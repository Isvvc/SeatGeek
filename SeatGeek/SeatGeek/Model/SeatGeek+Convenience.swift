//
//  SeatGeek+Convenience.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData
import SwiftyJSON

//MARK: Event

extension Event {
    @discardableResult
    convenience init?(json: JSON, context moc: NSManagedObjectContext) {
        guard let id = json["id"].int64,
              let title = json["title"].string,
              let dateString = json["datetime_utc"].string,
              let date = SeatGeekController.dateFormatter.date(from: dateString) else { return nil }
        
        self.init(context: moc)
        self.id = id
        self.title = title
        self.date = date
        
        getImage(from: json)
        getLocation(from: json)
    }
    
    func update(from json: JSON) {
        if let title = json["title"].string {
            self.title = title
        }
        if let dateString = json["datetime_utc"].string,
           let date = SeatGeekController.dateFormatter.date(from: dateString) {
            self.date = date
        }
        
        getImage(from: json)
        getLocation(from: json)
    }
    
    private func getImage(from json: JSON) {
        // Images are stored in "performers".
        // Get the first image available.
        _ = json["performers"].array?.first(where: { performer in
            guard let url = performer["image"].url else { return false }
            image = url
            return true
        })
    }
    
    private func getLocation(from json: JSON) {
        // The locations are stored in "venue".
        let venue = json["venue"]
        let city = venue["city"].string
        let state = venue["state"].string
        let country = venue["country"].string
        
        switch (city, state, country) {
        case (.some(let city), .some(let region), _),
             (.some(let city), .none, .some(let region)):
            // There is a city and a state and/or country.
            location = "\(city), \(region)"
        case (.none, .some(let region), _),
             (.none, .none, .some(let region)):
            // There is no city but there is a state and/or country
            location = region
        case (.some(let city), .none, .none):
            // There is a city but no state or country.
            location = city
        default:
            break
        }
    }
}
