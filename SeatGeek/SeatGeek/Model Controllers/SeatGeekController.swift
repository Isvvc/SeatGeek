//
//  SeatGeekController.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData
import SwiftyJSON

class SeatGeekController {
    
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
    
    enum SeatGeekError: Error {
        case noClientID
    }
    
    @discardableResult
    func getEvents(completion: @escaping ([Event]?, Error?) -> Void) -> URLSessionDataTask? {
        guard let auth = auth,
              let url = URL(string: "https://api.seatgeek.com/2/events") else {
            completion(nil, SeatGeekError.noClientID)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        
        let moc = self.moc
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data  else { return completion(nil, error) }
            do {
                let json = try JSON(data: data)
                let eventsJSON = json["events"].array
                let events = eventsJSON?.compactMap { Event(json: $0, context: moc) }
                print(events?.compactMap { $0.title } ?? [])
                completion(events, error)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
