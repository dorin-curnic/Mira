import SwiftUI

struct MiraTopBar: View {
	@Environment(\.colorScheme) private var colorScheme

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

			Text("Mira")
				.font(.title2)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Spacer()

			themeMenu
		}
	}

	private var languageMenu: some View {
		Menu {
			ForEach(MiraLanguage.allCases) { language in
				Button {
					selectedLanguage = language
				} label: {
					HStack {
						Text(language.rawValue)

						if selectedLanguage == language {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Text(selectedLanguage.shortName)
				.font(.subheadline)
				.fontWeight(.medium)
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
						Text(theme.rawValue)

						if selectedTheme == theme {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Image(systemName: selectedThemeIcon)
				.font(.subheadline)
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
