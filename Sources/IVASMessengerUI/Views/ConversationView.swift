import SwiftUI

@available(iOS 15, *)
struct ConversationView: ViewControllable
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    @State private var scrollOffset = CGPoint()
    @State private var viewsAppeared = false
    var holder = NavStackHolder()


    var body: some View
    {
        ZStack
        {
            engagementManager.settings?.backgroundColorPrimary.ignoresSafeArea()
            VStack(spacing: 0)
            {
                VStack
                {
                    Rectangle()
                        .fill(engagementManager.settings?.backgroundColorPrimary ?? .black)
                        .frame(height: 1)
                    ZStack
                    {
                        Color(hex: "#fafafa")
                        if viewModel.conversationId == nil && !viewModel.shouldPerformLaunchAction(config: config)
                        {
                            VStack
                            {
                                if let initialMessage = engagementManager.settings?.newConversationPlaceholder?.code?.html?.initialMessage
                                {
                                    Text(initialMessage)
                                        .foregroundColor(Color(hex: "#737376"))
                                        .padding()
                                }
                                Spacer()
                                if let options = engagementManager.settings?.newConversationPlaceholder?.code?.html?.options, !options.isEmpty
                                {
                                    ChipCollectionView(
                                        config: config,
                                        engagementManager: engagementManager,
                                        options: options.map({
                                            ChipOption(displayText: $0.displayText, directIntentHit: $0.directIntentHit, text: $0.text)
                                        }),
                                        conversationId: nil
                                    )
                                    .padding()
                                }
                            }
                        }
                        else
                        {
                            ScrollViewReader
                            { scrollView in

                                OffsetObservingScrollView(offset: $scrollOffset)
                                {

                                    LazyVStack
                                    {
                                        ForEach(viewModel.conversationHistory)
                                        { event in

                                            ConversationEventView(
                                                config: config,
                                                engagementManager: engagementManager,
                                                event: event,
                                                showLoadingIndicator: viewModel.paginationData.pagesRemaining &&
                                                                        viewModel.conversationHistory.first == event,
                                                isLast: viewModel.conversationHistory.last == event
                                            )
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                    }
                                    .onChange(of: viewModel.conversationHistory)
                                    { _ in

                                        viewModel.scroll()
                                    }
                                    .onChange(of: scrollOffset)
                                    { newScrollOffset in

                                        viewModel.setScrollOffset(newScrollOffset)
                                    }
                                }
                                .onAppear
                                {
                                    viewModel.setScrollView(scrollView)
                                    viewModel.performLaunchAction(config: config)
                                }
                            }
                        }
                    }
                }
                Divider()
                    .overlay(.gray)
                InputBox(config: config, engagementManager: engagementManager, conversationId: viewModel.conversationId)
            }
        }
        .handleSocketSceneChange(engagementManager: engagementManager)
        .onAppear() { viewModel.onAppear() }
        .onDisappear() { viewModel.onDisappear() }
        .onChange(of: viewsAppeared) { _ in viewModel.onViewsAppearedChange() }
        .onChange(of: engagementManager.settings) { _ in viewModel.performLaunchAction(config: config) }
        .toolbar
        {
            ToolbarItem(placement: .principal)
            {
                ParticipantsView(
                    engagementManager: engagementManager,
                    hasAppeared: $viewsAppeared,
                    isNewConversation: viewModel.conversationId == nil
                )
            }
            ToolbarItem(placement: .navigationBarTrailing)
            {
                CloseButton(engagementManager: engagementManager, viewController: holder.viewController)
            }
        }
    }

    init(config: Configuration, engagementManager: EngagementManager, previousScreen: Screen, conversationId: String? = nil)
    {
        self.config = config
        self.engagementManager = engagementManager

        _viewModel = StateObject(
            wrappedValue: ViewModel(
                manager: engagementManager,
                previousScreen: previousScreen,
                conversationId: conversationId
            )
        )
    }
}
