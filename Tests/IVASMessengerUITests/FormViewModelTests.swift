@testable import IVASMessengerUI
import GenericJSON
import XCTest

@available(iOS 15, *)
@MainActor class FormViewModelTests: XCTestCase
{
    var viewModel: FormView.ViewModel!
    var manager: EngagementManagerMock!

    @MainActor override func setUp()
    {
        super.setUp()

        manager = EngagementManagerMock()
        manager.settings = EngagementSettings()
        manager.settings?.engagementId = "eId"
        viewModel = FormView.ViewModel(
            config: Configuration(options: ConfigOptions(authToken: "")),
            manager: manager,
            form: ["id": ""],
            conversationId: "id"
        )
    }

    func testGetPlaceholderReturnsExpected()
    {
        let testCases = [
            (
                fields: [],
                value: FormFieldValue(name: "", value: ""),
                expected: ""
            ),
            (
                fields: [FormField(name: "n", placeholder: "p", type: .text)],
                value: FormFieldValue(name: "t", value: ""),
                expected: ""
            ),
            (
                fields: [FormField(name: "n", placeholder: "p", type: .text)],
                value: FormFieldValue(name: "n", value: ""),
                expected: "p"
            ),
            (
                fields: [
                    FormField(name: "n", placeholder: "p", type: .text),
                    FormField(name: "t", placeholder: "y", type: .text)
                ],
                value: FormFieldValue(name: "t", value: ""),
                expected: "y"
            )
        ]

        for (fields, value, expected) in testCases
        {
            XCTContext.runActivity(named: "Fields:\(fields), Value: \(value)")
            { _ in

                viewModel.template = FormTemplate(fields: fields, id: "")

                let result = viewModel.getPlaceholder(for: value)

                XCTAssertEqual(result, expected)
            }
        }
    }

    func testSubmitValuesBailsWhenNoIntent()
    {
        viewModel.template = FormTemplate(fields: [], id: "")
        viewModel.errorMessage = "e"

        viewModel.submitValues()

        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSubmitValuesSendsExpectedWhenNoValidation()
    {
        viewModel.template = FormTemplate(destination: FormDestination(directIntentHit: "d"), fields: [], id: "")

        viewModel.submitValues()

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .addConversationEvent)
        XCTAssertEqual(request.conversationId, "id")
        XCTAssertEqual(request.engagementId, "eId")
        XCTAssertEqual(request.input, "Form Submitted")
        XCTAssertNil(request.launchAction)
        XCTAssertNil(request.metadataName)
        XCTAssertNil(request.metadataValue)
        XCTAssertEqual(request.pendingData as! [String: String], [:])
    }

    func testSubmitValuesSendsExpectedWhenPassesValidation()
    {
        viewModel.template = FormTemplate(
            destination: FormDestination(directIntentHit: "d"),
            fields: [
                FormField(name: "req", type: .text),
                FormField(name: "reg", type: .text)
            ],
            id: "", 
            validation: [
                "req": FormValidation(message: "req", required: true),
                "reg": FormValidation(message: "reg", regex: FormValidationRegex(pattern: "\\d"))
            ]
        )
        viewModel.fieldValues = [
            FormFieldValue(name: "req", value: "hey"),
            FormFieldValue(name: "reg", value: "7")
        ]

        viewModel.submitValues()

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .addConversationEvent)
        XCTAssertEqual(request.conversationId, "id")
        XCTAssertEqual(request.engagementId, "eId")
        XCTAssertEqual(request.input, "Form Submitted")
        XCTAssertNil(request.launchAction)
        XCTAssertNil(request.metadataName)
        XCTAssertNil(request.metadataValue)
        XCTAssertEqual(request.pendingData as! [String: String], ["req": "hey", "reg": "7"])
    }

    func testSubmitValuesSetsErrorForRequiredValidation()
    {
        viewModel.template = FormTemplate(
            destination: FormDestination(directIntentHit: "d"),
            fields: [
                FormField(name: "req", type: .text),
                FormField(name: "reg", type: .text)
            ],
            id: "",
            validation: [
                "req": FormValidation(message: "req", required: true),
                "reg": FormValidation(message: "reg", regex: FormValidationRegex(pattern: "\\d"))
            ]
        )
        viewModel.fieldValues = [
            FormFieldValue(name: "reg", value: "7"),
            FormFieldValue(name: "req", value: "")
        ]

        viewModel.submitValues()

        XCTAssertEqual(viewModel.errorMessage, "req")
        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSubmitValuesSetsErrorForRegexValidation()
    {
        viewModel.template = FormTemplate(
            destination: FormDestination(directIntentHit: "d"),
            fields: [
                FormField(name: "req", type: .text),
                FormField(name: "reg", type: .text)
            ],
            id: "",
            validation: [
                "req": FormValidation(message: "req", required: true),
                "reg": FormValidation(message: "reg", regex: FormValidationRegex(pattern: "\\d"))
            ]
        )
        viewModel.fieldValues = [
            FormFieldValue(name: "req", value: "hey"),
            FormFieldValue(name: "reg", value: "hey")
        ]

        viewModel.submitValues()

        XCTAssertEqual(viewModel.errorMessage, "reg")
        XCTAssertEqual(manager.emittedEvents.count, 0)
    }

    func testSubmitValuesSendsExpectedWhenRegexValidationErrorsOut()
    {
        viewModel.template = FormTemplate(
            destination: FormDestination(directIntentHit: "d"),
            fields: [
                FormField(name: "req", type: .text),
                FormField(name: "reg", type: .text)
            ],
            id: "",
            validation: [
                "req": FormValidation(message: "req", required: true),
                "reg": FormValidation(message: "reg", regex: FormValidationRegex(pattern: ""))
            ]
        )
        viewModel.fieldValues = [
            FormFieldValue(name: "req", value: "hey"),
            FormFieldValue(name: "reg", value: "7")
        ]

        viewModel.submitValues()

        let event = manager.emittedEvents.first?.0
        let request = manager.emittedEvents.first?.1.first as! AddConversationEventRequest

        XCTAssertEqual(event, .addConversationEvent)
        XCTAssertEqual(request.conversationId, "id")
        XCTAssertEqual(request.engagementId, "eId")
        XCTAssertEqual(request.input, "Form Submitted")
        XCTAssertNil(request.launchAction)
        XCTAssertNil(request.metadataName)
        XCTAssertNil(request.metadataValue)
        XCTAssertEqual(request.pendingData as! [String: String], ["req": "hey", "reg": "7"])
    }
}
