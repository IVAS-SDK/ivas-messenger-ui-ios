@testable import IVASMessengerUI
import XCTest
import SwiftUI

@available(iOS 15, *)
@MainActor class ConversationViewModelTests: XCTestCase
{
    var viewModel: ConversationView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ConversationView.ViewModel(
            manager: manager,
            previousScreen: .conversationList,
            conversationId: "convoId"
        )
    }

    func testOnAppearRegistersEventHandlers()
    {
        viewModel.eventHandlers = []

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 3)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneAddingConversationEvent)
        XCTAssertEqual(manager.registeredHandlers[1].0, .doneGettingPaginatedConversationEvents)
        XCTAssertEqual(manager.registeredHandlers[2].0, .isTyping)
    }

    func testOnAppearDoesNotReRegisterEventHandlers()
    {
        XCTAssertEqual(viewModel.eventHandlers.count, 3)

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 3)
    }

    func testAddConversationEventHandlerSetsExpectedData()
    {
        let participant = Participant(accountNumber: 1, apiName: "", userId: "")
        let sentAt = TimeInterval()
        let expected = ConversationEvent(
            conversationId: "convoId",
            id: "id",
            input: "i",
            metadata: ["temp": "t"],
            options: [ChipOption(displayText: "d", directIntentHit: "i", text: "t")],
            sentAt: sentAt,
            sentBy: participant
        )
        let response = AddConversationEventResponse(
            _id: "id",
            conversationId: "convoId",
            input: "i",
            metadata: ["temp": "t"],
            options: [Option(directIntentHit: "i", displayText: "d", text: "t")],
            sentAt: sentAt,
            sentBy: participant
        )
        let handler = manager.registeredHandlers.first?.1 as? (AddConversationEventResponse) -> Void

        handler?(response)

        XCTAssertTrue(viewModel.doneAppendingToBottom)
        XCTAssertEqual(viewModel.paginationData.skipCounter, 1)
        XCTAssertEqual(viewModel.conversationId, "convoId")
        XCTAssertEqual(viewModel.conversationHistory, [expected])
    }

    func testGetPaginatedEventHandlerSetsExpectedData()
    {
        let participant = Participant(accountNumber: 1, apiName: "", userId: "")
        let sentAt = TimeInterval()
        let expected = ConversationEvent(
            conversationId: "convoId",
            id: "id",
            input: "i",
            metadata: ["temp": "t"],
            options: [ChipOption(displayText: "d", directIntentHit: "i", text: "t")],
            sentAt: sentAt,
            sentBy: participant
        )
        let convoResponse = AddConversationEventResponse(
            _id: "id",
            conversationId: "convoId",
            input: "i",
            metadata: ["temp": "t"],
            options: [Option(directIntentHit: "i", displayText: "d", text: "t")],
            sentAt: sentAt,
            sentBy: participant
        )
        let conversation = Conversation(
            _id: "id",
            lastMessage: convoResponse,
            participants: [],
            participantsData: [:],
            startedAt: 1,
            startedBy: ""
        )
        let response = GetPaginatedConversationEventsResponse(
            conversation: conversation,
            page: 1,
            rows: [convoResponse],
            total: 1,
            totalPages: 1
        )
        viewModel.conversationHistory = [
            ConversationEvent(
                conversationId: "convoId",
                id: "id2",
                input: "i2",
                options: [ChipOption(displayText: "d", directIntentHit: "i", text: "t")],
                sentAt: sentAt,
                sentBy: participant
            )
        ]
        let handler = manager.registeredHandlers[1].1 as? (GetPaginatedConversationEventsResponse) -> Void

        handler?(response)

        XCTAssertEqual(viewModel.paginationData.currentPage, 1)
        XCTAssertFalse(viewModel.paginationData.pagesRemaining)
        XCTAssertEqual(viewModel.conversationHistory.first, expected)
        XCTAssertNotEqual(viewModel.conversationHistory[1], expected)
    }

    func testTypingEventHandlerBailsWhenAlreadyTyping()
    {
        viewModel.conversationHistory = [
            ConversationEvent(id: "", typing: true, userId: "user")
        ]
        viewModel.doneAppendingToBottom = false
        let response = TypingResponse(name: "", typing: true, userId: "user")
        let handler = manager.registeredHandlers[2].1 as? (TypingResponse) -> Void

        handler?(response)

        XCTAssertFalse(viewModel.doneAppendingToBottom)
    }

    func testTypingEventHandlerAddsTypingEvent()
    {
        let testCases = [
            (
                response: TypingResponse(name: "", typing: true, userId: "user"),
                history: [ConversationEvent(id: "id", typing: true, userId: "user2")],
                expected: 2
            ),
            (
                response: TypingResponse(name: "", typing: true, userId: "user"),
                history: [],
                expected: 1
            )
        ]

        for (response, history, expected) in testCases
        {
            XCTContext.runActivity(named: "Response: \(response), history: \(history)")
            { _ in

                let handler = manager.registeredHandlers[2].1 as? (TypingResponse) -> Void
                viewModel.conversationHistory = history

                handler?(response)

                XCTAssertTrue(viewModel.doneAppendingToBottom)
                XCTAssertEqual(viewModel.conversationHistory.count, expected)
            }
        }
    }

    func testTypingEventHandlerRemovesTypingEvents()
    {
        viewModel.conversationHistory = [
            ConversationEvent(id: "", typing: true, userId: "user")
        ]
        viewModel.doneAppendingToBottom = false
        let response = TypingResponse(name: "", typing: false, userId: "user")
        let handler = manager.registeredHandlers[2].1 as? (TypingResponse) -> Void

        handler?(response)

        XCTAssertFalse(viewModel.doneAppendingToBottom)
        XCTAssertEqual(viewModel.conversationHistory.count, 0)
    }

    func testOnDisappearUnregistersHandlers()
    {
        manager.currentScreen = .baseApp

        viewModel.onDisappear()

        XCTAssertTrue(viewModel.eventHandlers.isEmpty)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 3)
        XCTAssertEqual(manager.currentScreen, .conversationList)
    }

    func testSetScrollOffsetGetsPaginatedConvoEvents()
    {
        let testCases = [
            (state: ConversationView.LoadState.initialLoad, expected: ConversationView.LoadState.initialLoad),
            (state: ConversationView.LoadState.loaded, expected: ConversationView.LoadState.loading)
        ]

        for (state, expected) in testCases
        {
            XCTContext.runActivity(named: "LoadState: \(state)")
            { _ in

                viewModel.paginationData = PaginationData(
                    currentPage: 1,
                    maxPageSize: 5,
                    pagesRemaining: true,
                    skipCounter: 2
                )
                viewModel.conversationId = "id"
                viewModel.loadState = state
                viewModel.conversationHistory = [ConversationEvent(id: "lastId")]

                viewModel.setScrollOffset(CGPoint(x: 0, y: 0))

                XCTAssertEqual(viewModel.loadState, expected)
                XCTAssertEqual(viewModel.lastTopId, "lastId")
                XCTAssertEqual(manager.emittedEvents.first?.0, .getPaginatedConversationEvents)
                XCTAssertEqual(manager.emittedEvents.first?.1.count, 1)
            }
        }
    }

    func testSetScrollOffsetSetsLoadedState()
    {
        viewModel.loadState = .initialLoad

        viewModel.setScrollOffset(CGPoint(x: 0, y: 0))

        XCTAssertEqual(viewModel.loadState, .loaded)
        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSetScrollOffsetBailsForExpected()
    {
        let testCases = [
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: true,
                state: ConversationView.LoadState.initialLoad,
                id: "id",
                history: []
            ),
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: true,
                state: ConversationView.LoadState.initialLoad,
                id: nil,
                history: [ConversationEvent(id: "id")]
            ),
            (
                offset: CGPoint(x: 0, y: 10),
                pagesRemaining: true,
                state: ConversationView.LoadState.loaded,
                id: "id",
                history: [ConversationEvent(id: "id")]
            ),
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: false,
                state: ConversationView.LoadState.loaded,
                id: "id",
                history: [ConversationEvent(id: "id")]
            ),
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: true,
                state: ConversationView.LoadState.loaded,
                id: "id",
                history: []
            ),
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: true,
                state: ConversationView.LoadState.loaded,
                id: nil,
                history: [ConversationEvent(id: "id")]
            ),
            (
                offset: CGPoint(x: 0, y: 0),
                pagesRemaining: true,
                state: ConversationView.LoadState.loading,
                id: "id",
                history: [ConversationEvent(id: "id")]
            ),
        ]

        for (offset, pagesRemaining, state, id, history) in testCases
        {
            XCTContext.runActivity(
                named: "Offset: \(offset), pagesRemaining: \(pagesRemaining), loadState: \(state), convoId: \(id ?? "nil") history: \(history)"
            )
            { _ in

                viewModel.paginationData.pagesRemaining = pagesRemaining
                viewModel.conversationId = id
                viewModel.loadState = state
                viewModel.conversationHistory = history

                viewModel.setScrollOffset(offset)

                XCTAssertEqual(viewModel.loadState, state)
                XCTAssertEqual(manager.emittedEvents.count, 0)
            }
        }
    }

    func testShouldPerformLaunchActionReturnsExpected()
    {
        let testCases = [
            (
                haveLaunched: true,
                launchAction: LaunchAction(preformedInput: "hey"),
                expected: false
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(preformedInput: "hey"),
                expected: true
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(preformedInput: ""),
                expected: false
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(),
                expected: false
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(preformedIntent: .Password1),
                expected: true
            ),
            (
                haveLaunched: false,
                launchAction: nil,
                expected: false
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(preformedIntent: .Account),
                expected: false
            ),
            (
                haveLaunched: false,
                launchAction: LaunchAction(preformedIntent: .ContactUs),
                expected: false
            )
        ]

        for (haveLaunched, launchAction, expected) in testCases
        {
            XCTContext.runActivity(
                named: "HaveLaunched: \(haveLaunched), LaunchAction: \(String(describing: launchAction))"
            )
            { _ in

                let config = Configuration(launchAction: launchAction, options: ConfigOptions(authToken: ""))
                manager.isLaunchActionPerformed = haveLaunched

                let result = viewModel.shouldPerformLaunchAction(config: config)

                XCTAssertEqual(result, expected)
            }
        }
    }

    func testPerformLaunchActionBailsWhenNoEngagementId()
    {
        let expectation = XCTestExpectation(description: "No event emitted")
        let launchAction = LaunchAction(preformedInput: "hey")
        let config = Configuration(launchAction: launchAction, options: ConfigOptions(authToken: ""))
        manager.settings?.engagementId = nil

        viewModel.performLaunchAction(config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)
        {
            XCTAssertTrue(self.manager.emittedEvents.isEmpty)
            XCTAssertFalse(self.manager.isLaunchActionPerformed)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testPerformLaunchActionBailsWhenShouldPerformFalse()
    {
        let expectation = XCTestExpectation(description: "No event emitted")
        let config = Configuration(options: ConfigOptions(authToken: ""))
        manager.settings?.engagementId = "id"

        viewModel.performLaunchAction(config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)
        {
            XCTAssertTrue(self.manager.emittedEvents.isEmpty)
            XCTAssertFalse(self.manager.isLaunchActionPerformed)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testPerformLaunchActionHandlesPreformedInput()
    {
        let expectation = XCTestExpectation(description: "PreformedInput Sent")
        let launchAction = LaunchAction(preformedInput: "hey")
        let config = Configuration(launchAction: launchAction, options: ConfigOptions(authToken: ""))
        manager.settings?.engagementId = "id"

        viewModel.performLaunchAction(config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)
        {
            let event = self.manager.emittedEvents.first?.0
            let request = self.manager.emittedEvents.first?.1.first as! AddConversationEventRequest

            XCTAssertEqual(event, .addConversationEvent)
            XCTAssertNil(request.conversationId)
            XCTAssertNil(request.directIntentHit)
            XCTAssertEqual(request.engagementId, "id")
            XCTAssertEqual(request.input, "hey")
            XCTAssertEqual(request.launchAction, launchAction)
            XCTAssertNil(request.metadataName)
            XCTAssertNil(request.metadataValue)
            XCTAssertTrue(self.manager.isLaunchActionPerformed)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testPerformLaunchActionHandlesPreformedIntent()
    {
        let expectation = XCTestExpectation(description: "PreformedIntent Sent")
        let launchAction = LaunchAction(preformedIntent: .Password1)
        let config = Configuration(launchAction: launchAction, options: ConfigOptions(authToken: ""))
        manager.settings?.engagementId = "id"

        viewModel.performLaunchAction(config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)
        {
            let event = self.manager.emittedEvents.first?.0
            let request = self.manager.emittedEvents.first?.1.first as! AddConversationEventRequest

            XCTAssertEqual(event, .addConversationEvent)
            XCTAssertNil(request.conversationId)
            XCTAssertEqual(request.directIntentHit, "MAPP: Custom Password Reset 1")
            XCTAssertEqual(request.engagementId, "id")
            XCTAssertEqual(request.input, "Password Help")
            XCTAssertEqual(request.launchAction, launchAction)
            XCTAssertNil(request.metadataName)
            XCTAssertNil(request.metadataValue)
            XCTAssertTrue(self.manager.isLaunchActionPerformed)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
