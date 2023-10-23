import SwiftUI

class HostingController<ContentView>: UIHostingController<ContentView> where ContentView: ViewControllable
{
    override func loadView()
    {
        super.loadView()

        self.rootView.loadView()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.rootView.viewOnAppear(viewController: self)
    }
}
