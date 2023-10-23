@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class ParticipantsViewModelTests: XCTestCase
{
    var viewModel: ParticipantsView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ParticipantsView.ViewModel(manager: manager)
    }

    func testOnAppearRegistersEventHandlers()
    {
        viewModel.eventHandlers = []

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 2)
        XCTAssertEqual(manager.registeredHandlers.first?.0, .doneUpdatingParticipants)
        XCTAssertEqual(manager.registeredHandlers[1].0, .doneGettingPaginatedConversationEvents)
    }

    func testOnAppearDoesNotReRegisterEventHandlers()
    {
        XCTAssertEqual(viewModel.eventHandlers.count, 2)

        viewModel.onAppear()

        XCTAssertEqual(viewModel.eventHandlers.count, 2)
    }

    func testParticipantEventHandlerSetsExpectedData()
    {
        let data = [
            "user": Participant(accountNumber: 1, apiName: "", userId: ""),
            "nonUser": Participant(accountNumber: 2, apiName: "", userId: "")
        ]
        let response = UpdateParticipantsResponse(conversationId: "", participants: [], participantsData: data)
        let handler = manager.registeredHandlers.first?.1 as? (UpdateParticipantsResponse) -> Void
        manager.userId = "user"

        handler?(response)

        XCTAssertEqual(viewModel.participantsData.count, 1)
        XCTAssertEqual(viewModel.participantsData.first, data["nonUser"])
    }

    func testConversationEventHandlerSetsExpectedData()
    {
        let data = [
            "user": Participant(accountNumber: 1, apiName: "", userId: ""),
            "nonUser": Participant(accountNumber: 2, apiName: "", userId: "")
        ]
        let convo = Conversation(
            _id: "id",
            lastMessage: AddConversationEventResponse(
                _id: "",
                conversationId: "",
                input: "",
                sentAt: TimeInterval(),
                sentBy: Participant(accountNumber: 0, apiName: "", userId: "")
            ),
            participants: [],
            participantsData: data,
            startedAt: 1,
            startedBy: ""
        )
        let response = GetPaginatedConversationEventsResponse(
            conversation: convo,
            page: 1,
            rows: [],
            total: 1,
            totalPages: 1
        )
        let handler = manager.registeredHandlers[1].1 as? (GetPaginatedConversationEventsResponse) -> Void
        manager.userId = "user"

        handler?(response)

        XCTAssertEqual(viewModel.participantsData.count, 1)
        XCTAssertEqual(viewModel.participantsData.first, data["nonUser"])
    }

    func testOnDisappearUnregistersHandlers()
    {
        viewModel.onDisappear()

        XCTAssertTrue(viewModel.eventHandlers.isEmpty)
        XCTAssertEqual(manager.unRegisteredHandlers.count, 2)
    }

    func testGetSingleParticipantNameReturnsExpected()
    {
        let testCases = [
            (data: [], expected: ""),
            (data: [Participant(accountNumber: 1, apiName: "", userId: "")], expected: ""),
            (data: [Participant(accountNumber: 1, apiName: "", name: "name", userId: "")], expected: "name")
        ]

        for (data, expected) in testCases
        {
            XCTContext.runActivity(named: "ParticipantData:\(data)")
            { _ in

                viewModel.participantsData = data

                let result = viewModel.getSingleParticipantName()

                XCTAssertEqual(result, expected)
            }
        }
    }

    func testGetSingleParticipantTypeReturnsExpected()
    {
        let testCases = [
            (data: [], expected: ""),
            (data: [Participant(accountNumber: 1, apiName: "", userId: "")], expected: ""),
            (data: [Participant(accountNumber: 1, apiName: "", type: "t", userId: "")], expected: "t")
        ]

        for (data, expected) in testCases
        {
            XCTContext.runActivity(named: "ParticipantData:\(data)")
            { _ in

                viewModel.participantsData = data

                let result = viewModel.getSingleParticipantType()

                XCTAssertEqual(result, expected)
            }
        }
    }

    func testGetMultipleParticipantsNameReturnsExpectedNames()
    {
        let testCases = [
            (data: [Participant(accountNumber: 1, apiName: "", name: "name", userId: "")], expected: ["name"]),
            (data: [
                Participant(accountNumber: 1, apiName: "", name: "name", userId: ""),
                Participant(accountNumber: 2, apiName: "", name: "name2", userId: "")
            ], expected: ["name", "name2"])
        ]

        for (data, expected) in testCases
        {
            XCTContext.runActivity(named: "ParticipantData:\(data)")
            { _ in

                viewModel.participantsData = data

                let result = viewModel.getMultipleParticipantsName()

                expected.forEach({ XCTAssertTrue(result.contains($0)) })
            }
        }
    }

    func testGetMultipleParticipantsNameReturnsEmptyString()
    {
        let testCases = [
            (data: [], expected: ""),
            (data: [Participant(accountNumber: 1, apiName: "", userId: "")], expected: "")
        ]

        for (data, expected) in testCases
        {
            XCTContext.runActivity(named: "ParticipantData:\(data)")
            { _ in

                viewModel.participantsData = data

                let result = viewModel.getMultipleParticipantsName()

                XCTAssertEqual(result, expected)
            }
        }
    }
}
