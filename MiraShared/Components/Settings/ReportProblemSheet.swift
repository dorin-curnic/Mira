import SwiftUI
import UniformTypeIdentifiers

struct ReportProblemSheet: View {
	@Environment(\.dismiss) private var dismiss

	@State private var selectedCategory: ReportCategory = .uiBug
	@State private var description = ""
	@State private var attachmentURLs: [URL] = []
	@State private var isShowingAttachmentImporter = false
	@State private var didTryToSubmit = false

	private var trimmedDescription: String {
		description.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var isDescriptionInvalid: Bool {
		didTryToSubmit && trimmedDescription.isEmpty
	}

	private var canSubmit: Bool {
		!trimmedDescription.isEmpty
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xl) {
					header
					formCard
				}
				.padding(MiraTheme.Spacing.xl)
				.frame(maxWidth: 620)
				.frame(maxWidth: .infinity)
			}
			.background(MiraTheme.ColorToken.background)
			.navigationTitle("Report Form")
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark")
							.fontWeight(.semibold)
					}
					.tint(MiraTheme.ColorToken.foreground)
				}

				ToolbarItem(placement: .confirmationAction) {
					Button {
						submit()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(.semibold)
					}
					.disabled(!canSubmit)
					.tint(MiraTheme.ColorToken.primary)
				}
			}
			.fileImporter(
				isPresented: $isShowingAttachmentImporter,
				allowedContentTypes: [.image, .movie],
				allowsMultipleSelection: true
			) { result in
				switch result {
				case .success(let urls):
					attachmentURLs.append(contentsOf: urls)
				case .failure:
					break
				}
			}
		}
	}

	private var header: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
			Text("Report a Problem")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Text("Describe what happened and attach screenshots or videos if needed.")
				.font(.subheadline)
				.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
		}
	}

	private var formCard: some View {
		MiraCard {
			VStack(alignment: .leading, spacing: MiraTheme.Spacing.lg) {
				categoryField

				Divider()

				descriptionField

				Divider()

				attachmentsField
			}
		}
	}

	private var categoryField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			Text("Category")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Picker("Category", selection: $selectedCategory) {
				ForEach(ReportCategory.allCases) { category in
					Text(category.rawValue)
						.tag(category)
				}
			}
			.pickerStyle(.menu)
			.tint(MiraTheme.ColorToken.primary)
		}
	}

	private var descriptionField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			Text("Description")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			TextEditor(text: $description)
				.frame(minHeight: 140)
				.padding(MiraTheme.Spacing.sm)
				.scrollContentBackground(.hidden)
				.background(MiraTheme.ColorToken.secondary)
				.clipShape(
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
				)
				.overlay {
					RoundedRectangle(
						cornerRadius: MiraTheme.Radius.md,
						style: .continuous
					)
					.stroke(
						isDescriptionInvalid
						? MiraTheme.ColorToken.destructive
						: MiraTheme.ColorToken.border,
						lineWidth: 1
					)
				}

			if isDescriptionInvalid {
				Text("Description is required.")
					.font(.caption)
					.foregroundStyle(MiraTheme.ColorToken.destructive)
			}
		}
	}

	private var attachmentsField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			Text("Attachments")
				.font(.subheadline)
				.fontWeight(.semibold)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

			Button {
				isShowingAttachmentImporter = true
			} label: {
				HStack(spacing: MiraTheme.Spacing.md) {
					Image(systemName: "paperclip")
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text("Add photos or videos")
							.font(.subheadline)
							.fontWeight(.semibold)
							.foregroundStyle(MiraTheme.ColorToken.foreground)

						Text(attachmentSummary)
							.font(.caption)
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
					}

					Spacer()
				}
				.padding(.vertical, MiraTheme.Spacing.sm)
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)

			if !attachmentURLs.isEmpty {
				VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
					ForEach(attachmentURLs, id: \.self) { url in
						Text(url.lastPathComponent)
							.font(.caption)
							.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
							.lineLimit(1)
							.truncationMode(.middle)
					}
				}
			}
		}
	}

	private var attachmentSummary: String {
		if attachmentURLs.isEmpty {
			return "No attachments selected."
		}

		return "\(attachmentURLs.count) attachment(s) selected."
	}

	private func submit() {
		didTryToSubmit = true

		guard canSubmit else {
			return
		}

		// Backend later: send selectedCategory, description, and attachmentURLs.
		dismiss()
	}
}
