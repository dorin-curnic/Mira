import SwiftUI

struct ContentView: View {
	@State private var selectedPage: MiraPage = .dashboard

	var body: some View {
#if os(macOS)
		macOSLayout
#else
		iOSLayout
#endif
	}

#if !os(macOS)
	private var iOSLayout: some View {
		TabView(selection: $selectedPage) {
			DashboardView()
				.tabItem {
					Label(MiraPage.dashboard.rawValue, systemImage: MiraPage.dashboard.iconName)
				}
				.tag(MiraPage.dashboard)

			CredentialsView()
				.tabItem {
					Label(MiraPage.credentials.rawValue, systemImage: MiraPage.credentials.iconName)
				}
				.tag(MiraPage.credentials)

			UsageView()
				.tabItem {
					Label(MiraPage.usage.rawValue, systemImage: MiraPage.usage.iconName)
				}
				.tag(MiraPage.usage)
		}
		.tint(MiraTheme.ColorToken.primary)
	}
#endif

#if os(macOS)
	private var macOSLayout: some View {
		NavigationSplitView {
			List(selection: $selectedPage) {
				ForEach(MiraPage.allCases) { page in
					Label(page.rawValue, systemImage: page.iconName)
						.tag(page)
				}
			}
			.navigationTitle("Mira")
			.frame(minWidth: 180)
		} detail: {
			selectedView
				.frame(minWidth: 520, minHeight: 520)
		}
	}
#endif

	@ViewBuilder
	private var selectedView: some View {
		switch selectedPage {
		case .dashboard:
			DashboardView()
		case .credentials:
			CredentialsView()
		case .usage:
			UsageView()
		}
	}
}

#Preview {
	ContentView()
}
