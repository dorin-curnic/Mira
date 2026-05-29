import Foundation

enum MiraText {
	case appName

	case dashboardTitle
	case dashboardSubtitle
	case wifiName
	case wifiDescription
	case connect
	case disconnect
	case authenticateReason

	case connected
	case pending
	case rejected
	case disconnected

	case speedTestTitle
	case speedTestDescription
	case mbps

	case credentialsTitle
	case credentialsSubtitle
	case username
	case password
	case portal
	case copyUsername
	case copyPassword
	case copyPortal

	case networkTitle
	case networkSubtitle
	case wifiConnection
	case download
	case upload
	case total
	case collectingNetworkData

	case system
	case light
	case dark

	case english
	case romanian
	case russian
	case french
	case chinese
	case japanese

	func localized(_ language: MiraLanguage) -> String {
		switch language {
		case .english:
			return englishValue
		case .romanian:
			return romanianValue
		case .russian:
			return russianValue
		case .french:
			return frenchValue
		case .chinese:
			return chineseValue
		case .japanese:
			return japaneseValue
		}
	}

	private var englishValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "Dashboard"
		case .dashboardSubtitle: return "Connect to university Wi-Fi."
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "Connect to the UTM-WiNetUni_Auth Wi-Fi, and check the status of the connection."
		case .connect: return "Connect"
		case .disconnect: return "Disconnect"
		case .authenticateReason: return "Authenticate to securely connect to university Wi-Fi."

		case .connected: return "Connected"
		case .pending: return "Pending"
		case .rejected: return "Rejected"
		case .disconnected: return "Disconnected"

		case .speedTestTitle: return "Speed Test"
		case .speedTestDescription: return "Mira downloads a small test file to analyse your network."
		case .mbps: return "Mbps"

		case .credentialsTitle: return "Credentials"
		case .credentialsSubtitle: return "Manage your credentials information."
		case .username: return "Username"
		case .password: return "Password"
		case .portal: return "Portal"
		case .copyUsername: return "Copy Username"
		case .copyPassword: return "Copy Password"
		case .copyPortal: return "Copy Portal"

		case .networkTitle: return "Network"
		case .networkSubtitle: return "Track the usage of the connection."
		case .wifiConnection: return "Wi-Fi Connection"
		case .download: return "Download"
		case .upload: return "Upload"
		case .total: return "Total"
		case .collectingNetworkData: return "Collecting network data..."

		case .system: return "System"
		case .light: return "Light"
		case .dark: return "Dark"

		case .english: return "English"
		case .romanian: return "Romanian"
		case .russian: return "Russian"
		case .french: return "French"
		case .chinese: return "Chinese"
		case .japanese: return "Japanese"
		}
	}

	private var romanianValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "Panou"
		case .dashboardSubtitle: return "Conectează-te la Wi-Fi-ul universității."
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "Conectează-te la Wi-Fi-ul UTM-WiNetUni_Auth și verifică starea conexiunii."
		case .connect: return "Conectează"
		case .disconnect: return "Deconectează"
		case .authenticateReason: return "Autentifică-te pentru a te conecta securizat la Wi-Fi-ul universității."

		case .connected: return "Conectat"
		case .pending: return "În așteptare"
		case .rejected: return "Respins"
		case .disconnected: return "Deconectat"

		case .speedTestTitle: return "Test de viteză"
		case .speedTestDescription: return "Mira descarcă un fișier mic de test pentru a analiza rețeaua."
		case .mbps: return "Mbps"

		case .credentialsTitle: return "Date de acces"
		case .credentialsSubtitle: return "Gestionează informațiile tale de autentificare."
		case .username: return "Utilizator"
		case .password: return "Parolă"
		case .portal: return "Portal"
		case .copyUsername: return "Copiază utilizatorul"
		case .copyPassword: return "Copiază parola"
		case .copyPortal: return "Copiază portalul"

		case .networkTitle: return "Rețea"
		case .networkSubtitle: return "Urmărește utilizarea conexiunii."
		case .wifiConnection: return "Conexiune Wi-Fi"
		case .download: return "Descărcare"
		case .upload: return "Încărcare"
		case .total: return "Total"
		case .collectingNetworkData: return "Se colectează datele rețelei..."

		case .system: return "Sistem"
		case .light: return "Luminos"
		case .dark: return "Întunecat"

		case .english: return "Engleză"
		case .romanian: return "Română"
		case .russian: return "Rusă"
		case .french: return "Franceză"
		case .chinese: return "Chineză"
		case .japanese: return "Japoneză"
		}
	}

	private var russianValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "Панель"
		case .dashboardSubtitle: return "Подключитесь к университетскому Wi-Fi."
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "Подключитесь к UTM-WiNetUni_Auth и проверьте состояние соединения."
		case .connect: return "Подключить"
		case .disconnect: return "Отключить"
		case .authenticateReason: return "Подтвердите личность для безопасного подключения к университетскому Wi-Fi."

		case .connected: return "Подключено"
		case .pending: return "Ожидание"
		case .rejected: return "Отклонено"
		case .disconnected: return "Отключено"

		case .speedTestTitle: return "Тест скорости"
		case .speedTestDescription: return "Mira загружает небольшой тестовый файл для анализа сети."
		case .mbps: return "Мбит/с"

		case .credentialsTitle: return "Данные доступа"
		case .credentialsSubtitle: return "Управляйте данными для входа."
		case .username: return "Имя пользователя"
		case .password: return "Пароль"
		case .portal: return "Портал"
		case .copyUsername: return "Копировать имя"
		case .copyPassword: return "Копировать пароль"
		case .copyPortal: return "Копировать портал"

		case .networkTitle: return "Сеть"
		case .networkSubtitle: return "Отслеживайте использование соединения."
		case .wifiConnection: return "Wi-Fi соединение"
		case .download: return "Загрузка"
		case .upload: return "Отправка"
		case .total: return "Всего"
		case .collectingNetworkData: return "Сбор сетевых данных..."

		case .system: return "Система"
		case .light: return "Светлая"
		case .dark: return "Тёмная"

		case .english: return "Английский"
		case .romanian: return "Румынский"
		case .russian: return "Русский"
		case .french: return "Французский"
		case .chinese: return "Китайский"
		case .japanese: return "Японский"
		}
	}

	private var frenchValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "Tableau de bord"
		case .dashboardSubtitle: return "Connectez-vous au Wi-Fi de l’université."
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "Connectez-vous au Wi-Fi UTM-WiNetUni_Auth et vérifiez l’état de la connexion."
		case .connect: return "Connecter"
		case .disconnect: return "Déconnecter"
		case .authenticateReason: return "Authentifiez-vous pour vous connecter au Wi-Fi universitaire en toute sécurité."

		case .connected: return "Connecté"
		case .pending: return "En attente"
		case .rejected: return "Rejeté"
		case .disconnected: return "Déconnecté"

		case .speedTestTitle: return "Test de vitesse"
		case .speedTestDescription: return "Mira télécharge un petit fichier de test pour analyser votre réseau."
		case .mbps: return "Mbit/s"

		case .credentialsTitle: return "Identifiants"
		case .credentialsSubtitle: return "Gérez vos informations d’identification."
		case .username: return "Nom d’utilisateur"
		case .password: return "Mot de passe"
		case .portal: return "Portail"
		case .copyUsername: return "Copier l’utilisateur"
		case .copyPassword: return "Copier le mot de passe"
		case .copyPortal: return "Copier le portail"

		case .networkTitle: return "Réseau"
		case .networkSubtitle: return "Suivez l’utilisation de la connexion."
		case .wifiConnection: return "Connexion Wi-Fi"
		case .download: return "Téléchargement"
		case .upload: return "Envoi"
		case .total: return "Total"
		case .collectingNetworkData: return "Collecte des données réseau..."

		case .system: return "Système"
		case .light: return "Clair"
		case .dark: return "Sombre"

		case .english: return "Anglais"
		case .romanian: return "Roumain"
		case .russian: return "Russe"
		case .french: return "Français"
		case .chinese: return "Chinois"
		case .japanese: return "Japonais"
		}
	}

	private var chineseValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "仪表板"
		case .dashboardSubtitle: return "连接到大学 Wi-Fi。"
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "连接到 UTM-WiNetUni_Auth Wi-Fi，并检查连接状态。"
		case .connect: return "连接"
		case .disconnect: return "断开连接"
		case .authenticateReason: return "请验证身份，以安全连接到大学 Wi-Fi。"

		case .connected: return "已连接"
		case .pending: return "等待中"
		case .rejected: return "已拒绝"
		case .disconnected: return "未连接"

		case .speedTestTitle: return "速度测试"
		case .speedTestDescription: return "Mira 会下载一个小型测试文件来分析网络。"
		case .mbps: return "Mbps"

		case .credentialsTitle: return "凭据"
		case .credentialsSubtitle: return "管理你的登录信息。"
		case .username: return "用户名"
		case .password: return "密码"
		case .portal: return "门户"
		case .copyUsername: return "复制用户名"
		case .copyPassword: return "复制密码"
		case .copyPortal: return "复制门户"

		case .networkTitle: return "网络"
		case .networkSubtitle: return "跟踪连接使用情况。"
		case .wifiConnection: return "Wi-Fi 连接"
		case .download: return "下载"
		case .upload: return "上传"
		case .total: return "总计"
		case .collectingNetworkData: return "正在收集网络数据..."

		case .system: return "系统"
		case .light: return "浅色"
		case .dark: return "深色"

		case .english: return "英语"
		case .romanian: return "罗马尼亚语"
		case .russian: return "俄语"
		case .french: return "法语"
		case .chinese: return "中文"
		case .japanese: return "日语"
		}
	}

	private var japaneseValue: String {
		switch self {
		case .appName: return "Mira"

		case .dashboardTitle: return "ダッシュボード"
		case .dashboardSubtitle: return "大学の Wi-Fi に接続します。"
		case .wifiName: return "UTM Wi-Fi"
		case .wifiDescription: return "UTM-WiNetUni_Auth Wi-Fi に接続し、接続状態を確認します。"
		case .connect: return "接続"
		case .disconnect: return "切断"
		case .authenticateReason: return "大学 Wi-Fi に安全に接続するために認証してください。"

		case .connected: return "接続済み"
		case .pending: return "保留中"
		case .rejected: return "拒否済み"
		case .disconnected: return "未接続"

		case .speedTestTitle: return "速度テスト"
		case .speedTestDescription: return "Mira は小さなテストファイルをダウンロードしてネットワークを分析します。"
		case .mbps: return "Mbps"

		case .credentialsTitle: return "認証情報"
		case .credentialsSubtitle: return "ログイン情報を管理します。"
		case .username: return "ユーザー名"
		case .password: return "パスワード"
		case .portal: return "ポータル"
		case .copyUsername: return "ユーザー名をコピー"
		case .copyPassword: return "パスワードをコピー"
		case .copyPortal: return "ポータルをコピー"

		case .networkTitle: return "ネットワーク"
		case .networkSubtitle: return "接続の使用状況を追跡します。"
		case .wifiConnection: return "Wi-Fi 接続"
		case .download: return "ダウンロード"
		case .upload: return "アップロード"
		case .total: return "合計"
		case .collectingNetworkData: return "ネットワークデータを収集中..."

		case .system: return "システム"
		case .light: return "ライト"
		case .dark: return "ダーク"

		case .english: return "英語"
		case .romanian: return "ルーマニア語"
		case .russian: return "ロシア語"
		case .french: return "フランス語"
		case .chinese: return "中国語"
		case .japanese: return "日本語"
		}
	}
}
