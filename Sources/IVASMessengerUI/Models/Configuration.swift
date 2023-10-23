import Foundation

public class Configuration: ObservableObject
{
    @Published public var launchAction: LaunchAction?
    @Published public var options: ConfigOptions
    @Published public var metadata: ConversationEventMetadata?
    @Published public var conversationEventHandler: ((AddConversationEventResponse) -> ())?

    public init(
        launchAction: LaunchAction? = nil,
        options: ConfigOptions,
        metadata: ConversationEventMetadata? = nil,
        conversationEventHandler: ((AddConversationEventResponse) -> ())? = nil
    )
    {
        self.launchAction = launchAction
        self.options = options
        self.metadata = metadata
        self.conversationEventHandler = conversationEventHandler
    }
}
