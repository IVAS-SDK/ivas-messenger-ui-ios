import SwiftUI

@available(iOS 15, *)
struct NonUserEventView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    let event: ConversationEvent
    let isLast: Bool
    @State private var scales = [1.0, 1.0, 1.0]
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View
    {
        HStack(alignment: .bottom)
        {
            
            if let participant = engagementManager.participantsData[(event.sentBy?.userId)!]
            {
                if let avatar = participant.avatar
                {
                    AsyncImage(url: URL(string: avatar))
                    { image in
                        
                        image.resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                    } placeholder: {}
                }
                else
                {
                    Image(systemName: "person.circle")
                        .font(.title)
                }
            }
            else
            {
                Image(systemName: "person.circle")
                    .font(.title)
            }

            if let input = event.input
            {
                VStack(alignment: .leading)
                {
                    Text(.init(input))
                    CardView(config: config, engagementManager: engagementManager, event: event, isLast: isLast)
                }
                .padding()
                .background(Color(hex: "#ebeaea"))
                .tint(engagementManager.settings?.actionColor)
                .cornerRadius(8)
            }
            else if event.typing == true
            {
                HStack
                {
                    Circle()
                        .fill(Color(hex: "#9e9ea1"))
                        .frame(width: 5, height: 5)
                        .scaleEffect(scales[0])
                        .onAppear { animate(delay: 0.0, index: 0) }
                        .onReceive(timer)
                        { _ in

                            animate(delay: 0.0, index: 0)
                        }
                    Circle()
                        .fill(Color(hex: "#9e9ea1"))
                        .frame(width: 5, height: 5)
                        .scaleEffect(scales[1])
                        .onAppear { animate(delay: 0.1, index: 1) }
                        .onReceive(timer)
                        { _ in

                            animate(delay: 0.1, index: 1)
                        }
                    Circle()
                        .fill(Color(hex: "#9e9ea1"))
                        .frame(width: 5, height: 5)
                        .scaleEffect(scales[2])
                        .onAppear { animate(delay: 0.2, index: 2) }
                        .onReceive(timer)
                        { _ in

                            animate(delay: 0.2, index: 2)
                        }
                }
                    .padding()
                    .background(Color(hex: "#ebeaea"))
                    .cornerRadius(8)
            }

            Spacer()
        }
    }

    private func animate(delay: Double, index: Int)
    {
        withAnimation(.linear(duration: 0.3).delay(delay))
        {
            scales[index] = 1.0
        }

        withAnimation(.linear(duration: 0.3).delay(delay + 0.3))
        {
            scales[index] = 1.5
        }

        withAnimation(.linear(duration: 0.3).delay(delay + 0.6))
        {
            scales[index] = 1.0
        }
    }
}
