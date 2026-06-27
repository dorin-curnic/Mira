import Combine
import Foundation

@MainActor
final class NetworkUsageService: ObservableObject {
	@Published private(set) var points: [NetworkUsagePoint] = []
	@Published private(set) var downloadSpeedText = "Zero KB/s"
	@Published private(set) var uploadSpeedText = "Zero KB/s"
	@Published private(set) var downloadedTotalText = "0 B"
	@Published private(set) var uploadedTotalText = "0 B"
	@Published private(set) var connectedTimeText = "0s"

	private var updateTask: Task<Void, Never>?
	private var firstSnapshot: NetworkUsageSnapshot?
	private var previousSnapshot: NetworkUsageSnapshot?
	private var startedAt: Date?

	private let maxPoints = 300

	func start() {
		stop()

		let snapshot = NetworkInterfaceReader.readSnapshot()
		firstSnapshot = snapshot
		previousSnapshot = snapshot
		startedAt = Date()

		updateTask = Task { [weak self] in
			while !Task.isCancelled {
				try? await Task.sleep(for: .seconds(1))

				await MainActor.run {
					self?.tick()
				}
			}
		}
	}

	func stop() {
		updateTask?.cancel()
		updateTask = nil
	}

	private func tick() {
		let current = NetworkInterfaceReader.readSnapshot()

		guard let previousSnapshot, let firstSnapshot, let startedAt else {
			self.previousSnapshot = current
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
}
