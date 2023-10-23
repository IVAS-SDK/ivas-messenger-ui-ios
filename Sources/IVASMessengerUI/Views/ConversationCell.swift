import SwiftUI

@available(iOS 15, *)
struct ConversationCell: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @ObservedObject var conversation: ConversationPreview
    var holder: NavStackHolder

    @StateObject private var viewModel: ViewModel


    var body: some View
    {
        HStack
        {
            Button(
                action: { viewModel.joinConversation(controller: holder.viewController, id: conversation.id) },
                label:
                {
                    HStack
                    {
                        if let avatar = conversation.sentByAvatar
                        {
                            AsyncImage(url: URL(string: avatar))
                            { image in

                                image.resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())

                            } placeholder: {}
                        }
                        else
                        {
                            Image(systemName: "person.circle")
                                .font(.title)
                        }
                        
                        VStack
                        {
                            HStack
                            {
                                Text(viewModel.getName(conversation))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(viewModel.getTimeAgo(conversation.sentAt))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            HStack
                            {
                                Text(conversation.input)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.footnote)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            )
            .tint(.black)
        }
        .onAppear() { viewModel.onAppear() }
        .onDisappear() { viewModel.onDisappear() }
    }

    init(
        config: Configuration,
        engagementManager: EngagementManager,
        conversation: ConversationPreview,
        holder: NavStackHolder
    )
    {
        self.config = config
        self.engagementManager = engagementManager
        self.conversation = conversation
        self.holder = holder

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager))
    }
}
