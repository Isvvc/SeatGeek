//
//  SeatGeek+Convenience.swift
//  SeatGeek
//
//  Created by Isaac Lyons on 8/6/21.
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
    }
    
    func update(from json: JSON) {
        if let title = json["title"].string {
            self.title = title
        }
        if let dateString = json["datetime_utc"].string,
           let date = SeatGeekController.dateFormatter.date(from: dateString) {
            self.date = date
        }
    }
}
