import Foundation

public struct LaunchAction
{
    public var preformedIntent: Intent?
    public var preformedInput: String?

    public init(preformedIntent: Intent? = nil, preformedInput: String? = nil) 
    {
        self.preformedIntent = preformedIntent
        self.preformedInput = preformedInput
    }
}

public enum Intent
{
    case Password1, Password2, ReservationDetails, ReservationSummary, ResModify

    func mappedData() -> (utterance: String, directIntentHit: String)
    {
        switch self
        {
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
