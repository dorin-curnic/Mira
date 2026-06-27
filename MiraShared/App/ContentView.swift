import SwiftUI

struct ContentView: View {
	@State private var selectedPage: MiraPage = .dashboard
	@AppStorage("selectedTheme") private var selectedThemeRawValue = MiraThemeMode.system.rawValue
	@AppStorage("selectedLanguage") private var selectedLanguageRawValue = MiraLanguage.english
		.rawValue

	@StateObject private var networkUsageService = NetworkUsageService()

	var body: some View {
		rootLayout
			.preferredColorScheme(selectedTheme.colorScheme)
			.environment(\.miraLanguage, selectedLanguage)
			.onAppear {
				networkUsageService.start()
			}
			.onDisappear {
				networkUsageService.stop()
			}
	}

	private var selectedTheme: MiraThemeMode {
		MiraThemeMode(rawValue: selectedThemeRawValue) ?? .system
	}

	private var selectedLanguage: MiraLanguage {
		MiraLanguage(rawValue: selectedLanguageRawValue) ?? .english
	}

	private var selectedThemeBinding: Binding<MiraThemeMode> {
		Binding(
			get: {
				selectedTheme
			},
			set: {
				selectedThemeRawValue = $0.rawValue
			}
		)
	}

	private var selectedLanguageBinding: Binding<MiraLanguage> {
		Binding(
			get: {
				selectedLanguage
			},
			set: {
				selectedLanguageRawValue = $0.rawValue
			}
		)
	}

	@ViewBuilder
	private var rootLayout: some View {
		#if os(macOS)
			macOSLayout
		#else
			iOSLayout
		#endif
	}

	private var topBar: some View {
		VStack(spacing: 0) {
			MiraTopBar(
				selectedTheme: selectedThemeBinding,
				selectedLanguage: selectedLanguageBinding
			)
			.padding(.horizontal, MiraTheme.Spacing.xl)
			.padding(.vertical, MiraTheme.Spacing.md)
		}
		.background(MiraTheme.ColorToken.background)
	}

	#if !os(macOS)
		private var iOSLayout: some View {
			VStack(spacing: 0) {
				topBar

				TabView(selection: $selectedPage) {
					DashboardView()
						.tabItem {
							Label(
								MiraPage.dashboard.titleText.localized(selectedLanguage),
								systemImage: MiraPage.dashboard.iconName
							)
						}
						.tag(MiraPage.dashboard)

					NetworkView(networkUsageService: networkUsageService)
						.tabItem {
							Label(
								MiraPage.network.titleText.localized(selectedLanguage),
								systemImage: MiraPage.network.iconName
							)
						}
						.tag(MiraPage.network)

					SettingsView()
						.tabItem {
							Label(
								MiraPage.settings.titleText.localized(selectedLanguage),
								systemImage: MiraPage.settings.iconName
							)
						}
						.tag(MiraPage.settings)
				}
				.tint(MiraTheme.ColorToken.primary)
			}
			.background(MiraTheme.ColorToken.background)
		}
	#endif

	#if os(macOS)
		private var macOSLayout: some View {
			NavigationSplitView {
				List(selection: $selectedPage) {
					ForEach(MiraPage.allCases) { page in
						Label(page.titleText.localized(selectedLanguage), systemImage: page.iconName)
							.tag(page)
					}
				}
				.navigationTitle(MiraText.appName.localized(selectedLanguage))
				.frame(minWidth: 180)
			} detail: {
				VStack(spacing: 0) {
					topBar
					selectedView
				}
				.frame(minWidth: 520, minHeight: 520)
				.background(MiraTheme.ColorToken.background)
			}
		}
	#endif

	@ViewBuilder
	private var selectedView: some View {
		switch selectedPage {
		case .dashboard:
			DashboardView()
		case .network:
			NetworkView(networkUsageService: networkUsageService)
		case .settings:
			SettingsView()
		}
	}
}

#Preview {
	ContentView()
}
