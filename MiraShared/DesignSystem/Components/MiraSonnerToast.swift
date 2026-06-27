import SwiftUI

struct MiraSonnerToast: View {
	@Environment(\.miraLanguage) private var language

	let message: MiraSonnerMessage
	let onDismiss: () -> Void
	let onInteractionChanged: (Bool) -> Void

	@State private var dragOffset: CGSize = .zero

	var body: some View {
		HStack(alignment: .center, spacing: MiraTheme.Spacing.sm) {
			Image(systemName: iconName)
				.font(MiraTheme.Typography.rowIcon)
				.fontWeight(MiraTheme.Typography.rowTitleWeight)
				.foregroundStyle(foregroundColor)

			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				Text(message.title)
					.font(MiraTheme.Typography.rowTitle)
					.fontWeight(MiraTheme.Typography.rowTitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.foreground)
					.lineLimit(1)

				if let description = message.description {
					Text(description)
						.font(MiraTheme.Typography.rowSubtitle)
						.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
						.fixedSize(horizontal: false, vertical: true)
						.lineLimit(1)
				}
			}

			Spacer(minLength: MiraTheme.Spacing.sm)

			Button(action: onDismiss) {
				Image(systemName: "xmark")
					.font(MiraTheme.Typography.badge)
					.fontWeight(MiraTheme.Typography.badgeWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
			.buttonStyle(.plain)
			.accessibilityLabel(MiraText.dismiss.localized(language))
		}
		.padding(.horizontal, MiraTheme.Spacing.md)
		.padding(.vertical, MiraTheme.Spacing.sm)
		.frame(height: 60)
		.background(background)
		.overlay {
			RoundedRectangle(cornerRadius: MiraTheme.Radius.md, style: .continuous)
				.strokeBorder(borderColor.opacity(0.05), lineWidth: 1)
		}
		.clipShape(RoundedRectangle(cornerRadius: MiraTheme.Radius.md, style: .continuous))
		.shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
		.offset(dragOffset)
		.opacity(dragOpacity)
		.gesture(dismissGesture)
	}

	private var background: some ShapeStyle {
		#if os(iOS)
			return .regularMaterial
		#else
			return .thinMaterial
		#endif
	}

	private var iconName: String {
		switch message.style {
		case .default:
			return "bell.fill"
		case .success, .connected:
			return "checkmark.circle.fill"
		case .error, .disconnected:
			return "xmark.octagon.fill"
		case .warning, .pending:
			return "exclamationmark.triangle.fill"
		case .info:
			return "info.circle.fill"
		case .rejected:
			return "hand.raised.fill"
		}
	}

	private var foregroundColor: Color {
		switch message.style {
		case .default:
			return MiraTheme.ColorToken.foreground
		case .success, .connected:
			return MiraTheme.Status.connectedForeground
		case .error, .rejected:
			return MiraTheme.Status.rejectedForeground
		case .warning, .pending:
			return MiraTheme.Status.pendingForeground
		case .info:
			return MiraTheme.Status.infoForeground
		case .disconnected:
			return MiraTheme.Status.disconnectedForeground
		}
	}

	private var borderColor: Color {
		switch message.style {
		case .default:
			return MiraTheme.ColorToken.border
		case .success, .connected:
			return MiraTheme.Status.connectedBorder
		case .error, .rejected:
			return MiraTheme.Status.rejectedBorder
		case .warning, .pending:
			return MiraTheme.Status.pendingBorder
		case .info:
			return MiraTheme.Status.infoBorder
		case .disconnected:
			return MiraTheme.Status.disconnectedBorder
		}
	}

	private var dismissGesture: some Gesture {
		DragGesture(minimumDistance: 8)
			.onChanged { value in
				onInteractionChanged(true)

				dragOffset = limitedOffset(for: value.translation)
			}
			.onEnded { value in
				let shouldDismiss = value.translation.height > 48

				if shouldDismiss {
					onDismiss()
					return
				}

				withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
					dragOffset = .zero
				}

				onInteractionChanged(false)
			}
	}

	private func limitedOffset(for translation: CGSize) -> CGSize {
		CGSize(
			width: 0,
			height: max(0, translation.height)
		)
	}

	private var dragOpacity: Double {
		let distance = dragOffset.height
		return max(0.55, 1 - Double(distance / 180))
	}
}
