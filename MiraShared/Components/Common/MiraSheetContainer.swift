import SwiftUI

struct MiraSheetContainer<Content: View>: View {
	let maxWidth: CGFloat
	let content: Content

	init(
		maxWidth: CGFloat = MiraTheme.Layout.sheetMaxWidth,
		@ViewBuilder content: () -> Content
	) {
		self.maxWidth = maxWidth
		self.content = content()
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				content
			}
			.padding(MiraTheme.Spacing.xl)
			.frame(maxWidth: maxWidth)
			.frame(maxWidth: .infinity)
		}
		.background(MiraTheme.ColorToken.background)
	}
}
