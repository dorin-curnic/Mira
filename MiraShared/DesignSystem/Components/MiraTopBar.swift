import SwiftUI

struct MiraTopBar: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.miraLanguage) private var language

	@Binding var selectedTheme: MiraThemeMode
	@Binding var selectedLanguage: MiraLanguage

	private var selectedThemeIcon: String {
		if selectedTheme == .system {
			return colorScheme == .dark ? "moon" : "sun.max"
		}

		return selectedTheme.iconName
	}

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			languageMenu

			Spacer()

			Text(.appName, language: language)
				.font(MiraTheme.Typography.appTitle)
				.fontWeight(MiraTheme.Typography.appTitleWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Spacer()

			themeMenu
		}
	}

	private var languageMenu: some View {
		Menu {
			ForEach(MiraLanguage.allCases) { menuLanguage in
				Button {
					selectedLanguage = menuLanguage
				} label: {
					HStack {
						Text(menuLanguage.displayText, language: language)

						if selectedLanguage == menuLanguage {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Text(selectedLanguage.shortName)
				.font(MiraTheme.Typography.rowValue)
				.fontWeight(MiraTheme.Typography.rowValueWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.padding(.horizontal, MiraTheme.Spacing.md)
				.padding(.vertical, MiraTheme.Spacing.sm)
				.background(MiraTheme.ColorToken.secondary)
				.clipShape(
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
				)
		}
	}

	private var themeMenu: some View {
		Menu {
			ForEach(MiraThemeMode.allCases) { theme in
				Button {
					selectedTheme = theme
				} label: {
					HStack {
						Image(systemName: theme.iconName)

						Text(theme.displayText, language: language)

						if selectedTheme == theme {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Image(systemName: selectedThemeIcon)
				.font(MiraTheme.Typography.icon)
				.foregroundStyle(MiraTheme.ColorToken.foreground)
				.frame(width: 36, height: 36)
				.background(MiraTheme.ColorToken.secondary)
				.clipShape(
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
				)
		}
	}
}
