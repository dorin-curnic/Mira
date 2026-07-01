import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ReportAttachment: Identifiable, Equatable {
	let id = UUID()
	let url: URL
	var displayName: String
	let fileSizeBytes: Int64

	var fileExtension: String? {
		let pathExtension = url.pathExtension

		return pathExtension.isEmpty
		? nil
		: pathExtension.uppercased()
	}

	var isVideo: Bool {
		Self.videoExtensions.contains(url.pathExtension.lowercased())
	}

	var fileSizeDescription: String {
		ByteCountFormatter.string(
			fromByteCount: fileSizeBytes,
			countStyle: .file
		)
	}

	private static let videoExtensions = Set(["mov", "mp4", "m4v"])

	init(url: URL, fileSizeBytes: Int64) {
		self.url = url
		self.displayName = url.deletingPathExtension().lastPathComponent
		self.fileSizeBytes = fileSizeBytes
	}
}

struct ReportProblemSheet: View {
	@Environment(\.miraLanguage) private var language
	@Environment(\.dismiss) private var dismiss

	@State private var selectedCategory: ReportCategory = .uiBug
	@State private var description = ""
	@State private var attachments: [ReportAttachment] = []
	@State private var isShowingAttachmentImporter = false
	@State private var didTryToSubmit = false
	@State private var attachmentErrorText: String?

	let onSubmit: (Result<Void, Error>) -> Void

	private let maximumAttachmentCount = 5
	private let maximumAttachmentSizeBytes: Int64 = 100 * 1000 * 1000

	private let allowedAttachmentTypes: [UTType] = [
		.png,
		.jpeg,
		.heic,
		.heif,
		.gif,
		.quickTimeMovie,
		.mpeg4Movie,
		.movie,
	]

	init(
		onSubmit: @escaping (Result<Void, Error>) -> Void = { _ in }
	) {
		self.onSubmit = onSubmit
	}

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
					.tint(MiraTheme.ColorToken.primary)
					.accessibilityLabel(MiraText.commonSubmit.localized(language))
				}
			}
			.fileImporter(
				isPresented: $isShowingAttachmentImporter,
				allowedContentTypes: allowedAttachmentTypes,
				allowsMultipleSelection: true
			) { result in
				handleAttachmentImport(result)
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
			errorText: isDescriptionInvalid
			? MiraText.reportDescriptionRequiredError.localized(language) : nil,
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
						.font(MiraTheme.Typography.rowTitle)
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

			if let attachmentErrorText {
				MiraHelperText(attachmentErrorText, tone: .destructive)
			}

			if !attachments.isEmpty {
				VStack(spacing: MiraTheme.Spacing.sm) {
					ForEach($attachments) { $attachment in
						ReportAttachmentRow(
							attachment: $attachment,
							onDelete: {
								deleteAttachment(attachment)
							}
						)
					}
				}
				.padding(.top, MiraTheme.Spacing.xs)
			}
		}
	}

	private var attachmentSummary: String {
		if attachments.isEmpty {
			return MiraText.reportAttachmentsNone.localized(language)
		}

		let format = MiraText.reportAttachmentsSelectedCount.localized(language)
		return String(format: format, attachments.count)
	}

	private func handleAttachmentImport(_ result: Result<[URL], Error>) {
		switch result {
		case .success(let urls):
			addAttachments(urls)

		case .failure(let error):
			if isUserCancelledImport(error) {
				return
			}

			attachmentErrorText = MiraText.reportAttachmentsImportFailed.localized(language)
		}
	}

	private func addAttachments(_ urls: [URL]) {
		attachmentErrorText = nil

		let existingURLs = Set(attachments.map(\.url))
		let newURLs = urls.filter { url in
			!existingURLs.contains(url)
		}

		guard !newURLs.isEmpty else {
			return
		}

		let remainingSlots = maximumAttachmentCount - attachments.count

		guard remainingSlots > 0 else {
			showAttachmentLimitError()
			return
		}

		var acceptedAttachments: [ReportAttachment] = []

		for url in newURLs {
			if acceptedAttachments.count >= remainingSlots {
				showAttachmentLimitError()
				break
			}

			guard isAllowedAttachmentType(url) else {
				showUnsupportedTypeError()
				continue
			}

			guard let fileSizeBytes = fileSizeBytes(for: url) else {
				showAttachmentImportError()
				continue
			}

			guard fileSizeBytes <= maximumAttachmentSizeBytes else {
				showAttachmentSizeError()
				continue
			}

			acceptedAttachments.append(
				ReportAttachment(
					url: url,
					fileSizeBytes: fileSizeBytes
				)
			)
		}

		attachments.append(contentsOf: acceptedAttachments)
	}

	private func deleteAttachment(_ attachment: ReportAttachment) {
		attachments.removeAll { currentAttachment in
			currentAttachment.id == attachment.id
		}

		if attachments.count < maximumAttachmentCount {
			attachmentErrorText = nil
		}
	}

	private func showAttachmentLimitError() {
		attachmentErrorText = MiraText.reportAttachmentsLimitReached.localized(language)
	}

	private func showAttachmentSizeError() {
		let format = MiraText.reportAttachmentsSizeLimitReached.localized(language)
		attachmentErrorText = String(
			format: format,
			ByteCountFormatter.string(
				fromByteCount: maximumAttachmentSizeBytes,
				countStyle: .file
			)
		)
	}

	private func showUnsupportedTypeError() {
		attachmentErrorText = MiraText.reportAttachmentsUnsupportedType.localized(language)
	}

	private func showAttachmentImportError() {
		attachmentErrorText = MiraText.reportAttachmentsImportFailed.localized(language)
	}

	private func isAllowedAttachmentType(_ url: URL) -> Bool {
		let allowedExtensions = Set([
			"png",
			"jpg",
			"jpeg",
			"heic",
			"heif",
			"gif",
			"mov",
			"mp4",
			"m4v",
		])

		return allowedExtensions.contains(url.pathExtension.lowercased())
	}

	private func fileSizeBytes(for url: URL) -> Int64? {
		let didStartAccess = url.startAccessingSecurityScopedResource()

		defer {
			if didStartAccess {
				url.stopAccessingSecurityScopedResource()
			}
		}

		do {
			let values = try url.resourceValues(forKeys: [.fileSizeKey])
			return values.fileSize.map(Int64.init)
		} catch {
			return nil
		}
	}

	private func isUserCancelledImport(_ error: Error) -> Bool {
		let nsError = error as NSError

		return nsError.domain == NSCocoaErrorDomain
		&& nsError.code == NSUserCancelledError
	}

	private func submit() {
		didTryToSubmit = true

		guard canSubmit else {
			return
		}

		onSubmit(.success(()))
		dismiss()
	}
}

private struct ReportAttachmentRow: View {
	@Environment(\.miraLanguage) private var language

	@Binding var attachment: ReportAttachment

	let onDelete: () -> Void

	var body: some View {
		HStack(spacing: MiraTheme.Spacing.md) {
			ReportAttachmentPreview(url: attachment.url, isVideo: attachment.isVideo)
				.frame(width: 58, height: 58)
				.clipShape(RoundedRectangle(cornerRadius: MiraTheme.Radius.md, style: .continuous))

			VStack(alignment: .leading, spacing: MiraTheme.Spacing.xs) {
				TextField(text: $attachment.displayName) {
					Text(verbatim: "Attachment name")
				}
				.textFieldStyle(.plain)
				.font(MiraTheme.Typography.rowTitle)
				.fontWeight(MiraTheme.Typography.rowTitleWeight)
				.foregroundStyle(MiraTheme.ColorToken.foreground)

				Text("\(fileTypeText) • \(attachment.fileSizeDescription)")
					.font(MiraTheme.Typography.rowSubtitle)
					.fontWeight(MiraTheme.Typography.rowSubtitleWeight)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}

			Spacer(minLength: MiraTheme.Spacing.md)

			Button(role: .destructive) {
				onDelete()
			} label: {
				Image(systemName: "xmark")
					.font(MiraTheme.Typography.rowSubtitle)
					.fontWeight(.semibold)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			}
			.buttonStyle(.plain)
		}
		.padding(MiraTheme.Spacing.md)
		.background(MiraTheme.ColorToken.card)
		.clipShape(RoundedRectangle(cornerRadius: MiraTheme.Radius.lg, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: MiraTheme.Radius.lg, style: .continuous)
				.stroke(MiraTheme.ColorToken.border, lineWidth: 1)
		}
	}

	private var fileTypeText: String {
		attachment.fileExtension ?? MiraText.reportAttachmentUnknownType.localized(language)
	}
}

private struct ReportAttachmentPreview: View {
	let url: URL
	let isVideo: Bool

	@State private var thumbnail: PlatformImage?
	@State private var didFinishLoading = false

	var body: some View {
		ZStack {
			MiraTheme.ColorToken.muted

			if let thumbnail {
				platformImage(thumbnail)
					.resizable()
					.scaledToFill()
			} else if didFinishLoading {
				Image(systemName: isVideo ? "film" : "photo")
					.font(.title3)
					.foregroundStyle(MiraTheme.ColorToken.mutedForeground)
			} else {
				ProgressView()
					.controlSize(.small)
			}

			if isVideo {
				Image(systemName: "play.circle.fill")
					.font(.title3)
					.foregroundStyle(.white)
					.shadow(radius: 2)
			}
		}
		.task(id: url) {
			didFinishLoading = false
			thumbnail = await AttachmentThumbnailProvider.thumbnail(for: url)
			didFinishLoading = true
		}
	}

	private func platformImage(_ image: PlatformImage) -> Image {
#if os(iOS)
		return Image(uiImage: image)
#elseif os(macOS)
		return Image(nsImage: image)
#endif
	}
}

#if os(iOS)
private typealias PlatformImage = UIImage
#elseif os(macOS)
private typealias PlatformImage = NSImage
#endif

private enum AttachmentThumbnailProvider {
	static func thumbnail(for url: URL) async -> PlatformImage? {
		await Task.detached(priority: .utility) {
			let didStartAccess = url.startAccessingSecurityScopedResource()
			defer {
				if didStartAccess {
					url.stopAccessingSecurityScopedResource()
				}
			}

			if let image = await imageThumbnail(for: url) {
				return image
			}

			return await videoThumbnail(for: url)
		}.value
	}

	private static func imageThumbnail(for url: URL) -> PlatformImage? {
#if os(iOS)
		return UIImage(contentsOfFile: url.path)
#elseif os(macOS)
		return NSImage(contentsOf: url)
#endif
	}

	private static func videoThumbnail(for url: URL) async -> PlatformImage? {
		let asset = AVURLAsset(url: url)
		let generator = AVAssetImageGenerator(asset: asset)
		generator.appliesPreferredTrackTransform = true
		generator.maximumSize = CGSize(width: 160, height: 160)

		do {
			let result = try await generator.image(
				at: CMTime(seconds: 0.1, preferredTimescale: 600)
			)

			let cgImage = result.image

#if os(iOS)
			return UIImage(cgImage: cgImage as! CGImage)
#elseif os(macOS)
			return NSImage(
				cgImage: cgImage ,
				size: NSSize(width: cgImage.width, height: cgImage.height)
			)
#endif
		} catch {
			return nil
		}
	}
}
