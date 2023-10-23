import SwiftUI

public protocol ViewControllable: View
{
    var holder: NavStackHolder { get set }

    func loadView()
    func viewOnAppear(viewController: UIViewController)
}

public extension ViewControllable
{
    var viewController: UIViewController
    {
        let viewController = HostingController(rootView: self)
        self.holder.viewController = viewController

        return viewController
    }

    func loadView() {}
    func viewOnAppear(viewController: UIViewController) {}
}
