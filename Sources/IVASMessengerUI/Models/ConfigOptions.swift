import Foundation
import SocketIO

public let defaultUrl = URL("https://messenger.usw.ivastudio.ai")
public let defaultNamespace = "/v1"

public let defaultConfig: SocketIOClientConfiguration = [
    .forceWebsockets(true),
    .log(true),
    .version(.three),
]

public struct ConfigOptions
{
    public var authToken: String
    public var moduleLocalization: Bool
    public var socketConfig: SocketIOClientConfiguration
    public var socketUrl: URL
    public var namespace: String
    public var prod: Bool
    public var routineHandler: IEngagementRoutine?

    public init(
        authToken: String,
        moduleLocalization: Bool = false,
        socketConfig: SocketIOClientConfiguration = defaultConfig,
        socketUrl: URL = defaultUrl,
        namespace: String = defaultNamespace,
        prod: Bool = true,
        routineHandler: IEngagementRoutine? = nil
    ) {
        self.authToken = authToken
        self.moduleLocalization = moduleLocalization
        self.socketConfig = socketConfig
        self.socketUrl = socketUrl
        self.namespace = namespace
        self.prod = prod
        self.routineHandler = routineHandler
    }
}

