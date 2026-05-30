import SwiftUI

struct SettingsSectionView<Content: View, Trailing: View>: View {
	let title: String
	let trailing: Trailing
	let content: Content

	init(
		title: String,
		@ViewBuilder content: () -> Content
	) where Trailing == EmptyView {
		self.title = title
		self.trailing = EmptyView()
		self.content = content()
	}

	init(
		title: String,
		@ViewBuilder trailing: () -> Trailing,
		@ViewBuilder content: () -> Content
	) {
		self.title = title
		self.trailing = trailing()
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.md) {
			HStack(alignment: .center) {
				Text(title)
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.foreground)

				Spacer()

				trailing
			}

			MiraCard {
				content
			}
		}
	}
}
