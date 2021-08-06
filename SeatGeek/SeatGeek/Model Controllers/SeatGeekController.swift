//
//  SeatGeekController.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData
import SwiftyJSON

class SeatGeekController {
    
    //MARK: Properties
    
    var clientID: String? = ProcessInfo.processInfo.environment["client_id"]
    var auth: String? {
        guard let clientID = clientID else { return nil }
        return "\(clientID):".data(using: .utf8)?.base64EncodedString()
    }
    
    var testing: Bool
    var moc: NSManagedObjectContext {
        testing ? PersistenceController.test.container.viewContext : PersistenceController.mainContext
    }
    
    init(testing: Bool = false) {
        self.testing = testing
    }
    
    static var dateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        return formatter
    }
    
    //MARK: SeatGeekError
    
    enum SeatGeekError: Error {
        case noClientID
    }
    
    //MARK: Functions
    
    @discardableResult
    func getEvents(completion: @escaping ([Event]?, Error?) -> Void) -> URLSessionDataTask? {
        guard let auth = auth,
              let url = URL(string: "https://api.seatgeek.com/2/events") else {
            NSLog("No valid client ID found. Set client_id in the scheme's environment to your SeatGeek client ID.")
            completion(nil, SeatGeekError.noClientID)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        
        let moc = self.moc
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return completion(nil, error) }
            do {
                let json = try JSON(data: data)
                let events = try self?.loadEvents(from: json, context: moc)
                print(events?.compactMap { $0.title } ?? [])
                completion(events, error)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    //MARK: Private
    
    @discardableResult
    private func loadEvents(from json: JSON, context moc: NSManagedObjectContext) throws -> [Event]? {
        guard let eventsJSON = json["events"].array else { return nil }
        
        let ids = eventsJSON.compactMap { $0["id"].int64 }
        
        // Fetch existing events
        let eventsFetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        eventsFetchRequest.predicate = NSPredicate(format: "id in %@", ids)
        let existingEvents = try moc.fetch(eventsFetchRequest)
        
        let eventsByID = Dictionary(uniqueKeysWithValues: zip(existingEvents.map { $0.id }, existingEvents))
        
        return eventsJSON.compactMap { loadEvent(from: $0, existingEvents: eventsByID, context: moc) }
    }
    
    private func loadEvent(from json: JSON, existingEvents: [Int64: Event], context moc: NSManagedObjectContext) -> Event? {
        guard let id = json["id"].int64 else { return nil }
        if let existingEvent = existingEvents[id] {
            existingEvent.update(from: json)
            return existingEvent
        } else {
            return Event(json: json, context: moc)
        }
    }
    
}
