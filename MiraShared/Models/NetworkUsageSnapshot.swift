import Foundation

struct NetworkUsageSnapshot {
	let timestamp: Date
	let downloadedBytes: UInt64
	let uploadedBytes: UInt64
}
