import SwiftUI

struct ContentView: View {
	@State private var selectedPage: MiraPage = .dashboard
	@State private var selectedTheme: MiraThemeMode = .system
	@State private var selectedLanguage: MiraLanguage = .english

	@StateObject private var networkUsageService = NetworkUsageService()

	var body: some View {

		rootLayout
			.onAppear {
				networkUsageService.start()
			}
			.onDisappear {
				networkUsageService.stop()
			}
	}
	@ViewBuilder
	private var rootLayout: some View {
#if os(macOS)
		macOSLayout
#else
		iOSLayout
#endif
	}

#if !os(macOS)
	private var iOSLayout: some View {
		VStack(spacing: 0) {
			topBar

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

				NetworkView(networkUsageService: networkUsageService)
					.tabItem {
						Label(MiraPage.network.rawValue, systemImage: MiraPage.network.iconName)
					}
					.tag(MiraPage.network)
			}
			.tint(MiraTheme.ColorToken.primary)
		}
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
			VStack(spacing: 0) {
				topBar
				selectedView
			}
			.frame(minWidth: 520, minHeight: 520)
		}
	}
#endif

	private var topBar: some View {
		VStack(spacing: 0) {
			MiraTopBar(
				selectedTheme: $selectedTheme,
				selectedLanguage: $selectedLanguage
			)
			.padding(.horizontal, MiraTheme.Spacing.xl)
			.padding(.vertical, MiraTheme.Spacing.md)
		}
		.background(MiraTheme.ColorToken.background)
	}

	@ViewBuilder
	private var selectedView: some View {
		switch selectedPage {
		case .dashboard:
			DashboardView()
		case .credentials:
			CredentialsView()
		case .network:
			NetworkView(networkUsageService: networkUsageService)
		}
	}
}

#Preview {
	ContentView()
}
