import Foundation
import Observation

@MainActor
@Observable
final class MiraSonnerCenter {
    private(set) var messages: [MiraSonnerMessage] = []

    private let maximumVisibleMessages = 3
    private var dismissalTokens: [MiraSonnerMessage.ID: UUID] = [:]
    private var interactingMessageIDs: Set<MiraSonnerMessage.ID> = []

    func show(_ message: MiraSonnerMessage) {
        messages.append(message)

        if messages.count > maximumVisibleMessages {
            let removedMessages = messages.prefix(messages.count - maximumVisibleMessages)

            for message in removedMessages {
                dismissalTokens[message.id] = nil
                interactingMessageIDs.remove(message.id)
            }

            messages.removeFirst(messages.count - maximumVisibleMessages)
        }

        scheduleDismiss(for: message)
    }

    func dismiss(_ id: MiraSonnerMessage.ID) {
        dismissalTokens[id] = nil
        interactingMessageIDs.remove(id)
        messages.removeAll { $0.id == id }
    }

    func dismissAll() {
        dismissalTokens.removeAll()
        interactingMessageIDs.removeAll()
        messages.removeAll()
    }

    func setInteracting(_ isInteracting: Bool, for id: MiraSonnerMessage.ID) {
        if isInteracting {
            let wasEmpty = interactingMessageIDs.isEmpty
            interactingMessageIDs.insert(id)

            if wasEmpty {
                invalidateDismissTimers()
            }

            return
        }

        interactingMessageIDs.remove(id)

        if interactingMessageIDs.isEmpty {
            restartDismissTimers()
        }
    }

    private func scheduleDismiss(
        for message: MiraSonnerMessage,
        additionalDelay: Duration = .zero
    ) {
        guard let duration = message.duration else {
            return
        }

        let token = UUID()
        dismissalTokens[message.id] = token

        Task { [weak self] in
            try? await Task.sleep(for: duration + additionalDelay)
            self?.dismissIfTokenIsCurrent(message.id, token: token)
        }
    }

    private func dismissIfTokenIsCurrent(
        _ id: MiraSonnerMessage.ID,
        token: UUID
    ) {
        guard dismissalTokens[id] == token else {
            return
        }

        guard interactingMessageIDs.isEmpty else {
            return
        }

        dismiss(id)
    }

    private func invalidateDismissTimers() {
        for message in messages {
            dismissalTokens[message.id] = UUID()
        }
    }

    private func restartDismissTimers() {
        for (index, message) in messages.enumerated() {
            scheduleDismiss(for: message, additionalDelay: .milliseconds(index * 450))
        }
    }
}
