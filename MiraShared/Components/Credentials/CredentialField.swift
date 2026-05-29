import Foundation

enum CredentialField: Equatable {
	case username
	case password
	case portal

	var copyLabel: String {
		switch self {
		case .username:
			return "Copy Username"
		case .password:
			return "Copy Password"
		case .portal:
			return "Copy Portal"
		}
	}
}
