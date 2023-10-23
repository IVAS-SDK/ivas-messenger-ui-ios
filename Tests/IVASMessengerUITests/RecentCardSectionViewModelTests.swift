@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class RecentCardSectionViewModelTests: XCTestCase
{
    var viewModel: RecentCardSection.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = RecentCardSection.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager
        )
    }

    func testOnAppearRegistersEventHandlers()
    {
        viewModel.eventHandlers = []
        viewModel.pushToConversationList = true

        viewModel.onAppear()

        XCTAssertFalse(viewModel.pushToConversationList)
        XCTAssertEqual(viewModel.eventHandlers.count, 1)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneGettingPaginatedConversations)
    }

    func testOnAppearDoesNotRegisterEventHandlers()
    {
        viewModel.pushToConversationList = true

        viewModel.onAppear()

        XCTAssertFalse(viewModel.pushToConversationList)
        XCTAssertEqual(viewModel.eventHandlers.count, 1)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneGettingPaginatedConversations)
    }

    func testEventHandlerSetsExpectedData()
    {
        let expectedSentAt = TimeInterval()
        let rows = [Conversation(
            _id: "id",
            lastMessage: AddConversationEventResponse(
                _id: "",
                conversationId: "",
                input: "i",
                sentAt: expectedSentAt,
                sentBy: Participant(accountNumber: 0, apiName: "", name: "n", userId: "u")
            ),
            participants: [],
            participantsData: [:],
            startedAt: 1,
            startedBy: ""
        )]
        let response = GetPaginatedConversationsResponse(page: 1, rows: rows, total: 1, totalPages: 2)
        let handler = manager.registeredHandlers.first?.1 as? (GetPaginatedConversationsResponse) -> Void

        handler?(response)

        XCTAssertEqual(viewModel.recentConversation?.id, "id")
        XCTAssertEqual(viewModel.recentConversation?.input, "i")
        XCTAssertEqual(viewModel.recentConversation?.sentAt, expectedSentAt)
        XCTAssertEqual(viewModel.recentConversation?.sentByName, "n")
        XCTAssertEqual(viewModel.recentConversation?.sentByUserId, "u")
    }

    func testOnFirstAppearRefreshesConversationWhenAuthenticated()
    {
        viewModel.eventHandlers = []
        manager.isAuthenticated = true

        viewModel.onFirstAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 1)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneGettingPaginatedConversations)
        XCTAssertEqual(manager.emittedEvents.first?.0, .getPaginatedConversations)
        XCTAssertEqual(manager.emittedEvents.first?.1.count, 1)
    }

    func testOnFirstAppearDoesNotRefreshesConversationWhenNotAuthenticated()
    {
        viewModel.eventHandlers = []
        manager.isAuthenticated = false

        viewModel.onFirstAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 1)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneGettingPaginatedConversations)
        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testOnDisappearSetsExpectedStateWhenPushingToConvoList()
    {
        viewModel.pushToConversationList = true
        manager.currentScreen = .baseApp

        viewModel.onDisappear()

        XCTAssertTrue(viewModel.eventHandlers.isEmpty)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 1)
        XCTAssertEqual(manager.currentScreen, .conversationList)
    }

    func testOnDisappearSetsExpectedStateWhenNotPushingToConvoList()
    {
        viewModel.pushToConversationList = false
        manager.currentScreen = .baseApp

        viewModel.onDisappear()

        XCTAssertTrue(viewModel.eventHandlers.isEmpty)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 1)
        XCTAssertEqual(manager.currentScreen, .baseApp)
    }

    func testOnAuthChangeRefreshesConvo()
    {
        manager.isAuthenticated = true

        viewModel.onAuthChange(true)

        XCTAssertEqual(manager.emittedEvents.first?.0, .getPaginatedConversations)
        XCTAssertEqual(manager.emittedEvents.first?.1.count, 1)
    }

    func testOnScreenChangeRefreshesConvoWhenScreenIsLanding()
    {
        manager.isAuthenticated = true

        viewModel.onScreenChange(.landing)

        XCTAssertEqual(manager.emittedEvents.first?.0, .getPaginatedConversations)
        XCTAssertEqual(manager.emittedEvents.first?.1.count, 1)
    }

    func testOnScreenChangeDoesNotRefresheConvoWhenScreenIsNotLanding()
    {
        manager.isAuthenticated = true

        viewModel.onScreenChange(.baseApp)

        XCTAssertTrue(manager.emittedEvents.isEmpty)
    }

    func testShowConversationListCallsPushViewController()
    {
        let navController = MockNavigationController()
        let vc = MockViewController()
        vc.navigationController = navController

        viewModel.showConversationList(controller: vc)

        XCTAssertNotNil(navController.pushedController)
        XCTAssertTrue(navController.animated!)
        XCTAssertTrue(viewModel.pushToConversationList)
    }

    func testShowConversationListDoesNotCallPushViewController()
    {
        viewModel.showConversationList(controller: nil)

        XCTAssertFalse(viewModel.pushToConversationList)
    }
}
