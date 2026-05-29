import Foundation

struct SpeedTestProgress {
	let downloadedBytes: Int64
	let expectedBytes: Int64
	let elapsedTime: TimeInterval
	let currentMegabitsPerSecond: Double
	let progress: Double

	var speedValueText: String {
		if currentMegabitsPerSecond < 1 {
			return String(format: "%.2f", currentMegabitsPerSecond)
		}

		return String(format: "%.1f", currentMegabitsPerSecond)
	}
}
