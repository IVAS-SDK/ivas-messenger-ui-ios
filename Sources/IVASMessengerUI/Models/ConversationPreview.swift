import Foundation

class ConversationPreview: ObservableObject
{
    @Published var id: String
    @Published var input: String
    @Published var sentAt: TimeInterval
    @Published var sentByAvatar: String?
    @Published var sentByName: String?
    @Published var sentByUserId: String?

    init(
        id: String,
        input: String,
        sentAt: TimeInterval,
        sentByAvatar: String?,
        sentByName: String?,
        sentByUserId: String?
    )
    {
        self.id = id
        self.input = input
        self.sentAt = sentAt
        self.sentByAvatar = sentByAvatar
        self.sentByName = sentByName
        self.sentByUserId = sentByUserId
    }
}
