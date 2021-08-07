//
//  EventTableViewCell.swift
//  SeatGeek
//
//  Created by Isaac Lyons on 8/7/21.
//

import UIKit
import SDWebImage

class EventTableViewCell: UITableViewCell {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var subheadline: UILabel!
    
    func load(event: Event) {
        headline.text = event.title
        if let date = event.date {
            subheadline.text = EventTableViewCell.dateFormatter.string(from: date)
        } else {
            subheadline.text = nil
        }
        previewImageView.sd_setImage(with: event.image)
    }

}
