import SwiftUI

private struct SettingsCopyValueRowBoundsKey: PreferenceKey {
	static var defaultValue: Anchor<CGRect>?

	static func reduce(
		value: inout Anchor<CGRect>?,
		nextValue: () -> Anchor<CGRect>?
	) {
		value = nextValue() ?? value
	}
}

struct SettingsCopyValueRow: View {
	let title: String
	let value: String
	let copyLabel: String
	let isCopyButtonVisible: Bool
	let onToggleCopyButton: () -> Void
	let onCopy: () -> Void

	var body: some View {
		Button {
			onToggleCopyButton()
		} label: {
			HStack {
				Text(title)
					.font(MiraTheme.Typography.rowTitle)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.fixedSize(horizontal: true, vertical: false)

				Spacer(minLength: MiraTheme.Spacing.md)

				Text(value)
					.font(MiraTheme.Typography.rowSubtitle)
					.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					.multilineTextAlignment(.trailing)
					.lineLimit(1)
					.truncationMode(.middle)
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.anchorPreference(key: SettingsCopyValueRowBoundsKey.self, value: .bounds) {
			$0
		}
		.overlayPreferenceValue(SettingsCopyValueRowBoundsKey.self) { anchor in
			GeometryReader { geometry in
				if let anchor, isCopyButtonVisible {
					floatingCopyButton
						.fixedSize()
						.position(
							x: geometry.size.width * 0.68,
							y: geometry[anchor].minY - 18
						)
						.transition(
							.asymmetric(
								insertion: .scale(scale: 0.92).combined(with: .opacity),
								removal: .opacity
							)
						)
						.zIndex(10)
				}
			}
			.animation(
				.spring(response: 0.22, dampingFraction: 0.68),
				value: isCopyButtonVisible
			)
		}
	}

	private var floatingCopyButton: some View {
		Button {
			onCopy()
		} label: {
			Text(copyLabel)
				.font(MiraTheme.Typography.button)
				.fontWeight(MiraTheme.Typography.buttonWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}
}
