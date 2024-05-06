import SwiftUI

@available(iOS 15, *)
struct ConversationListView: ViewControllable
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    var holder = NavStackHolder()

    var body: some View
    {
        ZStack
        {
            engagementManager.settings?.backgroundColorPrimary.ignoresSafeArea()
            VStack
            {
                VStack
                {
                    Rectangle()
                        .fill(engagementManager.settings?.backgroundColorPrimary ?? .black)
                        .frame(height: 1)
                    List
                    {
                        if viewModel.conversationList.isEmpty
                        {
                            LoadingView()
                                .id(UUID())
                        }
                        else
                        {
                            ForEach(viewModel.conversationList)
                            { conversation in

                                VStack
                                {
                                    ConversationCell(
                                        config: config,
                                        engagementManager: engagementManager,
                                        conversation: ConversationPreview(
                                            id: conversation.id,
                                            input: conversation.lastMessage.input,
                                            sentAt: conversation.lastMessage.sentAt,
                                            sentByAvatar: conversation.participantsData[conversation.lastMessage.sentBy.userId!]?.avatar,
                                            sentByName: conversation.participantsData[conversation.lastMessage.sentBy.userId!]?.name,
                                            sentByUserId: conversation.lastMessage.sentBy.userId
                                        ),
                                        holder: holder
                                    )

                                    if viewModel.paginationData.pagesRemaining &&
                                        viewModel.conversationList.last == conversation
                                    {
                                        LoadingView()
                                        .onAppear
                                        {
                                            viewModel.loadNextPage()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .handleSocketSceneChange(engagementManager: engagementManager)
        .onAppear() { viewModel.onAppear() }
        .onDisappear() { viewModel.onDisappear() }
        .onChange(of: engagementManager.currentScreen) { viewModel.onScreenChange($0) }
        .toolbar
        {
            ToolbarItem(placement: .principal)
            {
                Text(
                    "ivas.conversationList.title",
                    bundle: engagementManager.localizationBundle
                )
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing)
            {
                CloseButton(engagementManager: engagementManager, viewController: holder.viewController)
            }
        }
    }

    init(config: Configuration, engagementManager: EngagementManager)
    {
        self.config = config
        self.engagementManager = engagementManager

        _viewModel = StateObject(wrappedValue: ViewModel(manager: engagementManager))
    }
}
