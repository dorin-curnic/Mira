import Foundation

enum SpeedTestEvent {
	case progress(SpeedTestProgress)
	case completed(SpeedTestResult)
}
