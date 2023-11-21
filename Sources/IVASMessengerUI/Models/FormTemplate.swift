import Foundation

struct FormTemplate: Codable, Equatable
{
    var destination: FormDestination?
    var fields: [FormField]?
    var id: String
    var validation: [String: FormValidation]?
    var values: [String: String]?
}

struct FormDestination: Codable, Equatable
{
    var directIntentHit: String?
}

struct FormField: Codable, Hashable, Identifiable
{
    private enum CodingKeys: String, CodingKey { case label, name, placeholder, type }

    let id = UUID()

    var label: String?
    var name: String
    var placeholder: String?
    var type: FormFieldType
}

struct FormValidation: Codable, Equatable
{
    var message: String?
    var required: Bool?
    var regex: FormValidationRegex?
}

struct FormValidationRegex: Codable, Equatable
{
    var pattern: String?
    // TODO: Define flag contract for mobile when needed - js flags don't map 1:1
    var flags: String?
}

enum FormFieldType: String, Codable
{
    case text
}

struct FormFieldValue: Identifiable, Hashable
{
    let id = UUID()

    var name: String
    var value: String
}
