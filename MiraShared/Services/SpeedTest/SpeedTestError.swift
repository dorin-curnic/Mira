import Foundation

enum SpeedTestError: Error, LocalizedError {
	case invalidResponse(Int)
	case emptyDownload

	func errorDescription (language: MiraLanguage) -> String? {
		switch self {
		case .invalidResponse(let statusCode):
			return String(
				format: MiraText.speedTestErrorInvalidResponse.localized(language),
				statusCode
			)

		case .emptyDownload:
			return MiraText.speedTestErrorEmptyDownload.localized(language)
		}
	}
}
