import Foundation

enum DurationFormatters {
	static func connectionTime(_ interval: TimeInterval) -> String {
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
