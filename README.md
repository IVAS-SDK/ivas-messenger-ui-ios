# IVAS Messenger UI iOS

Provides a UI to interface with IVAS Messenger.

## Installation

You can add IVAS MessengerUI iOS to an Xcode project by adding it as a package dependency.

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/IVAS-Service/ivas-messenger-ui-ios", exact: "x.x.x")
```

Or [add the package in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

The sample project included provides a working example.

A `MessengerView` should be wrapped in a `UINavigationController` and presented as a full screen modal. The view takes a `Configuration` object to pass some static config options as well as dynamic feature options. 

```swift
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

	// Example method to present messenger when a button is clicked
    @objc
    func presentMessenger()
    {
        if #available(iOS 15, *)
        {
            let configOptions = ConfigOptions(
		        authToken: "MyAuthToken", // Same auth token used in web
		        moduleLocalization: true, // Use localization bundled in this package (only en-US), or provide custom localizations at app level
		        socketUrl: URL("MessengerSocketIOUrl") // Use to change environments if needed, defaults to "https://messenger.usw.ivastudio.ai"
                namespace: "/v1" // environment specific namespace tied to url, defaults to "/v1"
                prod: false, // flag to chage between prod and staging engagements
                routineHandler: GenesysLiveChat()  //  optional routine handler, for example here the Genesys Live Chat module.  settings for this module are defined in the engagment on server
		    )

            let conversationMetadata = ConversationEventMetadata(
		        metadataName: "trackingJson", // Name of property to inject into ConversationEvents
		        metadataValue: [ // Value to be injected, complex objects included must adhere to SocketIO.SocketData so they can be serialized (https://nuclearace.github.io/Socket.IO-Client-Swift/Protocols/SocketData.html)
		            "sample": "data",
		            "sample2": [1, 2, 3],
		            "sample3": ["sample4": "sample5"]
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
    
    // Example method updating ConversationEventMetadata
    func updateMetadata()
    {
			let conversationMetadata = ConversationEventMetadata(
		        metadataName: "newName",
		        metadataValue: ["new": "data"]
		    )
		    
		    self.config.metadata = conversationMetadata
    }
}
```

### Launch Actions

When presenting Messenger, a launch action may be specified to launch directly into a new conversation with a specified input or intent.

To set a launch action, create a `LaunchAction` object and set it on the `Configuration` object passed to a `MessengerView`.

```swift
@objc
func presentMessenger()
{
    if #available(iOS 15, *)
    {
        //...

        let inputLaunchAction = LaunchAction(preformedInput: "Launch with this input")
        let intentLaunchAction = LaunchAction(preformedIntent: .Password1)

        let config = Configuration(
            launchAction: inputLaunchAction,
            options: configOptions,
            metadata: conversationMetadata
        )
        { (event: AddConversationEventResponse) in

            // Perform any analytics work here...
            print(event)
        }

        //...
    }
}
```

### Passing Metadata

The `metadata` property on the `Configuration` object controls what data is injected into conversation requests. This property takes a `ConversationEventMetadata` object. If a reference is maintained to the `Configuration` object, the `metadata` property can be repopulated at any time to dynamicly update what data is sent.

```swift
@objc
func presentMessenger()
{
    if #available(iOS 15, *)
    {
        //...

        let conversationMetadata = ConversationEventMetadata(
            metadataName: "trackingJson",
            metadataValue: [
                "sample": "data",
                "sample2": [1, 2, 3],
                "sample3": ["sample4": "sample5"],
                "prod": false
            ]
        )

        self.config = Configuration(
            options: configOptions,
            metadata: conversationMetadata
        )
        { (event: AddConversationEventResponse) in

            // Perform any analytics work here...
            print(event)
        }

        //...
    }
}

// Example method updating ConversationEventMetadata
func updateMetadata()
{
    let conversationMetadata = ConversationEventMetadata(
        metadataName: "newName",
        metadataValue: ["new": "data"]
    )

    self.config.metadata = conversationMetadata
}
```

### Receiving Event Data

The `conversationEventHandler` property on the `Configuration` object allows for passing a call back method that will be invoked when conversation events are recieved during a conversation. 

```swift
@objc
func presentMessenger()
{
    if #available(iOS 15, *)
    {
        //...

        let config = Configuration(
            options: configOptions,
            metadata: conversationMetadata
        )
        { (event: AddConversationEventResponse) in

            // Perform any analytics work here...
            print(event)
        }

        //...
    }
}
```
