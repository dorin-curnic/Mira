import Foundation
import LocalAuthentication

enum AuthError: Error, LocalizedError {
	case unavailable(String)
	case failed(String)

	var errorDescription: String? {
		switch self {
		case .unavailable(let message):
			return message
		case .failed(let message):
			return message
		}
	}
}

final class AuthService {
	func authenticate(
		reason: String = "Authenticate to continue with Mira",
		language: MiraLanguage
	) async throws {
		let context = LAContext()
		context.localizedCancelTitle = MiraText.commonCancel.localized(language)

		var error: NSError?

		guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
			throw AuthError.unavailable(
				error?.localizedDescription ?? MiraText.authErrorUnavailable.localized(language)
			)
		}

		try await withCheckedThrowingContinuation { continuation in
			context.evaluatePolicy(
				.deviceOwnerAuthentication,
				localizedReason: reason
			) { success, error in
				if success {
					continuation.resume()
				} else {
					continuation.resume(
						throwing: AuthError.failed(
							error?.localizedDescription ?? MiraText.authErrorFailed.localized(language)
						)
					)
				}
			}
		}
	}
}
