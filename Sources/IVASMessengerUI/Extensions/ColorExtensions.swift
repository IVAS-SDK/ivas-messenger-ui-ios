import SwiftUI

extension Color: Codable
{
    init(hex: String)
    {
        let rgba = hex.toRGBA()

        self.init(.sRGB,
                  red: Double(rgba.red),
                  green: Double(rgba.green),
                  blue: Double(rgba.blue),
                  opacity: Double(rgba.alpha))
    }

    public init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)

        self.init(hex: hex)
    }

    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(toHex)
    }

    var toHex: String?
    {
        return toHex()
    }

    func toHex(alpha: Bool = false) -> String?
    {
        guard let components = cgColor?.components, components.count >= 3 else
        {
            return nil
        }

        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        var alphaValue = Float(1.0)

        if components.count >= 4
        {
            alphaValue = Float(components[3])
        }

        if alpha
        {
            return String(format: "%02lX%02lX%02lX%02lX",
                        lroundf(red * 255),
                        lroundf(green * 255),
                        lroundf(blue * 255),
                        lroundf(alphaValue * 255))
        }

        return String(format: "%02lX%02lX%02lX",
                    lroundf(red * 255),
                    lroundf(green * 255),
                    lroundf(blue * 255))
    }
}

extension String
{
    func toRGBA() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    {
        var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        let length = hexSanitized.count

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        if length == 6
        {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        }
        else if length == 8
        {
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        }

        return (red, green, blue, alpha)
    }
}
