import Foundation

enum MiraLanguage: String, CaseIterable, Identifiable {
	case english = "English"
	case romanian = "Romanian"
	case russian = "Russian"
	case french = "French"
	case chinese = "Chinese"
	case japanese = "Japanese"

	var id: String { rawValue }

	var shortName: String {
		switch self {
		case .english:
			return "En"
		case .romanian:
			return "Ro"
		case .russian:
			return "Ru"
		case .french:
			return "Fr"
		case .chinese:
			return "Zh"
		case .japanese:
			return "Ja"
		}
	}
}
