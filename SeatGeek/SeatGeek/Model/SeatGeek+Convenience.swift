//
//  SeatGeek+Convenience.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData
import SwiftyJSON

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
    }
    
    private func getImage(from json: JSON) {
        // Imagesa are stored in "performers".
        // Get the first image available.
        _ = json["performers"].array?.first(where: { performer in
            guard let url = performer["image"].url else { return false }
            image = url
            return true
        })
    }
}
