import Foundation

struct Product: Identifiable, Codable, Hashable {
    var id: String { "\(name)-\(type)".hashValue.description }
    let name: String
    let type: String
    let price: Double
    let tax: Double
    let imageUrl: String?
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case type = "product_type"
        case price
        case tax
        case imageUrl = "image"
    }
}
