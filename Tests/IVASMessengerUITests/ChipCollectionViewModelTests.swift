@testable import IVASMessengerUI
import XCTest

@available(iOS 15, *)
@MainActor class ChipCollectionViewModelTests: XCTestCase
{
    var viewModel: ChipCollectionView.ViewModel!
    var manager: EngagementManagerMock!


    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        viewModel = ChipCollectionView.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager,
            conversationId: "convoId"
        )
    }

    func testSendInputBailsWhenEngagementIdMissing()
    {
        manager.settings?.engagementId = nil

        viewModel.sendInput(option: ChipOption(text: "t"))

        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSendInputSendsExpectedEvent()
    {
        let expectedRequest = AddConversationEventRequest(
            conversationId: "convoId",
            directIntentHit: "d",
            engagementId: "id",
            input: "t",
            metadataName: "n",
            metadataValue: ["t": "v"]
        )
        manager.settings?.engagementId = "id"
        viewModel.config.metadata = ConversationEventMetadata(
            metadataName: "n",
            metadataValue: ["t": "v"]
        )

        viewModel.sendInput(option: ChipOption(directIntentHit: "d", text: "t"))

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .addConversationEvent)
        XCTAssertEqual(request.conversationId, expectedRequest.conversationId)
        XCTAssertEqual(request.directIntentHit, expectedRequest.directIntentHit)
        XCTAssertEqual(request.engagementId, expectedRequest.engagementId)
        XCTAssertEqual(request.input, expectedRequest.input)
        XCTAssertEqual(request.metadataName, expectedRequest.metadataName)
        XCTAssertNotNil(request.metadataValue)
    }
}
