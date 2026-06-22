import SwiftUI
import UniformTypeIdentifiers

struct ReportProblemSheet: View {
	@Environment(\.miraLanguage) private var language
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
			.navigationTitle(MiraText.reportFormTitle.localized(language))
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
					.accessibilityLabel(MiraText.commonClose.localized(language))
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
					.accessibilityLabel(MiraText.commonSubmit.localized(language))
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
			MiraText.reportTitle.localized(language),
			subtitle: MiraText.reportSubtitle.localized(language)
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
			MiraFieldLabel(MiraText.reportCategory.localized(language))

			Picker(MiraText.reportCategory.localized(language), selection: $selectedCategory) {
				ForEach(ReportCategory.allCases) { category in
					Text(category.titleText.localized(language))
						.tag(category)
				}
			}
			.pickerStyle(.menu)
			.tint(MiraTheme.ColorToken.primary)
		}
	}

	private var descriptionField: some View {
		MiraTextEditorField(
			label: MiraText.reportDescription.localized(language),
			placeholder: MiraText.reportDescriptionPlaceholder.localized(language),
			text: $description,
			errorText: isDescriptionInvalid ? MiraText.reportDescriptionRequiredError.localized(language) : nil,
			minHeight: 140
		)
	}

	private var attachmentsField: some View {
		VStack(alignment: .leading, spacing: MiraTheme.Spacing.sm) {
			MiraFieldLabel(MiraText.reportAttachments.localized(language))

			Button {
				isShowingAttachmentImporter = true
			} label: {
				HStack(spacing: MiraTheme.Spacing.md) {
					Image(systemName: "paperclip")
						.foregroundStyle(MiraTheme.ColorToken.mutedForeground)

					VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
						Text(MiraText.reportAttachmentsAdd.localized(language))
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
			return MiraText.reportAttachmentsNone.localized(language)
		}

		return "\(attachmentURLs.count)" + MiraText.reportAttachmentsSelectedCount.localized(language)
	}

	private func submit() {
		didTryToSubmit = true

		guard canSubmit else {
			return
		}
	}
}
