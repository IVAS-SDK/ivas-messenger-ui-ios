import SwiftUI

@available(iOS 15, *)
struct InputBox: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel

    var conversationId: String?

    var body: some View
    {
        HStack
        {
            TextField(viewModel.getInputPlaceholder(), text: $viewModel.inputText)
                .submitLabel(.send)
                .onSubmit({ viewModel.sendInput(conversationId: conversationId) })
                .tint(.black)
            Button(action: { viewModel.sendInput(conversationId: conversationId) },
            label: {
                Image(systemName: "paperplane.fill")
                    .accessibilityLabel(
                        String(
                            localized: "ivas.inputBox.sendButtonAria",
                            bundle: engagementManager.localizationBundle
                        )
                    )
            })
            .tint(engagementManager.settings?.actionColor)
        }
        .padding()
        .background(.white)
    }

    init(config: Configuration, engagementManager: EngagementManager, conversationId: String?)
    {
        self.config = config
        self.engagementManager = engagementManager
        self.conversationId = conversationId

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager))
    }
}
