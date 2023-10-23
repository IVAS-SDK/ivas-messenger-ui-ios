import Foundation
import SocketIO

public let defaultUrl = URL("https://messenger.speakeasyai.com/socket.io")
public let defaultConfig: SocketIOClientConfiguration = [
    .extraHeaders(["origin": "https://mobile-sdk.speakeasyai.com"]),
    .forceWebsockets(true),
    .forceNew(true),
    .log(true),
    .reconnectAttempts(3),
    .version(.two)
]

public struct ConfigOptions
{
    public var authToken: String
    public var moduleLocalization: Bool
    public var socketConfig: SocketIOClientConfiguration
    public var socketUrl: URL

    public init(
        authToken: String,
        moduleLocalization: Bool = false,
        socketConfig: SocketIOClientConfiguration = defaultConfig,
        socketUrl: URL = defaultUrl
    ) {
        self.authToken = authToken
        self.moduleLocalization = moduleLocalization
        self.socketConfig = socketConfig
        self.socketUrl = socketUrl
    }
}
