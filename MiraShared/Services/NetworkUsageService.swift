import Foundation
import Combine
import Darwin

struct NetworkUsageSnapshot {
	let timestamp: Date
	let downloadedBytes: UInt64
	let uploadedBytes: UInt64
}

struct NetworkUsagePoint: Identifiable {
	let id = UUID()
	let timestamp: Date
	let downloadBytesPerSecond: Double
	let uploadBytesPerSecond: Double
	let totalDownloadedBytes: UInt64
	let totalUploadedBytes: UInt64
}

@MainActor
final class NetworkUsageService: ObservableObject {
	@Published private(set) var points: [NetworkUsagePoint] = []
	@Published private(set) var downloadSpeedText = "0 B/s"
	@Published private(set) var uploadSpeedText = "0 B/s"
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

		let snapshot = readSnapshot()
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
		let current = readSnapshot()

		guard let previousSnapshot, let firstSnapshot, let startedAt else {
			self.previousSnapshot = current
			return
		}

		let seconds = max(current.timestamp.timeIntervalSince(previousSnapshot.timestamp), 1)

		let downloadedDelta = current.downloadedBytes >= previousSnapshot.downloadedBytes
		? current.downloadedBytes - previousSnapshot.downloadedBytes
		: 0

		let uploadedDelta = current.uploadedBytes >= previousSnapshot.uploadedBytes
		? current.uploadedBytes - previousSnapshot.uploadedBytes
		: 0

		let downloadSpeed = Double(downloadedDelta) / seconds
		let uploadSpeed = Double(uploadedDelta) / seconds

		let totalDownloaded = current.downloadedBytes >= firstSnapshot.downloadedBytes
		? current.downloadedBytes - firstSnapshot.downloadedBytes
		: 0

		let totalUploaded = current.uploadedBytes >= firstSnapshot.uploadedBytes
		? current.uploadedBytes - firstSnapshot.uploadedBytes
		: 0

		let point = NetworkUsagePoint(
			timestamp: current.timestamp,
			downloadBytesPerSecond: downloadSpeed,
			uploadBytesPerSecond: uploadSpeed,
			totalDownloadedBytes: totalDownloaded,
			totalUploadedBytes: totalUploaded
		)

		points.append(point)

		if points.count > maxPoints {
			points.removeFirst(points.count - maxPoints)
		}

		downloadSpeedText = Self.formatBytesPerSecond(downloadSpeed)
		uploadSpeedText = Self.formatBytesPerSecond(uploadSpeed)
		downloadedTotalText = Self.formatBytes(totalDownloaded)
		uploadedTotalText = Self.formatBytes(totalUploaded)
		connectedTimeText = Self.formatDuration(Date().timeIntervalSince(startedAt))

		self.previousSnapshot = current
	}

	private func readSnapshot() -> NetworkUsageSnapshot {
		var addresses: UnsafeMutablePointer<ifaddrs>?

		var downloaded: UInt64 = 0
		var uploaded: UInt64 = 0

		guard getifaddrs(&addresses) == 0, let firstAddress = addresses else {
			return NetworkUsageSnapshot(
				timestamp: Date(),
				downloadedBytes: 0,
				uploadedBytes: 0
			)
		}

		defer {
			freeifaddrs(addresses)
		}

		var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddress

		while pointer != nil {
			guard let interface = pointer?.pointee else {
				pointer = pointer?.pointee.ifa_next
				continue
			}

			let name = String(cString: interface.ifa_name)
			let isLoopback = name == "lo0"
			let isInterfaceUp = (interface.ifa_flags & UInt32(IFF_UP)) != 0
			let isLinkLayer = interface.ifa_addr.pointee.sa_family == UInt8(AF_LINK)

			if !isLoopback, isInterfaceUp, isLinkLayer {
				let data = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>?.self)

				if let data {
					downloaded += UInt64(data.pointee.ifi_ibytes)
					uploaded += UInt64(data.pointee.ifi_obytes)
				}
			}

			pointer = interface.ifa_next
		}

		return NetworkUsageSnapshot(
			timestamp: Date(),
			downloadedBytes: downloaded,
			uploadedBytes: uploaded
		)
	}

	private static func formatBytesPerSecond(_ bytes: Double) -> String {
		if bytes <= 0 {
			return "Zero KB/s"
		}

		return "\(formatBytes(UInt64(bytes)))/s"
	}

	private static func formatBytes(_ bytes: UInt64) -> String {
		let formatter = ByteCountFormatter()
		formatter.countStyle = .binary
		formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
		formatter.includesUnit = true
		formatter.isAdaptive = true

		return formatter.string(fromByteCount: Int64(bytes))
	}

	private static func formatDuration(_ interval: TimeInterval) -> String {
		let totalSeconds = Int(interval)

		let days = totalSeconds / 86400
		let hours = (totalSeconds % 86400) / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60

		if days > 0 {
			return String(format: "%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
		}

		if hours > 0 {
			return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
		}

		if minutes > 0 {
			return String(format: "%dm %02ds", minutes, seconds)
		}

		return "\(seconds)s"
	}
}
