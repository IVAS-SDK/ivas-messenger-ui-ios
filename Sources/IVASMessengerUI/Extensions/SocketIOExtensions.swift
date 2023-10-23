import Foundation
import SocketIO

extension Decodable
{
    init(from any: Any) throws
    {
        let data = try JSONSerialization.data(withJSONObject: any)
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

extension SocketIOClient
{
    func on(_ event: CustomSocketEvents, callback: @escaping NormalCallback) -> UUID
    {
        return self.on(event.rawValue)
        { data, ack in

            callback(data, ack)
        }
    }

    func on<T: Decodable>(_ event: CustomSocketEvents, callback: @escaping (T) -> Void) -> UUID
    {
        return self.on(event.rawValue)
        { data, _ in

            guard !data.isEmpty else
            {
                print("[SocketIO] \(event) data empty")

                return
            }

            guard let decoded = try? T(from: data[0]) else
            {
                print("[SocketIO] \(event) data \(data) cannot be decoded to \(T.self)")

                return
            }

            callback(decoded)
        }
    }

    func emit(_ event: CustomSocketEvents, _ items: SocketData..., completion: (() -> Void)? = nil)
    {
        emit(event.rawValue, with: items, completion: completion)
    }
}
