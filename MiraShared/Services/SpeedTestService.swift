import Foundation
import Combine

struct SpeedTestResult {
	let downloadedBytes: Int64
	let duration: TimeInterval
	let finalMegabitsPerSecond: Double

	var speedValueText: String {
		if finalMegabitsPerSecond < 1 {
			return String(format: "%.2f", finalMegabitsPerSecond)
		}

		return String(format: "%.1f", finalMegabitsPerSecond)
	}

	var speedText: String {
		"\(speedValueText) Mbps"
	}
}

struct SpeedTestProgress {
	let downloadedBytes: Int64
	let expectedBytes: Int64
	let elapsedTime: TimeInterval
	let currentMegabitsPerSecond: Double
	let progress: Double

	var speedValueText: String {
		if currentMegabitsPerSecond < 1 {
			return String(format: "%.2f", currentMegabitsPerSecond)
		}

		return String(format: "%.1f", currentMegabitsPerSecond)
	}
}

enum SpeedTestEvent {
	case progress(SpeedTestProgress)
	case completed(SpeedTestResult)
}

enum SpeedTestError: Error, LocalizedError {
	case invalidResponse(Int)
	case emptyDownload
	case missingExpectedSize

	var errorDescription: String? {
		switch self {
		case .invalidResponse(let statusCode):
			return "The speed test server returned an invalid response. HTTP \(statusCode)."
		case .emptyDownload:
			return "No data was downloaded during the speed test."
		case .missingExpectedSize:
			return "The speed test server did not provide a valid file size."
		}
	}
}

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

private final class SpeedTestRunner: NSObject, URLSessionDataDelegate {
	private let url: URL
	private let continuation: AsyncThrowingStream<SpeedTestEvent, Error>.Continuation

	private var session: URLSession?
	private var task: URLSessionDataTask?

	private var startedAt: Date?
	private var downloadedBytes: Int64 = 0
	private let targetExpectedBytes: Int64
	private var expectedBytes: Int64

	init(
		url: URL,
		expectedBytes: Int64,
		continuation: AsyncThrowingStream<SpeedTestEvent, Error>.Continuation
	) {
		self.url = url
		self.targetExpectedBytes = expectedBytes
		self.expectedBytes = expectedBytes
		self.continuation = continuation
	}

	func start() {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		configuration.urlCache = nil
		configuration.timeoutIntervalForRequest = 30
		configuration.timeoutIntervalForResource = 120

		let session = URLSession(
			configuration: configuration,
			delegate: self,
			delegateQueue: nil
		)

		self.session = session

		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		request.setValue("MiraSpeedTest/1.0", forHTTPHeaderField: "User-Agent")
		request.setValue("*/*", forHTTPHeaderField: "Accept")

		startedAt = Date()

		let task = session.dataTask(with: request)
		self.task = task
		task.resume()
	}

	func cancel() {
		task?.cancel()
		session?.invalidateAndCancel()
	}

	func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive response: URLResponse,
		completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
	) {
		guard let httpResponse = response as? HTTPURLResponse else {
			continuation.finish(throwing: SpeedTestError.invalidResponse(-1))
			completionHandler(.cancel)
			return
		}

		guard (200...299).contains(httpResponse.statusCode) else {
			continuation.finish(throwing: SpeedTestError.invalidResponse(httpResponse.statusCode))
			completionHandler(.cancel)
			return
		}

		let responseExpectedBytes = response.expectedContentLength

		if responseExpectedBytes > 0 {
			expectedBytes = responseExpectedBytes
		} else if let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
				  let parsedContentLength = Int64(contentLength),
				  parsedContentLength > 0 {
			expectedBytes = parsedContentLength
		} else {
			expectedBytes = targetExpectedBytes
		}
		
		completionHandler(.allow)
	}

	func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive data: Data
	) {
		downloadedBytes += Int64(data.count)

		guard let startedAt else {
			return
		}

		let elapsed = max(Date().timeIntervalSince(startedAt), 0.001)
		let speedMbps = Double(downloadedBytes) * 8 / elapsed / 1_000_000

		let progress: Double
		if expectedBytes > 0 {
			progress = min(Double(downloadedBytes) / Double(expectedBytes), 1)
		} else {
			progress = 0
		}

		let event = SpeedTestProgress(
			downloadedBytes: downloadedBytes,
			expectedBytes: expectedBytes,
			elapsedTime: elapsed,
			currentMegabitsPerSecond: speedMbps,
			progress: progress
		)

		continuation.yield(.progress(event))
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didCompleteWithError error: Error?
	) {
		defer {
			session.finishTasksAndInvalidate()
		}

		if let error {
			continuation.finish(throwing: error)
			return
		}

		guard downloadedBytes > 0 else {
			continuation.finish(throwing: SpeedTestError.emptyDownload)
			return
		}

		guard let startedAt else {
			continuation.finish(throwing: SpeedTestError.emptyDownload)
			return
		}

		let duration = max(Date().timeIntervalSince(startedAt), 0.001)
		let finalMbps = Double(downloadedBytes) * 8 / duration / 1_000_000

		let result = SpeedTestResult(
			downloadedBytes: downloadedBytes,
			duration: duration,
			finalMegabitsPerSecond: finalMbps
		)

		continuation.yield(.completed(result))
		continuation.finish()
	}
}
