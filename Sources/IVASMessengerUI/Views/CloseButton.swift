import SwiftUI

@available(iOS 15, *)
struct CloseButton: View
{
    @ObservedObject var engagementManager: EngagementManager
    var viewController: UIViewController?

    var body: some View
    {
        Button(action: { viewController?.dismiss(animated: true) },
        label: {
            Image(systemName: "xmark")
                .accessibilityLabel(
                    String(
                        localized: "ivas.navigationBar.closeButtonAria",
                        bundle: engagementManager.localizationBundle
                    )
                )
        })
        .tint(.white)
    }
}
