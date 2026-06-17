import SwiftUI

private struct MiraFormInputChrome: ViewModifier {
	let isInvalid: Bool

	func body(content: Content) -> some View {
		content
			.padding(.horizontal, MiraTheme.Spacing.md)
			.padding(.vertical, MiraTheme.Spacing.md)
			.background(MiraTheme.ColorToken.secondary)
			.clipShape(
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.md,
					style: .continuous
				)
			)
			.overlay {
				RoundedRectangle(
					cornerRadius: MiraTheme.Radius.md,
					style: .continuous
				)
				.stroke(
					isInvalid
					? MiraTheme.ColorToken.destructive
					: MiraTheme.ColorToken.border,
					lineWidth: 1
				)
			}
	}
}

extension View {
	func miraFormInputChrome(isInvalid: Bool = false) -> some View {
		modifier(MiraFormInputChrome(isInvalid: isInvalid))
	}
}
