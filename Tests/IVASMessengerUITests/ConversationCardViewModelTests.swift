@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class ConversationCardViewModelTests: XCTestCase
{
    var viewModel: ConversationCard.ViewModel!
    var manager: EngagementManagerMock!


    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ConversationCard.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager
        )
    }

    func testOnAppearSetsPushToConversationToFalse()
    {
        viewModel.pushToConversation = true

        viewModel.onAppear()

        XCTAssertFalse(viewModel.pushToConversation)
    }

    func testOnDisappearSetsCurrentScreen()
    {
        manager.currentScreen = .baseApp
        viewModel.pushToConversation = true

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .conversation)
    }

    func testOnDisappearDoesNotSetCurrentScreen()
    {
        manager.currentScreen = .baseApp
        viewModel.pushToConversation = false

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .baseApp)
    }

    func testStartNewConversationCallsPushViewController()
    {
        let navController = MockNavigationController()
        let vc = MockViewController()
        vc.navigationController = navController

        viewModel.startNewConversation(controller: vc)

        XCTAssertNotNil(navController.pushedController)
        XCTAssertTrue(navController.animated!)
        XCTAssertTrue(viewModel.pushToConversation)
    }

    func testStartNewConversationDoesNotCallPushViewController()
    {
        viewModel.startNewConversation(controller: nil)

        XCTAssertFalse(viewModel.pushToConversation)
    }
}
