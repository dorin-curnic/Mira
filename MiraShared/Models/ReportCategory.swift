import Foundation

enum ReportCategory: CaseIterable, Identifiable {
	case language
	case uiBug
	case credentials
	case connection
	case speedTest
	case network
	case other

	var id: Self { self }

	var titleText: MiraText {
		switch self {
		case .language:
			return .reportCategoryLanguage
		case .uiBug:
			return .reportCategoryUIBug
		case .credentials:
			return .reportCategoryCredentials
		case .connection:
			return .reportCategoryConnection
		case .speedTest:
			return .reportCategorySpeedTest
		case .network:
			return .reportCategoryNetwork
		case .other:
			return .reportCategoryOther
		}
	}
}
