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
    
    enum SeatGeekError: Error {
        case noClientID
    }
    
    @discardableResult
    func getEvents(completion: @escaping ([JSON]?, Error?) -> Void) -> URLSessionDataTask? {
        guard let clientID = clientID,
              let url = URL(string: "https://api.seatgeek.com/2/events") else {
            completion(nil, SeatGeekError.noClientID)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(clientID):", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data  else { return completion(nil, error) }
            do {
                let json = try JSON(data: data)
                print(json)
                let events = json["events"].array
                completion(events, error)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
