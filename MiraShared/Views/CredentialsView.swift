import SwiftUI

struct CredentialsView: View {
	@State private var activeField: CredentialField? = nil

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
				pageHeader
				userDataCard
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
			Text("Credentials")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Manage your credentials information.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var userDataCard: some View {
		CredentialsSectionView(
			username: "name.surname@xyz.utm.md",
			password: "university-password-ewubrfoueqbfoque-wefwef",
			portal: "wifi.university.local",
			activeField: $activeField
		)
	}
}

#Preview {
	CredentialsView()
}
