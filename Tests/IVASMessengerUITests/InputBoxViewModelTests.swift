@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class InputBoxViewModelTests: XCTestCase
{
    var viewModel: InputBox.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = InputBox.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager
        )
    }

    func testSendInputBailsWhenEngagementIdMissing()
    {
        manager.settings?.engagementId = nil

        viewModel.sendInput(conversationId: "convoId")

        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSendInputSendsExpectedEvent()
    {
        let expectedRequest = AddConversationEventRequest(
            conversationId: "convoId",
            engagementId: "id",
            input: "input",
            metadataName: "n",
            metadataValue: ["t": "v"]
        )
        manager.settings?.engagementId = "id"
        viewModel.inputText = "input"
        viewModel.config.metadata = ConversationEventMetadata(
            metadataName: "n",
            metadataValue: ["t": "v"]
        )

        viewModel.sendInput(conversationId: "convoId")

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .addConversationEvent)
        XCTAssertEqual(request.conversationId, expectedRequest.conversationId)
        XCTAssertEqual(request.engagementId, expectedRequest.engagementId)
        XCTAssertEqual(request.input, expectedRequest.input)
        XCTAssertEqual(request.metadataName, expectedRequest.metadataName)
        XCTAssertNotNil(request.metadataValue)
        XCTAssertEqual(viewModel.inputText, "")
    }

    func testGetInputPlaceholderReturnsExpected()
    {
        let testCases = [
            (placeholder: nil, expected: "ivas.inputBox.placeholder"),
            (placeholder: "", expected: "ivas.inputBox.placeholder"),
            (placeholder: "p", expected: "p")
        ]

        for (placeholder, expected) in testCases
        {
            XCTContext.runActivity(named: "Placeholder setting:\(placeholder ?? "nil")")
            { _ in

                manager.settings?.inputPlaceholder = placeholder

                let result = viewModel.getInputPlaceholder()

                XCTAssertEqual(result, expected)
            }
        }
    }
}
