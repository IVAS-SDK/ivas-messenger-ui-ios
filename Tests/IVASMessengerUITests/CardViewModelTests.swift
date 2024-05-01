@testable import IVASMessengerUI
import XCTest
import SwiftUI

@available(iOS 15, *)
@MainActor class CardViewModelTests: XCTestCase
{
    var viewModel: CardView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = MessengerEngagementSettings()
        viewModel = CardView.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager,
            event: ConversationEvent(conversationId: "convoId", id: "")
        )
    }

    func testGetCardTemplateReturnsNilForNoTemplateData()
    {
        let event = ConversationEvent(id: "")
        viewModel.event = event

        let result = viewModel.getCardTemplate()

        XCTAssertNil(result)
    }

    func testGetCardTemplateReturnsNilForSerializationError()
    {
        let event = ConversationEvent(
            id: "",
            metadata: [
                "templateData": [
                    "not right data": true
                ]
            ]
        )
        viewModel.event = event

        let result = viewModel.getCardTemplate()

        XCTAssertNil(result)
    }

    func testGetCardTemplateReturnsExpected()
    {
        let expected = CardTemplate(
            banner: "b",
            buttons: [
                CardButton(
                    directIntentHit: "d",
                    input: "i",
                    pendingData: ["p": 1],
                    title: "t"
                )
            ],
            image: "i",
            rows: [
                [
                    CardRow(title: "t", value: "v"),
                    CardRow(title: "t", value: "v")
                ],
                [
                    CardRow(title: "t", value: "v")
                ]
            ],
            title: "t",
            type: .card
        )
        let event = ConversationEvent(
            id: "",
            metadata: [
                "templateData": [
                    "banner": "b",
                    "image": "i",
                    "title": "t",
                    "type": "CARD",
                    "buttons": [
                        [
                            "directIntentHit": "d",
                            "input": "i",
                            "pendingData": ["p": 1],
                            "title": "t"
                        ]
                    ],
                    "rows": [
                        [
                            ["title": "t", "value": "v"],
                            ["title": "t", "value": "v"]
                        ],
                        [
                            ["title": "t", "value": "v"]
                        ]
                    ]
                ]
            ]
        )
        viewModel.event = event

        let result = viewModel.getCardTemplate()

        XCTAssertEqual(result, expected)
    }

    func testSendInputBailsWhenNoEngagementId()
    {
        let button = CardButton(
            directIntentHit: "intent",
            input: "input",
            pendingData: ["temp": "t"],
            title: "title"
        )

        viewModel.sendInput(for: button)

        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSendInputSendsExpectedEvent()
    {
        let expectedRequest = AddConversationEventRequest(
            conversationId: "convoId",
            directIntentHit: "intent",
            input: "input",
            metadataName: "n",
            metadataValue: ["t": "v"],
            pendingData: ["temp": "t"]
        )
        let button = CardButton(
            directIntentHit: "intent", 
            input: "input",
            pendingData: ["temp": "t"], 
            title: "title"
        )
        viewModel.config.metadata = ConversationEventMetadata(
            metadataName: "n",
            metadataValue: ["t": "v"]
        )

        viewModel.sendInput(for: button)

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .eventCreate)
        XCTAssertEqual(request.conversationId, expectedRequest.conversationId)
        XCTAssertEqual(request.directIntentHit, expectedRequest.directIntentHit)
        XCTAssertEqual(request.input, expectedRequest.input)
        XCTAssertEqual(request.metadataName, expectedRequest.metadataName)
        XCTAssertNotNil(request.metadataValue)
    }
}
