import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack(spacing: 16) {
			Text("Mira")
				.font(.largeTitle)
				.fontWeight(.bold)

			Text("University Wi-Fi authentication helper")
				.foregroundStyle(.secondary)

			Button("Test App") {
				print("Mira is running")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
		.frame(minWidth: 320, minHeight: 220)
	}
}

#Preview {
	ContentView()
}
