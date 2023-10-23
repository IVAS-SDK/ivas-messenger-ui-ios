import SwiftUI

class MockViewController: UIViewController
{
    private var navController: UINavigationController?

    override var navigationController: UINavigationController?
    {
        set
        {
            navController = newValue
        }

        get
        {
            return navController
        }
    }
}

class MockNavigationController: UINavigationController
{
    var pushedController: UIViewController?
    var animated: Bool?

    override func pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        self.pushedController = viewController
        self.animated = animated
    }
}
