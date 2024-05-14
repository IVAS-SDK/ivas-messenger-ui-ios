import Foundation
import SocketIO

class EngagementManager: ObservableObject
{
    @Published var currentScreen = Screen.baseApp
    @Published var isAuthenticated: Bool?
    @Published var isLaunchActionPerformed = false
    @Published var isSocketConnected = false
    @Published var settings: MessengerEngagementSettings?
    @Published var showAction: Bool = false

    var configOptions: ConfigOptions
    var conversationEventHandler: ((AddConversationEventResponse) -> ())?
    var localizationBundle: Bundle
    var userId = UUID().uuidString
    var userToken = ""
    var conversationId = ""
    var participantsData: [String: Participant] = [:]

    private var socketManager: SocketManager
    private var socket: SocketIOClient
    private let userIdKey = "ivas.userId"
    private let userTokenKey = "ivas.userToken"

    // MARK: - Public Methods

    init(configOptions: ConfigOptions, eventHandler: ((AddConversationEventResponse) -> ())?)
    {
        if let storedUserId = UserDefaults.standard.string(forKey: userIdKey)
        {
            self.userId = storedUserId
        }
        else
        {
            self.userId = UUID().uuidString
        }
        
        if let storedUserToken = UserDefaults.standard.string(forKey: userTokenKey)
        {
            self.userToken = storedUserToken
        }
        else
        {
            self.userToken = ""
        }

        self.configOptions = configOptions
        self.conversationEventHandler = eventHandler
        self.socketManager = SocketManager(socketURL: configOptions.socketUrl, config: configOptions.socketConfig)
        self.socket = socketManager.socket(forNamespace: configOptions.namespace)
        self.localizationBundle = configOptions.moduleLocalization ? .module : .main

        registerDefaultEventHandlers()

        connect()
    }

    deinit
    {
        disconnect()
    }
    
    func updateUserToken(token: UserTokenResponse)
    {
        self.userToken = token.userToken
            UserDefaults.standard.set(self.userToken, forKey: userTokenKey)
    
        self.userId  = token.userId
        UserDefaults.standard.set(self.userId, forKey: userIdKey)
    }

    func connect()
    {
        let auth = ["token" :  self.configOptions.authToken,
                    "userId" :  self.userId,
                    "referer" :  (self.configOptions.prod) ? "mobile-prod" : "mobile-stage",
                    "userToken" : self.userToken]
        
        socket.connect(withPayload: auth)
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
            
            self?.socket.emitWithAck("Engagement:get").timingOut(after: 10000)
            { args in
                guard let dict = args.first as? [String: Any] else { return }
                
                let response = try? GetEngagementResponse(from: dict)
                
                self?.isAuthenticated = true
                self?.settings = response?.settings
                
                self?.configOptions.routineHandler?.onEngagementLoad(settings: response?.routines.onEngagementLoad ?? "")
            }
            
        }

        socket.on(clientEvent: .disconnect)
        { [weak self] _, _ in

            self?.isSocketConnected = false
        }

        _ = socket.on(.eventCreate)
        { [weak self] (response: AddConversationEventResponse) in
            self?.conversationEventHandler?(response)
            
            let routineAction = self?.configOptions.routineHandler?.afterAddConversationEvent(payload: response)
            if(self?.showAction != routineAction) {
                self?.showAction = routineAction ?? false
            }
            
            if( (self?.conversationId == "") && (response.conversationId != nil)) {
                self?.conversationId = response.conversationId!
                let joinRequest = JoinConversationRequest(conversationId: self!.conversationId)
                self?.emit(.conversationJoin, joinRequest)
            }
        }
        
        _ = socket.on(.userToken)
        { [weak self] (response: UserTokenResponse) in
            self?.updateUserToken(token:response)
        }
    }
}
