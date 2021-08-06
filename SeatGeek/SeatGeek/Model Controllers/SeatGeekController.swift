//
//  SeatGeekController.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import CoreData

class SeatGeekController {
    
    var clientID: String? = ProcessInfo.processInfo.environment["client_id"]
    
    enum SeatGeekError: Error {
        case noClientID
    }
    
    @discardableResult
    func getEvents(completion: @escaping (String?, Error?) -> Void) -> URLSessionDataTask? {
        guard let clientID = clientID,
              let url = URL(string: "https://api.seatgeek.com/2/events") else {
            completion(nil, SeatGeekError.noClientID)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Basic \(clientID):", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = String(data: data, encoding: .utf8) else { return completion(nil, error) }
            print(json)
            completion(json, error)
        }
        task.resume()
        return task
    }
}
