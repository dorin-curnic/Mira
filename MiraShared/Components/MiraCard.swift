import SwiftUI

struct MiraCard<Content: View>: View {
	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		content
			.padding(MiraTheme.Spacing.lg)
			.background(MiraTheme.ColorToken.card)
			.clipShape(
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.lg,
					style: .continuous
				)
			)
			.overlay {
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.lg,
					style: .continuous
				)
				.stroke(MiraTheme.ColorToken.border, lineWidth: 1)
			}
	}
}
