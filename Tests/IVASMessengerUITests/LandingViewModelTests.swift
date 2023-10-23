@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class LandingViewModelTests: XCTestCase
{
    var viewModel: LandingView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = LandingView.ViewModel(
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

    func testOnFirstAppearPerformsLaunchAction()
    {
        let navController = MockNavigationController()
        let vc = MockViewController()
        vc.navigationController = navController
        viewModel.config.launchAction = LaunchAction(preformedInput: "hey")

        viewModel.onFirstAppear(controller: vc)

        XCTAssertNotNil(navController.pushedController)
        XCTAssertTrue(navController.animated!)
        XCTAssertTrue(viewModel.pushToConversation)
    }

    func testOnFirstAppearDoesNotPerformLaunchActionWhenNoController()
    {
        viewModel.config.launchAction = LaunchAction(preformedInput: "hey")

        viewModel.onFirstAppear(controller: nil)

        XCTAssertFalse(viewModel.pushToConversation)
    }

    func testOnFirstAppearDoesNotPerformLaunchActionWhenShouldPerformFalse()
    {
        let testCases = [
            nil,
            LaunchAction(),
            LaunchAction(preformedInput: "")
        ]

        for launchAction in testCases
        {
            XCTContext.runActivity(named: "Launch Action:\(String(describing: launchAction))")
            { _ in

                let navController = MockNavigationController()
                let vc = MockViewController()
                vc.navigationController = navController
                viewModel.config.launchAction = launchAction

                viewModel.onFirstAppear(controller: vc)

                XCTAssertNil(navController.pushedController)
                XCTAssertNil(navController.animated)
                XCTAssertFalse(viewModel.pushToConversation)
            }
        }
    }

    func testOnDisappearSetsExpectedWhenPushing()
    {
        manager.currentScreen = .baseApp
        viewModel.pushToConversation = true

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .conversation)
    }

    func testOnDisappearSetsExpectedWhenOnLandingScreen()
    {
        manager.currentScreen = .landing
        viewModel.pushToConversation = false

        viewModel.onDisappear()

        XCTAssertEqual(manager.currentScreen, .baseApp)
    }
}
