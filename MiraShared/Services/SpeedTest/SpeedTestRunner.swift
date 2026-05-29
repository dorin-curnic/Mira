import Foundation

final class SpeedTestRunner: NSObject, URLSessionDataDelegate {
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
