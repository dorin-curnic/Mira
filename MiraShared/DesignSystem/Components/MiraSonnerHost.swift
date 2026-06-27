import SwiftUI

struct MiraSonnerHost<Content: View>: View {
	@State private var sonner = MiraSonnerCenter()

	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		content
			.environment(sonner)
			.overlay(alignment: alignment) {
				VStack(spacing: MiraTheme.Spacing.sm) {
					ForEach(sonner.messages) { message in
						MiraSonnerToast(
							message: message,
							onDismiss: {
								sonner.dismiss(message.id)
							},
							onInteractionChanged: { isInteracting in
								sonner.setInteracting(isInteracting, for: message.id)
							}
						)
						.frame(maxWidth: 420)
						.transition(
							.asymmetric(
								insertion: .move(edge: insertionEdge).combined(with: .opacity),
								removal: .opacity.combined(with: .scale(scale: 0.96))
							)
						)
					}
				}
				.padding(.horizontal, MiraTheme.Spacing.md)
				.padding(.vertical, MiraTheme.Spacing.md)
			}
			.animation(.spring(response: 0.32, dampingFraction: 0.88), value: sonner.messages)
	}

	private var alignment: Alignment {
		#if os(macOS)
			return .topTrailing
		#else
			return .bottom
		#endif
	}

	private var insertionEdge: Edge {
		#if os(macOS)
			return .trailing
		#else
			return .bottom
		#endif
	}
}
