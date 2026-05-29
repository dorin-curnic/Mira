import Foundation

enum SpeedTestError: Error, LocalizedError {
	case invalidResponse(Int)
	case emptyDownload

	var errorDescription: String? {
		switch self {
		case .invalidResponse(let statusCode):
			return "The speed test server returned an invalid response. HTTP \(statusCode)."
		case .emptyDownload:
			return "No data was downloaded during the speed test."
		}
	}
}
