import SwiftUI

@available(iOS 15, *)
public struct MessengerView: ViewControllable
{
    @ObservedObject var config: Configuration
    @StateObject var engagementManager: EngagementManager
    public var holder = NavStackHolder()

    public var body: some View
    {
        LandingView(config: config, engagementManager: engagementManager, holder: holder)
    }


    public init(config: Configuration)
    {
        self.config = config

        let manager = EngagementManager(configOptions: config.options, eventHandler: config.conversationEventHandler)

        self._engagementManager = StateObject(wrappedValue: manager)
    }
}
