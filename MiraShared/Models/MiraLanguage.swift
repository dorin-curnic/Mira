import Foundation

enum MiraLanguage: String, CaseIterable, Identifiable {
	case english = "English"
	case romanian = "Romanian"
	case russian = "Russian"
	case french = "French"
	case chinese = "Chinese"
	case japanese = "Japanese"

	var id: String { rawValue }

	var localizationIdentifier: String {
		switch self {
		case .english:
			return "en"
		case .romanian:
			return "ro"
		case .russian:
			return "ru"
		case .french:
			return "fr"
		case .chinese:
			return "zh-Hans"
		case .japanese:
			return "ja"
		}
	}

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

	var displayText: MiraText {
		switch self {
		case .english:
			return .english
		case .romanian:
			return .romanian
		case .russian:
			return .russian
		case .french:
			return .french
		case .chinese:
			return .chinese
		case .japanese:
			return .japanese
		}
	}
}
