import SwiftUI

enum MiraThemeMode: String, CaseIterable, Identifiable {
	case system = "System"
	case light = "Light"
	case dark = "Dark"

	var id: String { rawValue }
}

enum MiraLanguage: String, CaseIterable, Identifiable {
	case english = "English"
	case romanian = "Romanian"
	case russian = "Russian"
	case french = "French"
	case chinese = "Chinese"
	case japanese = "Japanese"

	var id: String { rawValue }
}

struct MiraTopBar: View {
	@Binding var selectedTheme: MiraThemeMode
	@Binding var selectedLanguage: MiraLanguage

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			Picker("Language", selection: $selectedLanguage) {
				ForEach(MiraLanguage.allCases) { language in
					Text(language.rawValue).tag(language)
				}
			}
			.labelsHidden()
			.pickerStyle(.menu)

			Spacer()

			Text("Mira")
				.font(.title2)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Spacer()

			Picker("Theme", selection: $selectedTheme) {
				ForEach(MiraThemeMode.allCases) { theme in
					Text(theme.rawValue).tag(theme)
				}
			}
			.labelsHidden()
			.pickerStyle(.menu)
		}
	}
}
