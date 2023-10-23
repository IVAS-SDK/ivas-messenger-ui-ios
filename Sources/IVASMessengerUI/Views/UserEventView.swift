import SwiftUI

struct UserEventView: View
{
    @ObservedObject var engagementManager: EngagementManager

    let event: ConversationEvent

    var body: some View
    {
        HStack
        {
            Spacer()
            Text(event.input ?? "")
                .padding()
                .foregroundColor(.white)
                .background(engagementManager.settings?.backgroundColorPrimary)
                .cornerRadius(8)
        }
    }
}
