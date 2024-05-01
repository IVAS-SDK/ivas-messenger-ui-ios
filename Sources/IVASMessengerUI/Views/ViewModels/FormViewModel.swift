import GenericJSON
import SwiftUI

@available(iOS 15, *)
extension FormView
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var template: FormTemplate?
        @Published var fieldValues: [FormFieldValue] = []
        @Published var errorMessage: String?

        var config: Configuration
        var engagementManager: EngagementManager
        var conversationId: String?

        // MARK: - Public Methods

        init(
            config: Configuration,
            manager: EngagementManager,
            form: JSON,
            conversationId: String?)
        {
            self.config = config
            self.engagementManager = manager
            self.conversationId = conversationId
            self.template = getFormTemplate(from: form)
        }

        func getPlaceholder(for value: FormFieldValue) -> String
        {
            return template?.fields?.first
            {
                $0.name == value.name

            }?.placeholder ?? ""
        }

        func submitValues()
        {
            guard validate()
            else
            {
                return
            }

            sendInput()
        }

        // MARK: Helper Methods

        private func getFormTemplate(from json: JSON) -> FormTemplate?
        {
            do
            {
                let data = try JSONEncoder().encode(json)
                let template = try JSONDecoder().decode(FormTemplate.self, from: data)

                fieldValues = template.fields?.map(
                {
                    return FormFieldValue(name: $0.name, value: template.values?[$0.name] ?? "")

                }) ?? []

                return template
            }
            catch
            {
                print("Unable to read form template: \(error)")

                return nil
            }
        }

        private func validate() -> Bool
        {
            for fieldValue in fieldValues 
            {
                let validation = template?.validation?[fieldValue.name]

                if validation?.required == true && fieldValue.value.isEmpty
                {
                    errorMessage = validation?.message

                    return false
                }

                if let pattern = validation?.regex?.pattern
                {
                    do
                    {
                        let range = NSRange(fieldValue.value.startIndex..., in: fieldValue.value)
                        let matches = try NSRegularExpression(pattern: pattern).matches(in: fieldValue.value, range: range)

                        if matches.isEmpty
                        {
                            errorMessage = validation?.message

                            return false
                        }
                    }
                    catch
                    {
                        print("Regex validation error: \(error)")
                    }
                }
            }

            errorMessage = ""

            return true
        }

        private func sendInput()
        {
            guard let intent = template?.destination?.directIntentHit
            else
            {
                return
            }

            let request = AddConversationEventRequest(
                conversationId: conversationId,
                userId: engagementManager.userId,
                directIntentHit: intent,
                input: "Form Submitted",
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue,
                postBack: buildPostBack(),
                prod: engagementManager.configOptions.prod
            )

            engagementManager.emit(.eventCreate, request)
        }

        private func buildPostBack() -> JSON?
        {
            var data: [String: String] = [:]

            fieldValues.forEach
            {
                data[$0.name] = $0.value
            }

            do
            {
                return try JSON(encodable: data)
            }
            catch
            {
                print("Error serializing form data: \(error)")
            }

            return nil
        }
    }
}
