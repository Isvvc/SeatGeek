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
    @IBOutlet weak var bodyLabel: UILabel!
    
    var event: Event?
    var seatGeekController: SeatGeekController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        updateViews()
    }
    
    @IBAction func favorite(_ sender: UIBarButtonItem) {
        event?.favorite.toggle()
        seatGeekController?.save()
        updateViews()
    }
    
    private func updateViews() {
        eventTitle.text = event?.title
        
        var bodyText = event?.location ?? ""
        if let date = event?.date {
            bodyText += "\n" + EventTableViewCell.dateFormatter.string(from: date)
        }
        bodyLabel.text = bodyText
        
        eventImage.sd_setImage(with: event?.image)
        eventImage.layer.cornerRadius = 8
        eventImage.clipsToBounds = true
        
        navigationItem.rightBarButtonItem?.image = event?.favorite ?? false ? #imageLiteral(resourceName: "heart.fill") : #imageLiteral(resourceName: "heart")
    }
    
    private func setUpViews() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: eventImage.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: eventImage.trailingAnchor)
        ]
        view.addSubview(label)
        view.addConstraints(constraints)
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Example description"
    }

}
