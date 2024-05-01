import Foundation

public struct ConfigureSessionMessage: Codable
{
    var action: String
    var deploymentId: String
    var token: String
}
