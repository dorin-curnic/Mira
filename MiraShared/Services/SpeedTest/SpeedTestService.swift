import Foundation

final class SpeedTestService {
	private let downloadBytes = 75_000_000

	private var testFileURL: URL {
		let measId = UUID().uuidString.replacingOccurrences(of: "-", with: "")

		var components = URLComponents()
		components.scheme = "https"
		components.host = "speed.cloudflare.com"
		components.path = "/__down"
		components.queryItems = [
			URLQueryItem(name: "measId", value: measId),
			URLQueryItem(name: "bytes", value: String(downloadBytes))
		]

		return components.url!
	}

	func runDownloadTest() -> AsyncThrowingStream<SpeedTestEvent, Error> {
		AsyncThrowingStream { continuation in
			let runner = SpeedTestRunner(
				url: testFileURL,
				expectedBytes: Int64(downloadBytes),
				continuation: continuation
			)

			runner.start()

			continuation.onTermination = { _ in
				runner.cancel()
			}
		}
	}
}
