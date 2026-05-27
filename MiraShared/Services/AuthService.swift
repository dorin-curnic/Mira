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
	func authenticate(reason: String = "Authenticate to continue with Mira") async throws -> Bool {
		let context = LAContext()
		context.localizedCancelTitle = "Cancel"

		var error: NSError?

		guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
			throw AuthError.unavailable(
				error?.localizedDescription ?? "Device authentication is not available."
			)
		}

		return try await withCheckedThrowingContinuation { continuation in
			context.evaluatePolicy(
				.deviceOwnerAuthentication,
				localizedReason: reason
			) { success, error in
				if success {
					continuation.resume(returning: true)
				} else {
					continuation.resume(
						throwing: AuthError.failed(
							error?.localizedDescription ?? "Authentication failed."
						)
					)
				}
			}
		}
	}
}
