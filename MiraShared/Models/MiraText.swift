import Foundation

enum MiraText: String {
	// Global
	case appName = "app.name"
	case formInput = "form.input"

	case commonCancel = "common.cancel"
	case commonClose = "common.close"
	case commonSubmit = "common.submit"

	case navigationDashboard = "navigation.dashboard"
	case navigationNetwork = "navigation.network"
	case navigationSettings = "navigation.settings"

	case system = "theme.system"
	case light = "theme.light"
	case dark = "theme.dark"

	case english = "language.english"
	case romanian = "language.romanian"
	case russian = "language.russian"
	case french = "language.french"
	case chinese = "language.chinese"
	case japanese = "language.japanese"

	// Dashboard
	case dashboardTitle = "dashboard.title"
	case dashboardSubtitle = "dashboard.subtitle"
	case wifiName = "dashboard.wifi.name"
	case wifiDescription = "dashboard.wifi.description"
	case connect = "dashboard.connect"
	case disconnect = "dashboard.disconnect"
	case authenticateReason = "dashboard.authenticate.reason"

	case connected = "status.connected"
	case pending = "status.pending"
	case rejected = "status.rejected"
	case disconnected = "status.disconnected"

	case speedTestTitle = "speedtest.title"
	case speedTestDescription = "speedtest.description"
	case mbps = "speedtest.mbps"
	case speedTestErrorInvalidResponse = "speedtest.error.invalid_response"
	case speedTestErrorEmptyDownload = "speedtest.error.empty_download"

	// Network
	case networkTitle = "network.title"
	case networkSubtitle = "network.subtitle"
	case wifiConnection = "network.wifi.connection"
	case download = "network.download"
	case upload = "network.upload"
	case total = "network.total"
	case networkTotalFormat = "network.total.format"
	case networkChartTime = "network.chart.time"
	case networkChartMinimum = "network.chart.minimum"
	case networkChartSelectedTime = "network.chart.selected.time"
	case collectingNetworkData = "network.collecting.data"

	// Settings
	case settingsTitle = "settings.title"

	case settingsConnectionTitle = "settings.connection.title"
	case settingsAutoReconnectTitle = "settings.auto_reconnect.title"
	case settingsAutoReconnectSubtitle = "settings.auto_reconnect.subtitle"

	case settingsSupportTitle = "settings.support.title"
	case settingsReportFormTitle = "settings.report_form.title"
	case settingsReportFormSubtitle = "settings.report_form.subtitle"
	case settingsGitHubRepositoryTitle = "settings.github_repository.title"
	case settingsGitHubRepositorySubtitle = "settings.github_repository.subtitle"

	case settingsAboutTitle = "settings.about.title"
	case settingsVersionTitle = "settings.version.title"

	// Credentials
	case credentialsTitle = "credentials.title"
	case credentialsNoTitle = "credentials.no.title"
	case credentialsNoSubtitle = "credentials.no.subtitle"
	case credentialsAddButton = "credentials.add.button"

	case credentialsEditButton = "credentials.edit.button"
	case credentialsAddTitle = "credentials.add.title"
	case credentialsEditTitle = "credentials.edit.title"
	case credentialsSheetSubtitle = "credentials.sheet.subtitle"

	case universityName = "university.name"
	case username = "credentials.username"
	case password = "credentials.password"
	case portal = "credentials.portal"

	case credentialsUsernamePlaceholder = "credentials.username.placeholder"
	case credentialsUsernameRequiredError = "credentials.username.required.error"
	case credentialsUsernameFormatError = "credentials.username.format.error"

	case credentialsPasswordPlaceholder = "credentials.password.placeholder"
	case credentialsPasswordRequiredError = "credentials.password.required.error"

	case credentialsRevealAuthenticationReason = "credentials.reveal.authentication.reason"

	case credentialsDeleteButton = "credentials.delete.button"
	case credentialsDeleteQuestion = "credentials.delete.question"
	case credentialsDeleteMessage = "credentials.delete.message"

	case copyUsername = "credentials.copy.username"
	case copyPassword = "credentials.copy.password"
	case copyPortal = "credentials.copy.portal"

	// Report
	case reportFormTitle = "report.form.title"
	case reportTitle = "report.title"
	case reportSubtitle = "report.subtitle"

	case reportCategory = "report.category"
	case reportDescription = "report.description"
	case reportDescriptionPlaceholder = "report.description.placeholder"
	case reportDescriptionRequiredError = "report.description.required.error"

	case reportAttachments = "report.attachments"
	case reportAttachmentsAdd = "report.attachments.add"
	case reportAttachmentsNone = "report.attachments.none"
	case reportAttachmentsSelectedCount = "report.attachments.selected.count"

	case reportCategoryLanguage = "report.category.language"
	case reportCategoryUIBug = "report.category.ui_bug"
	case reportCategoryCredentials = "report.category.credentials"
	case reportCategoryConnection = "report.category.connection"
	case reportCategorySpeedTest = "report.category.speed_test"
	case reportCategoryNetwork = "report.category.network"
	case reportCategoryOther = "report.category.other"

	// Authentication
	case authErrorUnavailable = "auth.error.unavailable"
	case authErrorFailed = "auth.error.failed"

	func localized(_ language: MiraLanguage) -> String {
		let bundle = Bundle.localizedBundle(for: language)
		return bundle.localizedString(forKey: rawValue, value: rawValue, table: "Localizable")
	}
}

extension Bundle {
	fileprivate static func localizedBundle(for language: MiraLanguage) -> Bundle {
		guard
			let path = Bundle.main.path(
				forResource: language.localizationIdentifier,
				ofType: "lproj"
			),
			let bundle = Bundle(path: path)
		else {
			return .main
		}

		return bundle
	}
}
