import Foundation
import SocketIO

class EngagementManager: ObservableObject
{
    @Published var currentScreen = Screen.baseApp
    @Published var isAuthenticated: Bool?
    @Published var isLaunchActionPerformed = false
    @Published var isSocketConnected = false
    @Published var settings: EngagementSettings?

    var configOptions: ConfigOptions
    var conversationEventHandler: ((AddConversationEventResponse) -> ())?
    var localizationBundle: Bundle
    var userId = UUID().uuidString

    private var socketManager: SocketManager
    private var socket: SocketIOClient
    private let userIdKey = "ivas.userId"

    // MARK: - Public Methods

    init(configOptions: ConfigOptions, eventHandler: ((AddConversationEventResponse) -> ())?)
    {
        if let storedUserId = UserDefaults.standard.string(forKey: userIdKey)
        {
            self.userId = storedUserId
        }
        else
        {
            UserDefaults.standard.set(self.userId, forKey: userIdKey)
        }

        var newConfig = configOptions.socketConfig
        newConfig.insert(SocketIOClientOption.connectParams(["userId": self.userId]))

        self.configOptions = configOptions
        self.conversationEventHandler = eventHandler
        self.socketManager = SocketManager(socketURL: configOptions.socketUrl, config: newConfig)
        self.socket = socketManager.defaultSocket
        self.localizationBundle = configOptions.moduleLocalization ? .module : .main

        registerDefaultEventHandlers()

        connect()
    }

    deinit
    {
        disconnect()
    }

    func connect()
    {
        socket.connect()
    }

    func disconnect()
    {
        socket.disconnect()
    }

    func registerHandler<T: Decodable>(_ event: CustomSocketEvents, callback: @escaping (T) -> Void) -> UUID
    {
        return socket.on(event, callback: callback)
    }

    func unregisterHandler(id: UUID)
    {
        socket.off(id: id)
    }

    func emit(_ event: CustomSocketEvents, _ items: SocketData..., completion: (() -> Void)? = nil)
    {
        socket.emit(event, items, completion: completion)
    }

    // MARK: - Helper Methods

    private func registerDefaultEventHandlers()
    {
        socket.on(clientEvent: .connect)
        { [weak self] _, _ in

            self?.isSocketConnected = true

            guard self?.isAuthenticated == nil
            else
            {
                return
            }

            self?.socket.emit(.authenticate, AuthenticateRequest(token: self?.configOptions.authToken ?? ""))
        }

        socket.on(clientEvent: .disconnect)
        { [weak self] _, _ in

            self?.isSocketConnected = false
        }

        _ = socket.on(.authenticated)
        { [weak self] _, _ in

            self?.isAuthenticated = true

            self?.socket.emit(.getEngagementBasedOnRules, [String: Any]())
        }

        _ = socket.on(.unauthorized)
        { [weak self] _, _ in

            self?.isAuthenticated = false
        }

        _ = socket.on(.doneGettingEngagementBasedOnRules)
        { [weak self] (response: GetEngagementResponse) in

            self?.settings = response.settings
        }

        _ = socket.on(.doneAddingConversationEvent)
        { [weak self] (response: AddConversationEventResponse) in

            self?.conversationEventHandler?(response)
        }
    }
}
