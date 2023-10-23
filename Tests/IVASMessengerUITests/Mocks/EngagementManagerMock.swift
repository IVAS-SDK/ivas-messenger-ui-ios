@testable import IVASMessengerUI
import Foundation
import SocketIO

class EngagementManagerMock: EngagementManager
{
    var emittedEvents: [(CustomSocketEvents, [SocketData])] = []
    var registeredHandlers: [(CustomSocketEvents, Any)] = []
    var unRegisteredHandlers: [UUID] = []


    init()
    {
        super.init(configOptions: ConfigOptions(authToken: ""), eventHandler: nil)
    }

    override func emit(_ event: CustomSocketEvents, _ items: SocketData..., completion: (() -> Void)? = nil)
    {
        emittedEvents.append((event, items))
    }

    override func registerHandler<T>(_ event: CustomSocketEvents, callback: @escaping (T) -> Void) -> UUID where T : Decodable
    {
        registeredHandlers.append((event, callback))

        return UUID()
    }

    override func unregisterHandler(id: UUID)
    {
        unRegisteredHandlers.append(id)
    }
}
