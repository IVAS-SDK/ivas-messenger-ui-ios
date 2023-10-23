import Foundation

public struct Participant: Codable, Equatable
{
    public var accountNumber: Int
    public var apiName: String
    public var avatar: String?
    public var engagementId: String?
    public var iat: TimeInterval?
    public var ip: String?
    public var name: String?
    public var `private`: Bool?
    public var socketId: String?
    public var type: String?
    public var userId: String
}
