import Foundation

struct SpeedTestResult {
	let downloadedBytes: Int64
	let duration: TimeInterval
	let finalMegabitsPerSecond: Double

	var speedValueText: String {
		if finalMegabitsPerSecond < 1 {
			return String(format: "%.2f", finalMegabitsPerSecond)
		}

		return String(format: "%.1f", finalMegabitsPerSecond)
	}

	var speedText: String {
		"\(speedValueText) Mbps"
	}
}
