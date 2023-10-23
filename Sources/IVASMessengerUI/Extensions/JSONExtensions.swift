import GenericJSON
import SocketIO


extension JSON: SocketData
{
    // NOTE: SocketIO can't serialize the JSON type, this function bridges the JSON and SocketData types
    func customSocketRepresentation() -> SocketData?
    {
        return switch self
        {
            case .array:
                self.arrayValue?.map({ $0.customSocketRepresentation() })

            case .string:
                self.stringValue

            case .number:
                self.doubleValue

            case .bool:
                self.boolValue

            case .null:
                nil

            default:
                self.objectValue?.mapValues({ $0.customSocketRepresentation() })
        }
    }
}
