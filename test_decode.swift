import Foundation

struct SpotlightItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    
    let date: String?
    let location: String?
    let type: String?
    let url: String?
    let priceMin: Double?
    let priceMax: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, date, type, url
        case imageUrl = "image_url"
        case priceMin = "price_min"
        case priceMax = "price_max"
    }
}

let sem = DispatchSemaphore(value: 0)
let url = URL(string: "https://district.monu14.me/api/v1/events?type=movie")!
URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error { print("Network Error: \(error)"); sem.signal(); return }
    do {
        let items = try JSONDecoder().decode([SpotlightItem].self, from: data!)
        print("Success! Decoded \(items.count) movies.")
    } catch {
        print("Decoding Error: \(error)")
    }
    sem.signal()
}.resume()
sem.wait()
