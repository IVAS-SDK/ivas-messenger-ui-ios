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
                authToken: "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJ3b3Jrc3BhY2VJZCI6IjY1M2ZjMzQ5OGY0NWMzYWU2YTUzNDM0NCIsImlhdCI6MTY5ODY3NzU3N30.ylAGWScS3sehDgeFt4gbaIJGweV8O5wfYCizgZoIVsIU6LbEXAz_cDVSmWVmV1sJFwy6idYGkBUdpdFm8_9oFSvvZOl6xn9E2WtCyvN7Shk5pDRkJCJL2gdLTypCo5gP3Dk5LLK2JQ8tBRHuqUS85JZKslwSg7YVq73oA2eZVmOygeIyLFwZa2UnnQGUHPy85WhRRKVn9Rwm0z7PXG0akKVd1xmTHWhKwl9Il_NLmDjNF3BDWt5gzyQMvlv6nag232T6dNob_zBHYAQKkYYhrIh0Szf_765R05_fNRAsEginybgL_T02PUDDXj19YG2P8QDE45-fZd6zAonKY-9p-mqMzMo5bVrd5AOr0WCh8-zOTZ2uGiOzYKGguegnxW_91P-kn4n1NN0rJgc7jEpEgtA8dRDgNlSzBla6ChUlEqV9gs6MAUKVVbEL5XPlJbD_oD43BCbtX9VnNGWLm-_2JHfyPpjDDoIAj-xN3UAMFV-IOTKOBKscbUvBLfv5tIAB",
                moduleLocalization: true,
                prod: false,
                routineHandler: GenesysLiveChat()
                
            )

            let conversationMetadata = ConversationEventMetadata(
                metadataName: "trackingJson",
                metadataValue: [
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

