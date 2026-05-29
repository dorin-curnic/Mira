import SwiftUI

struct CredentialsView: View {
	@Environment(\.miraLanguage) private var language

	@State private var activeField: CredentialField?

	private let username = "name.surname@xyz.utm.md"
	private let password = "university-password-ewubrfoueqbfoque-wefwef"
	private let portal = "wifi.university.local"

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader
				credentialsSection
			}
			.padding(MiraTheme.Spacing.xl)
			.frame(maxWidth: 820)
			.frame(maxWidth: .infinity)
		}
		.background(MiraTheme.ColorToken.background)
		.contentShape(Rectangle())
		.onTapGesture {
			activeField = nil
		}
	}

	private var pageHeader: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text(.credentialsTitle, language: language)
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text(.credentialsSubtitle, language: language)
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var credentialsSection: some View {
		CredentialsSectionView(
			username: username,
			password: password,
			portal: portal,
			activeField: $activeField
		)
	}
}

#Preview {
	CredentialsView()
}
