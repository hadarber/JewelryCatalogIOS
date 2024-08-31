
import Foundation

struct Jewelry: Codable {
    var id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    var isFavorite: Bool
    
    init?(dict: [String: Any]) {
            guard let name = dict["name"] as? String,
                  let description = dict["description"] as? String,
                  let price = dict["price"] as? Double,
                  let imageURL = dict["imageURL"] as? String,
                  let isFavorite = dict["isFavorite"] as? Bool else {
                return nil
            }
            
            self.id = ""  // נעדכן את זה מאוחר יותר עם המפתח של ה-snapshot
            self.name = name
            self.description = description
            self.price = price
            self.imageURL = imageURL
            self.isFavorite = isFavorite
        }
    
    mutating func toggleFavorite() {
            isFavorite.toggle()
        }
}
