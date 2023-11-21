import GenericJSON
import SwiftUI

@available(iOS 15, *)
struct FormView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel

    var body: some View
    {
        if viewModel.template != nil
        {
            VStack(alignment: .leading)
            {
                if let errorMessage = viewModel.errorMessage
                {
                    Text(errorMessage)
                }

                ForEach($viewModel.fieldValues)
                { $fieldValue in

                    TextField(
                        fieldValue.name,
                        text: $fieldValue.value,
                        prompt: Text(viewModel.getPlaceholder(for: fieldValue)).foregroundColor(Color(hex: "#757575"))
                    )
                    .padding()
                    .tint(.black)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button(
                    action: { viewModel.submitValues() },
                    label:
                    {
                        Text(String(
                            localized: "ivas.form.submitTitle",
                            bundle: engagementManager.localizationBundle
                        ))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                )
                .buttonStyle(.borderedProminent)
                .tint(engagementManager.settings?.backgroundColorPrimary)
            }
            .padding()
            .background(Color(hex: "#ebeaea"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    init(config: Configuration, engagementManager: EngagementManager, form: JSON, conversationId: String?)
    {
        self.config = config
        self.engagementManager = engagementManager

        _viewModel = StateObject(
            wrappedValue: ViewModel(
                config: config,
                manager: engagementManager,
                form: form,
                conversationId: conversationId
            )
        )
    }
}
