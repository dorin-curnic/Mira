import Foundation

enum CredentialField: Equatable {
	case username
	case password
	case portal

	func copyLabel(language: MiraLanguage) -> String {
		switch self {
		case .username:
			return MiraText.copyUsername.localized(language)
		case .password:
			return MiraText.copyPassword.localized(language)
		case .portal:
			return MiraText.copyPortal.localized(language)
		}
	}
}
