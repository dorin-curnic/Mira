import SwiftUI

extension View {
	func disableAnimations() -> some View {
		transaction { transaction in
			transaction.animation = nil
		}
	}
}
