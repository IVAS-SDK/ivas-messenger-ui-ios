import Foundation
import Starscream
import GenericJSON


public class GenesysLiveChat : IEngagementRoutine, WebSocketDelegate {

    private let STATE_CONNECTING = "CONNECTING"
    private let STATE_DISCONNECTING = "DISCONNECTING"
    private let STATE_CONNECTED = "CONNECTED"
    private let STATE_DISCONNECTED = "DISCONNECTED"
    
    private var conversationId : String? = nil
    
    private var engagementId : String? = nil
    
    private var liveChatGuid : String = ""
    
    private var metadata: [String:JSON] = [:]
    
    private var socket : WebSocket?
    private var connected = false
    
    private var apiBaseUrl : String
    private var deploymentId : String
    private var genesysServer : String
    private var userDisconnectMessage : String
    
    public init() {
        apiBaseUrl = ""
        deploymentId = ""
        genesysServer = ""
        userDisconnectMessage = ""
    }
    
    
    private func connect(guid: String) {
        
        liveChatGuid = guid
        
        let url = "wss://webmessaging.\(genesysServer)/v1?deploymentId=\(deploymentId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    
    private func postJsonString(urlString: String, sendData: String) -> String {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        var responseString: String = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json; charset=utf-8",forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = sendData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let recvData = data, error == nil else {
                // check for fundamental networking error
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                return
            }
            
            responseString = String(data: recvData, encoding: .utf8)!
            semaphore.signal()
            
        }
        
        task.resume()
        let _ = semaphore.wait(timeout: DispatchTime.now().advanced(by: .seconds(5)))
        
        print("GenesysLiveChat::postJsonString::\(liveChatGuid):: \(url)  \r\n\(sendData) ::\r\n\r\n \(responseString)")
        
        return responseString
    }
    
    private func disconnect(originator: String = "operator") {
        
        if (originator != "operator") {
            let disconnectMessage = TextActionMessage(action: "onMessage", token: liveChatGuid, message: TextMessage(type: "Text", text: userDisconnectMessage))
            let json = toJsonString(data: disconnectMessage)
            
            print("GenesysLiveChat::disconnect::\(liveChatGuid) - \(json)")
            
            socket?.write(string:json)
            
            let proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/disconnect"
            let proxyDisconnectMessage = ProxyDisconnectMessage(conversationId: conversationId, engagementId: engagementId, guid: liveChatGuid)
            let proxyJson = toJsonString(data: proxyDisconnectMessage)
            let _ = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
            
        }
        socket?.disconnect()
        
        connected = false
    }
    
    
    private func sendInit() {
        let initMessage = ConfigureSessionMessage(action: "configureSession", deploymentId: deploymentId, token: liveChatGuid)
        let json = toJsonString(data: initMessage)
        
        

        
        print("GenesysLiveChat::sendInit::\(liveChatGuid) - \(json)")
        
        socket?.write(string:json)
    }
    
    
    private func sendTextMessage(input: String, conversationId: String?, metadata: [String:JSON]) {
        let message = TextMessage(type: "Text", text: input)
        let inputMessage = TextActionMessage(action: "onMessage", token: liveChatGuid, message: message)
        let json = toJsonString(data: inputMessage)
        
        print("GenesysLiveChat::sendTextMessage::\(liveChatGuid) - \(json)")
        
        socket?.write(string:json)
        
        
        let proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/recordUserMessage"
        let proxyInputMessage = ProxyInputMessage(input : input, conversationId : conversationId, metadata : metadata)
        let proxyJson = toJsonString(data: proxyInputMessage)
        let _ = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
    }
    
    
    private func sendPing() {
        let message = PingMessage(action: "echo", message: TextMessage(type: "Text", text: "ping"))
        let json = toJsonString(data: message)
        
         print("GenesysLiveChat::sendPing::\(liveChatGuid) - \(json)")
        
        socket?.write(string:json)
    }
    
    
    private func sendPresence() {
        var channelMetaData: [String: JSON] = [:]
        channelMetaData["customAttributes"] = toJsonObject(data: metadata)
        channelMetaData["FirstName"] = metadata["firstName"] ?? "FirstNotFound"
        channelMetaData["LastName"] = metadata["lastName"] ?? "LastNotFound"
        channelMetaData["brand"] = metadata["brandCode"] ?? "6C"
        channelMetaData["language"] =  metadata["language"] ?? "EN"
        channelMetaData["rcNumber"] = metadata["rewardsClubNumber"] ?? ""
        
        
        let connectMessage = PresenceActionMessage(action: "onMessage", token: liveChatGuid, message: PresenceMessage(type: "Event", events: [PresenceEvent(eventType : "Presence", presence : PresenceType(type : "Join"))]), channel: PresenceChannelData(metadata: channelMetaData))
        
        let json = toJsonString(data: connectMessage)
        
        print("GenesysLiveChat::Presence::\(liveChatGuid) - \(json)")
        
        socket?.write(string:json)
    }
    
    private func toJsonString(data: Codable) -> String {
        let jsonData = try! JSONEncoder().encode(data)
        return String(data: jsonData, encoding: .utf8)!
    }
    private func ToObject<T>(_ type: T.Type, from data: String) -> T where T : Decodable{
        
        return try! JSONDecoder().decode(type, from: data.data(using: .utf8)!)

    }
    
    private func toJsonObject(data: Codable) -> JSON {
        let data = try! JSONEncoder().encode(data)
        let template = try! JSONDecoder().decode(JSON.self, from: data)
        
        
        
        return template
    }
    
    
    //region WebSocketListener
    
    public func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
            case .connected(let headers):
                connected = true
                print("GenesysLiveChat::onOpen::\(liveChatGuid) - Connection established: \(headers)")
                
                sendInit()
            
            
            case .disconnected(let reason, let code):
                onClose()
            print("GenesysLiveChat::onDisconnect::\(liveChatGuid) - \(code) - \(reason)")
            
            case .text(let string):
                onMessage(text: string)
            
            case .ping(_):
                break
            
            case .pong(_):
                break
            
            case .viabilityChanged(_):
                break
            
            case .reconnectSuggested(_):
                break
            
            case .cancelled:
                onClose()
            print("GenesysLiveChat::onCancelled::\(liveChatGuid)")
            
            case .error(let error):
            print("GenesysLiveChat::onError::\(liveChatGuid) -  \(String(describing: error))")
                connected = false
            
            case .peerClosed:
                break
            case .binary(_):
                break
        }
    }
    
    
    
    
    func onClose() {
        
        connected = false
        
        print("GenesysLiveChat::onClosing::\(liveChatGuid) - Connection closing")
        
        let proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/disconnect"
        let proxyDisconnectMessage = ProxyDisconnectMessage(conversationId: conversationId, engagementId: engagementId, guid: liveChatGuid)
        let proxyJson = toJsonString(data: proxyDisconnectMessage)
        let _ = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
    }

        
    func onMessage(text: String) {
        
        print("GenesysLiveChat::onMessage::\(liveChatGuid) -  \(text)")
        
        let message = ToObject(LiveChatMessage.self, from: text)
        
        var proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/log"
        let proxyLogMessage = ProxyLogMessage(conversationId: conversationId, engagementId: engagementId, event: text)
        var proxyJson = toJsonString(data: proxyLogMessage)
        let _ = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
        
        if (message.code == 200) {
            
            if ((message.type == "response") && (message.clazz == "SessionResponse") && ((message.body["connected"] != nil) == true)) {
                
                sendPresence()
                
                proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/connect"
                let proxyConnectMessage = ProxyConnectMessage(conversationId: conversationId!)
                proxyJson = toJsonString(data: proxyConnectMessage)
                let _ = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
            } else if ((message.clazz == "StructuredMessage") && (message.body["direction"] == "Outbound")) {
                
                let obj = ToObject(JSON.self, from: text)
      
                
                proxyEndpoint = "\(apiBaseUrl)genesyswebhookproxy/processmessage"
                
                let proxyOutboundMessage = ProxyOutboundMessage(message: obj, conversationId: conversationId)
                proxyJson = toJsonString(data: proxyOutboundMessage)
                let proxyReturn = postJsonString(urlString: proxyEndpoint, sendData: proxyJson)
                if(proxyReturn.count > 0) {
                    let proxyReturnObj = ToObject(ProxyReturnMessage.self, from: proxyReturn)
                
                
                    if (proxyReturnObj.data == STATE_DISCONNECTING) {
                        disconnect(originator: "operator")
                    }
                }
            }
        }
    }
    

    public func afterAddConversationEvent(payload: AddConversationEventResponse) -> Bool {
        
        let trackingJson = payload.metadata?["trackingJson"]
        
        let outputs = payload.metadata?["outputs"]
        
        if(trackingJson != nil) {
            
            
            metadata["brandCode"] = trackingJson?["hotelBrand"] ?? "6C"
            metadata["language"] = trackingJson?["siteLanguage"] ?? "EN"
            metadata["confirmationNumber"] = trackingJson?["confirmationNumber"] ?? ""
            metadata["arrivalDate"] =  trackingJson?["checkInDate"] ?? ""
            metadata["departureDate"] =  trackingJson?["checkOutDate"] ?? ""
            metadata["adults"] =  trackingJson?["adultCount"] ?? ""
            metadata["children"] =  trackingJson?["childCount"] ?? ""
            metadata["numberOfRooms"] =  trackingJson?["roomCount"] ?? ""
            metadata["city"] = trackingJson?["city"] ?? ""
            metadata["state"] =  trackingJson?["state"] ?? ""
            metadata["hotelCityStateCountryCode"] =  trackingJson?["hotelCityStateCountryCode"] ?? ""
            metadata["caseNumber"] = trackingJson?["caseNumber"] ?? ""
            metadata["rewardsClubLevel"] =  trackingJson?["trackingJson.membershipStatus"] ?? ""
            metadata["rewardsClubNumber"] =  trackingJson?["pcrNumber"] ?? trackingJson?["ihgRewardsNumber"] ?? ""
            metadata["hotelCode"] =  trackingJson?["propertyCode"] ?? ""
        }
        
        if(outputs != nil) {
            
            let postBack = outputs?["postBack"]
            
            if(postBack != nil) {
                metadata["firstName"] = postBack?["firstName"]
                metadata["lastName"] = postBack?["lastName"]
            }
            
            let guid = outputs?["guid"]
            
            let state = outputs?["liveChatState"]
            
            if(state?.stringValue == STATE_CONNECTING) {
                connect(guid: guid?.stringValue ?? "")
            } else if(state?.stringValue == STATE_DISCONNECTING) {
                
                disconnect(originator: "user")
            }
        }
        
        return connected
    }
    
    
    public func beforeAddConversationEvent(payload: inout AddConversationEventRequest) {
        
        let input = payload.input
        conversationId = payload.conversationId
        
        if(!connected) {
            return
        }
        
        
        sendTextMessage(input: input, conversationId: conversationId, metadata: metadata)
        
        
        
        //set property to avoid iva processing
        payload.liveChatState = STATE_CONNECTED
        
    }
    
    
    
    public func onEngagementLoad(settings: String) {

        let settingsObj = try? JSONDecoder().decode(MobileSettings.self, from: (settings.data(using: .utf8)!))
        
        if(settingsObj == nil) {
            print("GenesysLiveChat::onEngagementLoad - Error Loading Settings")
        }
        
        
        let liveChatSettings = settingsObj?.settings?["genesyslivechat"]
        
        self.apiBaseUrl = (liveChatSettings?["apiBaseUrl"]?.stringValue)!
        self.deploymentId = (liveChatSettings?["deploymentId"]?.stringValue)!
        self.genesysServer = (liveChatSettings?["genesysServer"]?.stringValue)!
        self.userDisconnectMessage = (liveChatSettings?["userDisconnectMessage"]?.stringValue)!
        
        print("")
    }
    
    
    public func onAction() {
        
        if(connected) {
            disconnect(originator: "user")
        }
    }
}
