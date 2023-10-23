import IVASMessengerUI
import UIKit

class ViewController: UIViewController
{
    var config: Configuration?


    override func viewDidLoad()
    {
        super.viewDidLoad()

        let button = UIButton()

        button.frame.size = CGSize(width: 200.0, height: 44.0)
        button.center = view.center
        button.setTitle("Present Messenger", for: .normal)
        button.addTarget(self, action: #selector(presentMessenger), for: .touchUpInside)

        view.addSubview(button)
    }

    @objc
    func presentMessenger()
    {
        if #available(iOS 15, *)
        {
            let configOptions = ConfigOptions(
                authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50TnVtYmVyIjo1MDA5NjAyLCJhcGlOYW1lIjoibWVzc2VuZ2VyIiwicHJpdmF0ZSI6ZmFsc2UsImlhdCI6MTYxMDUwNzMxM30.USArf1gntyOIuCNRyo_XNJD5T5R5ngXbrwGk4moIWP0",
                moduleLocalization: true
            )

            let conversationMetadata = ConversationEventMetadata(
                metadataName: "trackingJson",
                metadataValue: [
                    "sample": "data",
                    "sample2": [1, 2, 3],
                    "sample3": ["sample4": "sample5"],
                    "prod": false,
                    "isNative": true,
                    "hotelCode": "YUMAZ"
                ]
            )

            let config = Configuration(options: configOptions, metadata: conversationMetadata)
            { (event: AddConversationEventResponse) in

                // Perform any analytics work here...
                print(event)
            }

            self.config = config

            let view = MessengerView(config: config)
            let controller = UINavigationController(rootViewController: view.viewController)

            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            controller.navigationBar.tintColor = .white

            present(controller, animated: true)
        }
    }
}

