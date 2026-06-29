import Combine
import Foundation
import Network

enum NetworkUsageState: Equatable {
	case collecting
	case active
	case unavailable
	case failed
}

@MainActor
final class NetworkUsageService: ObservableObject {
	@Published private(set) var points: [NetworkUsagePoint] = []
	@Published private(set) var downloadSpeedText = "Zero KB/s"
	@Published private(set) var uploadSpeedText = "Zero KB/s"
	@Published private(set) var downloadedTotalText = "0 B"
	@Published private(set) var uploadedTotalText = "0 B"
	@Published private(set) var connectedTimeText = "0s"
	@Published private(set) var usageState: NetworkUsageState = .collecting

	private var updateTask: Task<Void, Never>?
	private var pathMonitor: NWPathMonitor?
	private let pathMonitorQueue = DispatchQueue(label: "Mira.NetworkUsageService.PathMonitor")
	private var isNetworkPathAvailable = false

	private var firstSnapshot: NetworkUsageSnapshot?
	private var previousSnapshot: NetworkUsageSnapshot?
	private var startedAt: Date?
	private let maxPoints = 300

	func start() {
		stop()
		reset()
		startPathMonitor()

		updateTask = Task { [weak self] in
			while !Task.isCancelled {
				try? await Task.sleep(for: .seconds(1))
				self?.tick()
			}
		}
	}

	func stop() {
		updateTask?.cancel()
		updateTask = nil

		pathMonitor?.cancel()
		pathMonitor = nil
	}

	private func startPathMonitor() {
		let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
		pathMonitor = monitor

		monitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor [weak self] in
				self?.handlePathUpdate(path)
			}
		}

		monitor.start(queue: pathMonitorQueue)
	}

	private func handlePathUpdate(_ path: NWPath) {
		let wasNetworkPathAvailable = isNetworkPathAvailable
		isNetworkPathAvailable = path.status == .satisfied

		guard isNetworkPathAvailable else {
			markUnavailable()
			return
		}

		if !wasNetworkPathAvailable {
			reset()
			readInitialSnapshot()
		}
	}

	private func reset() {
		clearReadings()
		usageState = .collecting
		firstSnapshot = nil
		previousSnapshot = nil
		startedAt = Date()
	}

	private func readInitialSnapshot() {
		do {
			let snapshot = try NetworkInterfaceReader.readSnapshot()
			firstSnapshot = snapshot
			previousSnapshot = snapshot
			usageState = .collecting
		} catch NetworkInterfaceReaderError.activeInterfaceUnavailable {
			markUnavailable()
		} catch {
			markFailed()
		}
	}

	private func tick() {
		guard isNetworkPathAvailable else {
			return
		}

		let current: NetworkUsageSnapshot

		do {
			current = try NetworkInterfaceReader.readSnapshot()
		} catch NetworkInterfaceReaderError.activeInterfaceUnavailable {
			markUnavailable()
			return
		} catch {
			markFailed()
			return
		}

		if usageState == .unavailable || usageState == .failed {
			reset()
			firstSnapshot = current
			previousSnapshot = current
			usageState = .collecting
			return
		}

		guard let previousSnapshot, let firstSnapshot, let startedAt else {
			self.firstSnapshot = current
			self.previousSnapshot = current
			self.startedAt = Date()
			usageState = .collecting
			return
		}

		let seconds = max(current.timestamp.timeIntervalSince(previousSnapshot.timestamp), 1)

		let downloadedDelta = byteDelta(
			current: current.downloadedBytes,
			previous: previousSnapshot.downloadedBytes
		)

		let uploadedDelta = byteDelta(
			current: current.uploadedBytes,
			previous: previousSnapshot.uploadedBytes
		)

		let downloadSpeed = Double(downloadedDelta) / seconds
		let uploadSpeed = Double(uploadedDelta) / seconds

		let totalDownloaded = byteDelta(
			current: current.downloadedBytes,
			previous: firstSnapshot.downloadedBytes
		)

		let totalUploaded = byteDelta(
			current: current.uploadedBytes,
			previous: firstSnapshot.uploadedBytes
		)

		let point = NetworkUsagePoint(
			timestamp: current.timestamp,
			downloadBytesPerSecond: downloadSpeed,
			uploadBytesPerSecond: uploadSpeed,
			totalDownloadedBytes: totalDownloaded,
			totalUploadedBytes: totalUploaded
		)

		appendPoint(point)

		downloadSpeedText = ByteFormatters.speed(downloadSpeed)
		uploadSpeedText = ByteFormatters.speed(uploadSpeed)
		downloadedTotalText = ByteFormatters.data(totalDownloaded)
		uploadedTotalText = ByteFormatters.data(totalUploaded)
		connectedTimeText = DurationFormatters.connectionTime(
			Date().timeIntervalSince(startedAt)
		)
		usageState = .active

		self.previousSnapshot = current
	}

	private func appendPoint(_ point: NetworkUsagePoint) {
		points.append(point)

		if points.count > maxPoints {
			points.removeFirst(points.count - maxPoints)
		}
	}

	private func byteDelta(current: UInt64, previous: UInt64) -> UInt64 {
		current >= previous ? current - previous : 0
	}

	private func markUnavailable() {
		usageState = .unavailable
		firstSnapshot = nil
		previousSnapshot = nil
		clearReadings()
	}

	private func markFailed() {
		usageState = .failed
		firstSnapshot = nil
		previousSnapshot = nil
		clearReadings()
	}

	private func clearReadings() {
		points = []
		downloadSpeedText = "Zero KB/s"
		uploadSpeedText = "Zero KB/s"
		downloadedTotalText = "0 B"
		uploadedTotalText = "0 B"
		connectedTimeText = "0s"
	}
}
