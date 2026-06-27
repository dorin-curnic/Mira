import Foundation

struct MiraSonnerMessage: Identifiable, Equatable {
	let id: UUID
	let title: String
	let description: String?
	let style: MiraSonnerStyle
	let duration: Duration?

	init(
		id: UUID = UUID(),
		title: String,
		description: String? = nil,
		style: MiraSonnerStyle = .default,
		duration: Duration? = .seconds(3)
	) {
		self.id = id
		self.title = title
		self.description = description
		self.style = style
		self.duration = duration
	}

	static func success(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .success)
	}

	static func error(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .error)
	}

	static func warning(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .warning)
	}

	static func info(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .info)
	}

	static func connected(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .connected)
	}

	static func disconnected(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .disconnected)
	}

	static func rejected(_ title: String, description: String? = nil) -> MiraSonnerMessage {
		MiraSonnerMessage(title: title, description: description, style: .rejected)
	}
}

enum MiraSonnerStyle: Equatable {
	case `default`
	case success
	case error
	case warning
	case info
	case connected
	case pending
	case disconnected
	case rejected
}
