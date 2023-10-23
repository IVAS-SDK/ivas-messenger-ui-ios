import SwiftUI

@available(iOS 15, *)
struct ParticipantsView: View
{
    @ObservedObject var engagementManager: EngagementManager
    @Binding var hasAppeared: Bool
    @StateObject private var viewModel: ViewModel

    var isNewConversation = false

    var body: some View
    {
        HStack
        {
            ZStack
            {
                ForEach(0..<viewModel.participantsData.count, id: \.self)
                { index in

                    if let avatar = viewModel.participantsData[index].avatar
                    {
                        AsyncImage(url: URL(string: avatar))
                        { image in

                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: 15 * CGFloat(index))
                                .zIndex(Double(-index))

                        } placeholder: {}
                    }
                    else
                    {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.mask(Circle()))
                            .offset(x: 15 * CGFloat(index))
                            .zIndex(Double(-index))
                    }
                }
            }

            VStack(alignment: .leading)
            {
                switch viewModel.participantsData.count
                {
                    case ..<1:
                        if isNewConversation
                        {
                            Text(String(
                                localized: "ivas.conversation.newConversationTitle",
                                bundle: engagementManager.localizationBundle
                            ))
                                .foregroundColor(.white)
                        }

                    case 1:
                        Text(viewModel.getSingleParticipantName().capitalized)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text(viewModel.getSingleParticipantType().capitalized)
                            .font(.footnote)
                            .foregroundColor(.white)

                    case 2...:
                        Text(viewModel.getMultipleParticipantsName())
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)

                    default:
                        EmptyView()
                }
            }
            .padding(.leading, CGFloat(viewModel.participantsData.count - 1) * 15)
        }
        .onAppear()
        {
            viewModel.onAppear()
            hasAppeared = true
        }
        .onDisappear() { viewModel.onDisappear() }
    }

    init(engagementManager: EngagementManager, hasAppeared: Binding<Bool>, isNewConversation: Bool)
    {
        self.engagementManager = engagementManager
        self._hasAppeared = hasAppeared
        self.isNewConversation = isNewConversation

        _viewModel = StateObject(wrappedValue: ViewModel(manager: engagementManager))
    }
}
