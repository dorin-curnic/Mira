import SwiftUI

struct MiraFieldLabel: View {
	let title: String

	init(_ title: String) {
		self.title = title
	}

	var body: some View {
		Text(title)
			.font(MiraTheme.Typography.rowTitle)
			.fontWeight(MiraTheme.Typography.rowTitleWeight)
			.foregroundStyle(MiraTheme.ColorToken.foreground)
	}
}
