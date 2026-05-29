import SwiftUI

extension Text {
	init(_ miraText: MiraText, language: MiraLanguage) {
		self.init(verbatim: miraText.localized(language))
	}
}
