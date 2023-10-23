@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class ConversationListViewModelTests: XCTestCase
{
    var viewModel: ConversationListView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ConversationListView.ViewModel(manager: manager)
    }

    func testOnAppearRegistersEventHandlers()
    {
        viewModel.eventHandlers = []

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 1)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneGettingPaginatedConversations)
    }

    func testOnAppearDoesNotReRegisterEventHandlers()
    {
        XCTAssertEqual(viewModel.eventHandlers.count, 1)

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 1)
    }

    func testEventHandlerSetsExpectedData()
    {
        let rows = [Conversation(
            _id: "id",
            lastMessage: AddConversationEventResponse(
                _id: "",
                conversationId: "",
                input: "",
                sentAt: TimeInterval(),
                sentBy: Participant(accountNumber: 0, apiName: "", userId: "")
            ),
            participants: [],
            participantsData: [:],
            startedAt: 1,
            startedBy: ""
        )]
        let response = GetPaginatedConversationsResponse(page: 1, rows: rows, total: 1, totalPages: 2)
        let handler = manager.registeredHandlers.first?.1 as? (GetPaginatedConversationsResponse) -> Void

        handler?(response)

        XCTAssertEqual(viewModel.paginationData.currentPage, 1)
        XCTAssertTrue(viewModel.paginationData.pagesRemaining)
        XCTAssertEqual(viewModel.conversationList, rows)
    }

    func testOnDisappearSetsExpectedDataWhenOnConversationListScreen()
    {
        manager.currentScreen = .conversationList
        viewModel.conversationList = [Conversation(
            _id: "id",
            lastMessage: AddConversationEventResponse(
                _id: "",
                conversationId: "",
                input: "",
                sentAt: TimeInterval(),
                sentBy: Participant(accountNumber: 0, apiName: "", userId: "")
            ),
            participants: [],
            participantsData: [:],
            startedAt: 1,
            startedBy: ""
        )]

        viewModel.onDisappear()

        XCTAssertEqual(viewModel.eventHandlers.count, 0)
        XCTAssertEqual(viewModel.conversationList, [])
        XCTAssertEqual(manager.currentScreen, .landing)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 1)
    }

    func testOnDisappearSetsExpectedDataWhenNotOnConversationListScreen()
    {
        manager.currentScreen = .baseApp
        viewModel.conversationList = [Conversation(
            _id: "id",
            lastMessage: AddConversationEventResponse(
                _id: "",
                conversationId: "",
                input: "",
                sentAt: TimeInterval(),
                sentBy: Participant(accountNumber: 0, apiName: "", userId: "")
            ),
            participants: [],
            participantsData: [:],
            startedAt: 1,
            startedBy: ""
        )]

        viewModel.onDisappear()

        XCTAssertEqual(viewModel.eventHandlers.count, 0)
        XCTAssertEqual(viewModel.conversationList, [])
        XCTAssertEqual(manager.currentScreen, .baseApp)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 1)
    }
}
