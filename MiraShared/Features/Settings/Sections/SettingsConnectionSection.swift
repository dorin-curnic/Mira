import SwiftUI

private struct PortalRowBoundsKey: PreferenceKey {
	static var defaultValue: Anchor<CGRect>?

	static func reduce(
		value: inout Anchor<CGRect>?,
		nextValue: () -> Anchor<CGRect>?
	) {
		value = nextValue() ?? value
	}
}

struct SettingsConnectionSection: View {
	@Environment(\.miraLanguage) private var language

	@Binding var allowsAutoReconnect: Bool
	@Binding var isPortalCopyButtonVisible: Bool

	let portal: String

	var body: some View {
		MiraCardSection(title: "Connection") {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
				autoReconnectToggle

				Divider()

				portalRow
			}
		}
	}

	private var autoReconnectToggle: some View {
		Toggle(isOn: $allowsAutoReconnect) {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				Text("Auto-reconnect")
					.font(MiraTheme.Typography.rowTitle)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Text("Allow Mira to reconnect to university Wi-Fi when needed.")
					.font(MiraTheme.Typography.rowSubtitle)
					.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
			}
		}
	}

	private var portalRow: some View {
		Button {
			togglePortalCopyButton()
		} label: {
			HStack {
				Text(MiraText.portal.localized(language))
					.font(MiraTheme.Typography.rowTitle)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.fixedSize(horizontal: true, vertical: false)

				Spacer(minLength: MiraTheme.Spacing.md)

				Text(portal)
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
		.anchorPreference(key: PortalRowBoundsKey.self, value: .bounds) {
			$0
		}
		.overlayPreferenceValue(PortalRowBoundsKey.self) { anchor in
			GeometryReader { geometry in
				if let anchor, isPortalCopyButtonVisible {
					floatingPortalCopyButton
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
				value: isPortalCopyButtonVisible
			)
		}
	}

	private var floatingPortalCopyButton: some View {
		Button {
			ClipboardService.copy(portal)
			isPortalCopyButtonVisible = false
		} label: {
			Text(MiraText.copyPortal.localized(language))
				.font(MiraTheme.Typography.button)
				.fontWeight(MiraTheme.Typography.buttonWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, 24)
				.padding(.vertical, 12)
				.frame(minHeight: 44)
		}
		.buttonStyle(.miraGlassCopy)
	}

	private func togglePortalCopyButton() {
		isPortalCopyButtonVisible.toggle()
	}
}
