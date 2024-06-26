import SwiftUI
import WrappingHStack

@available(iOS 15, *)
struct ChipCollectionView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel

    let chipOptions: [ChipOption]

    var body: some View
    {
        WrappingHStack(self.chipOptions, alignment: .center, lineSpacing: 8)
        { option in

            Button()
            {
                viewModel.sendInput(option: option)
            } label: { Text(option.displayText ?? option.input).padding(.horizontal, 12).padding(.vertical, 6) }
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .background((engagementManager.settings?.actionColor)!)
            .foregroundColor(engagementManager.settings?.actionColor)
            .border((engagementManager.settings?.actionColor)!, width: 2)
            
        }
    }

    init(config: Configuration, engagementManager: EngagementManager, options: [ChipOption], conversationId: String?)
    {
        self.config = config
        self.engagementManager = engagementManager
        self.chipOptions = options

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager, conversationId: conversationId))
    }
}
