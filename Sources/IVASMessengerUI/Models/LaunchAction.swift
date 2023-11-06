import Foundation
import SocketIO

public struct LaunchAction: SocketData, Equatable
{
    public var preformedIntent: Intent?
    public var preformedInput: String?

    public init(preformedIntent: Intent? = nil, preformedInput: String? = nil) 
    {
        self.preformedIntent = preformedIntent
        self.preformedInput = preformedInput
    }

    public func socketRepresentation() throws -> SocketData
    {
        return [
            "preformedIntent": try preformedIntent?.socketRepresentation(),
            "preformedInput": preformedInput
        ] as [String: SocketData?]
    }
}

public enum Intent: String, SocketData
{
    case Account, ContactUs, Password1, Password2, ReservationDetails, ReservationSummary, ResModify

    public func socketRepresentation() throws -> SocketData
    {
        return self.rawValue
    }

    func mappedData() -> (utterance: String, directIntentHit: String)?
    {
        switch self
        {
            case .Account, .ContactUs:
                return nil

            case .Password1:
                return ("Password Help", "MAPP: Custom Password Reset 1")

            case .Password2:
                return ("Password Reset Help", "MAPP: Custom Password Reset 2")

            case .ResModify, .ReservationSummary:
                return ("Reservation Help", "MAPP: Custom Reservation Summary")

            case .ReservationDetails:
                return ("Reservation Help", "MAPP: Custom Reservation Details")
        }
    }
}
