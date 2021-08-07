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
    
    /// The `client_id` API key
    var clientID: String? = ProcessInfo.processInfo.environment["client_id"]
    /// The authorization header encoded to base-64.
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
    
    /// Fetches a list of Events from the server with an option search query..
    /// - Parameters:
    ///   - search: An optional search query. Default value is `nil` which will not perform a search.
    ///   - completion: If client ID is invalid, this will run immediately on the same thread.
    ///   Otherwise, it runs when the network call finishes on a background thread.
    ///   - events: The Events returned by the server.
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful.
    /// - Returns: A URLSession data task which has been resumed.
    @discardableResult
    func getEvents(search: String? = nil, completion: @escaping (_ events: [Event]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        // Construct the URL
        let url: URL
        
        switch search {
        case .some(let search):
            // Set up the search query
            var components = URLComponents(string: "https://api.seatgeek.com/2/events")
            components?.queryItems = [.init(name: "q", value: search)]
            if let urlComponents = components?.url {
                url = urlComponents
            } else {
                // If the URL couldn't be created with
                // the search query passed in, ignore it.
                fallthrough
            }
        default:
            url = URL(string: "https://api.seatgeek.com/2/events")!
        }
        
        // Get the URLRequest
        guard let request = authorizedRequest(url: url) else {
            completion(nil, SeatGeekError.noClientID)
            return nil
        }
        
        let moc = self.moc
        
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return completion(nil, error) }
            do {
                let json = try JSON(data: data)
                let events = try self?.loadEvents(from: json, context: moc)
                print(events?.compactMap { $0.title } ?? [])
                PersistenceController.save(context: moc)
                completion(events, error)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func save() {
        PersistenceController.save(context: moc)
    }
    
    //MARK: Private
    
    private func authorizedRequest(url: URL) -> URLRequest? {
        guard let auth = auth else {
            // fatalError instead?
            NSLog("No valid client ID found. Set client_id in the scheme's environment to your SeatGeek client ID.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    /// Loads Event objects based on the given JSON.
    /// - Parameters:
    ///   - json: A JSON object that has an "events" key containing an array of events.
    ///   - moc: The Core Data context to fetch and create Event objects on.
    /// - Throws: An error if existing Events cannot be fetched.
    /// - Returns: An array of Events that match the contents of the JSON if it is valid.
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
    
    /// Loads an Event object based on the given JSON.
    /// - Parameters:
    ///   - json: A JSON event.
    ///   - existingEvents: A dictionary of existing events keyed by their IDs.
    ///   - moc: The Core Data context to create new Event objects on.
    /// - Returns: The Event matching the JSON if it is valid.
    /// If an Event already exists with the ID in the JSON, that Event is updated based on the JSON content and returned.
    /// If no Event exists with the ID in the JSON, a new Event is created.
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
