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
			MiraSheetContainer(maxWidth: MiraTheme.Layout.reportSheetMaxWidth) {
				header
				formCard
			}
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
							.fontWeight(MiraTheme.Typography.buttonWeight)
					}
					.tint(MiraTheme.ColorToken.foreground)
				}

				ToolbarItem(placement: .confirmationAction) {
					Button {
						submit()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(MiraTheme.Typography.buttonWeight)
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
		MiraPageHeader(
			"Report a Problem",
			subtitle: "Describe what happened and attach screenshots or videos if needed."
		)
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
			MiraFieldLabel("Category")

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
		MiraTextEditorField(
			label: "Description",
			placeholder: "Describe what happened...",
			text: $description,
			errorText: isDescriptionInvalid ? "Description is required." : nil,
			minHeight: 140
		)
	}

	private var attachmentsField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			MiraFieldLabel("Attachments")

			Button {
				isShowingAttachmentImporter = true
			} label: {
				HStack(spacing: MiraTheme.Spacing.md) {
					Image(systemName: "paperclip")
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text("Add photos or videos")
							.font(MiraTheme.Typography.rowTitle)
							.fontWeight(MiraTheme.Typography.rowTitleWeight)
							.foregroundStyle(MiraTheme.ColorToken.foreground)

						MiraHelperText(attachmentSummary)
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
							.font(MiraTheme.Typography.rowSubtitle)
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
	}
}
