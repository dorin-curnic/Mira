import SwiftUI

enum NetworkTrafficKind {
	case download
	case upload

	func title(language: MiraLanguage) -> String {
		switch self {
		case .download:
			return MiraText.download.localized(language)
		case .upload:
			return MiraText.upload.localized(language)
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
