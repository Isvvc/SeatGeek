//
//  EventViewController.swift
//  SeatGeek
//
//  Created by Isaac Lyons on 8/7/21.
//

import UIKit
import SDWebImage

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTitle.text = event?.title
        if let date = event?.date {
            dateLabel.text = EventTableViewCell.dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        eventImage.sd_setImage(with: event?.image)
        eventImage.layer.cornerRadius = 8
        eventImage.clipsToBounds = true
    }

}
