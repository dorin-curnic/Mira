import SwiftUI

struct MiraGlassCopyButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			configuration.label
				.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
				.glassEffect(.regular.interactive(), in: Capsule())
				.overlay {
					Capsule()
						.strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
				}
				.shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
		} else {
			configuration.label
				.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
				.background {
					Capsule()
						.fill(.regularMaterial)
						.overlay {
							Capsule()
								.strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
						}
						.shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
				}
		}
	}
}

extension ButtonStyle where Self == MiraGlassCopyButtonStyle {
	static var miraGlassCopy: MiraGlassCopyButtonStyle {
		MiraGlassCopyButtonStyle()
	}
}
