@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class ConversationCellViewModelTests: XCTestCase
{
    var viewModel: ConversationCell.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ConversationCell.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager
        )
    }

    func testOnAppearSetsExpected()
    {
        viewModel.pushToConversation = true

        viewModel.onAppear()

        XCTAssertFalse(viewModel.pushToConversation)
    }

    func testOnDisappearSetsExpectedWhenPushing()
    {
        manager.currentScreen = .baseApp
        viewModel.pushToConversation = true

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .conversation)
    }

    func testOnDisappearBailsWhenNotPushing()
    {
        manager.currentScreen = .baseApp
        viewModel.pushToConversation = false

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .baseApp)
    }

    func testJoinConversationCallsPushViewController()
    {
        let navController = MockNavigationController()
        let vc = MockViewController()
        vc.navigationController = navController

        viewModel.joinConversation(controller: vc, id: "")

        XCTAssertNotNil(navController.pushedController)
        XCTAssertTrue(navController.animated!)
        XCTAssertTrue(viewModel.pushToConversation)
    }

    func testJoinConversationDoesNotCallPushViewController()
    {
        viewModel.joinConversation(controller: nil, id: "")

        XCTAssertFalse(viewModel.pushToConversation)
    }

    func testGetNameReturnsBundleName()
    {
        let conversation = ConversationPreview(
            id: "",
            input: "",
            sentAt: TimeInterval(),
            sentByAvatar: "",
            sentByName: "sent",
            sentByUserId: "id"
        )
        manager.userId = "id"

        let result = viewModel.getName(conversation)

        XCTAssertEqual(result, "ivas.conversationList.userName")
    }

    func testGetNameReturnsSentByName()
    {
        let conversation = ConversationPreview(
            id: "",
            input: "",
            sentAt: TimeInterval(),
            sentByAvatar: "",
            sentByName: "sent",
            sentByUserId: "id"
        )
        manager.userId = "nope"

        let result = viewModel.getName(conversation)

        XCTAssertEqual(result, "sent")
    }
}
