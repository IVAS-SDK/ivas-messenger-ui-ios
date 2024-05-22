import SafariServices
import SocketIO
import SwiftUI

@available(iOS 15, *)
struct LandingView: ViewControllable
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    var holder: NavStackHolder

    var body: some View
    {
        switch engagementManager.isAuthenticated
        {
            case nil:
                LoadingView()
            
            case false:
                ZStack
                {
                    Color.gray.ignoresSafeArea()
                    Text(engagementManager.errorMessage ?? "unknown error")
                        .foregroundColor(.white)
                }
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        CloseButton(engagementManager: engagementManager, viewController: holder.viewController)
                    }
                }

            case true:
                ZStack
                {
                    engagementManager.settings?.backgroundColorPrimary.ignoresSafeArea()
                    VStack
                    {
                        VStack(alignment: .leading)
                        {
                            if let title = engagementManager.settings?.mainTitle, !title.isEmpty
                            {
                                Text(.init(title))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .tint(engagementManager.settings?.actionColor)
                            }
                            if let subtitle = engagementManager.settings?.mainSubTitle, !subtitle.isEmpty
                            {
                                Text(.init(subtitle))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .tint(engagementManager.settings?.actionColor)
                                    .environment(\.openURL, OpenURLAction
                                    { url in

                                        holder.viewController?.present(SFSafariViewController(url: url), animated: true)

                                        return .handled
                                    })
                            }
                        }
                        .padding()
                        List
                        {
                            ConversationCard(config: config, engagementManager: engagementManager, holder: holder)
                        }
                        .background(Color(hex: "#FAFAFA"))
                    }
                }
                .handleSocketSceneChange(engagementManager: engagementManager)
                .onFirstAppear { viewModel.onFirstAppear(controller: holder.viewController) }
                .onAppear() { viewModel.onAppear() }
                .onDisappear() { viewModel.onDisappear() }
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        if let logo = engagementManager.settings?.logo
                        {
                            let components = logo.components(separatedBy: ",")
                            let base64 = components[1]

                            Image(base64Str: base64)?
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 44)
                                .padding()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        CloseButton(engagementManager: engagementManager, viewController: holder.viewController)
                    }
                }

            default:
                EmptyView()
        }
    }

    init(config: Configuration, engagementManager: EngagementManager, holder: NavStackHolder)
    {
        self.config = config
        self.engagementManager = engagementManager
        self.holder = holder

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager))
    }
}
