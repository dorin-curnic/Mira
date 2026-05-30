import Foundation

enum ReportCategory: String, CaseIterable, Identifiable {
	case language = "Language"
	case uiBug = "UI Bug"
	case credentials = "Credentials"
	case connection = "Connection"
	case speedTest = "Speed Test"
	case network = "Network"
	case other = "Other"

	var id: String {
		rawValue
	}
}
