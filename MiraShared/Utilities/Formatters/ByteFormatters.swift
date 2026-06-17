import Foundation

enum ByteFormatters {
	static func speed(_ bytesPerSecond: Double) -> String {
		if bytesPerSecond <= 0 {
			return "Zero KB/s"
		}

		let value = UInt64(max(bytesPerSecond, 0))

		let formatter = ByteCountFormatter()
		formatter.countStyle = .binary
		formatter.allowedUnits = [.useKB, .useMB, .useGB]
		formatter.includesUnit = true
		formatter.isAdaptive = true

		return formatter.string(fromByteCount: Int64(value)) + "/s"
	}

	static func data(_ bytes: UInt64) -> String {
		let formatter = ByteCountFormatter()
		formatter.countStyle = .binary
		formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
		formatter.includesUnit = true
		formatter.isAdaptive = true

		return formatter.string(fromByteCount: Int64(bytes))
	}
}
