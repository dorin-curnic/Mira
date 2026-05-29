import SwiftUI

enum NetworkTrafficKind {
	case download
	case upload

	var title: String {
		switch self {
		case .download:
			return "Download"
		case .upload:
			return "Upload"
		}
	}

	var color: Color {
		switch self {
		case .download:
			return MiraTheme.ColorToken.chart2
		case .upload:
			return MiraTheme.ColorToken.chart5
		}
	}

	func speed(from point: NetworkUsagePoint) -> Double {
		switch self {
		case .download:
			return point.downloadBytesPerSecond
		case .upload:
			return point.uploadBytesPerSecond
		}
	}
}
