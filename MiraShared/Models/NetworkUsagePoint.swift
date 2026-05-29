import Foundation

struct NetworkUsagePoint: Identifiable {
	let timestamp: Date
	let downloadBytesPerSecond: Double
	let uploadBytesPerSecond: Double
	let totalDownloadedBytes: UInt64
	let totalUploadedBytes: UInt64

	var id: Date {
		timestamp
	}
}
