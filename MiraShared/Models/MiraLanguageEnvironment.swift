import SwiftUI

private struct MiraLanguageKey: EnvironmentKey {
	static let defaultValue: MiraLanguage = .english
}

extension EnvironmentValues {
	var miraLanguage: MiraLanguage {
		get {
			self[MiraLanguageKey.self]
		}
		set {
			self[MiraLanguageKey.self] = newValue
		}
	}
}
