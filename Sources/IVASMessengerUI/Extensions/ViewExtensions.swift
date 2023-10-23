import SwiftUI

struct OnFirstAppearModifier: ViewModifier
{
    @State private var firstTime: Bool = true

    let perform: () -> Void

    func body(content: Content) -> some View
    {
        content
            .onAppear
            {
                guard firstTime
                else
                {
                    return
                }

                firstTime = false

                self.perform()
            }
    }
}

struct HandleSocketSceneChange: ViewModifier
{
    @Environment(\.scenePhase) var scenePhase

    let engagementManager: EngagementManager

    func body(content: Content) -> some View
    {
        content
            .onChange(of: scenePhase)
            { scenePhase in

                switch scenePhase
                {
                    case .active:
                        engagementManager.connect()

                    case .background, .inactive:
                        engagementManager.disconnect()

                    default:
                        break
                }
            }
    }
}

extension View
{
    func onFirstAppear(perform: @escaping () -> Void) -> some View
    {
        return self.modifier(OnFirstAppearModifier(perform: perform))
    }

    func handleSocketSceneChange(engagementManager: EngagementManager) -> some View
    {
        return self.modifier(HandleSocketSceneChange(engagementManager: engagementManager))
    }
}
