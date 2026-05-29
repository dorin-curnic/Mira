import Foundation

extension String {
	func addingSoftBreaks(every interval: Int) -> String {
		guard interval > 0 else {
			return self
		}

		var result = ""
		var count = 0

		for character in self {
			result.append(character)
			count += 1

			if count >= interval {
				result.append("\u{200B}")
				count = 0
			}
		}

		return result
	}
}
