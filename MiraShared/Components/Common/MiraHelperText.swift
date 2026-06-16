import SwiftUI

struct MiraHelperText: View {
	enum Tone {
		case muted
		case destructive
	}

	let text: String
	let tone: Tone

	init(_ text: String, tone: Tone = .muted) {
		self.text = text
		self.tone = tone
	}

	private var color: Color {
		switch tone {
		case .muted:
			return MiraTheme.ColorToken.mutedForeground
		case .destructive:
			return MiraTheme.ColorToken.destructive
		}
	}

	var body: some View {
		Text(text)
			.font(MiraTheme.Typography.rowSubtitle)
			.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
			.foregroundStyle(color)
	}
}
