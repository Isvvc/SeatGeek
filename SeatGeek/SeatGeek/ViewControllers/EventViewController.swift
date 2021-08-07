//
//  EventViewController.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/7/21.
//

import UIKit
import SDWebImage

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var event: Event?
    var seatGeekController: SeatGeekController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func favorite(_ sender: UIBarButtonItem) {
        event?.favorite.toggle()
        seatGeekController?.save()
        updateViews()
    }
    
    private func updateViews() {
        eventTitle.text = event?.title
        if let date = event?.date {
            dateLabel.text = EventTableViewCell.dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        eventImage.sd_setImage(with: event?.image)
        eventImage.layer.cornerRadius = 8
        eventImage.clipsToBounds = true
        
        navigationItem.rightBarButtonItem?.image = event?.favorite ?? false ? #imageLiteral(resourceName: "heart.fill") : #imageLiteral(resourceName: "heart")
    }

}
