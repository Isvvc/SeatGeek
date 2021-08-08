//
//  EventTableViewCell.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/7/21.
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
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var event: Event?
    var seatGeekController: SeatGeekController?
    
    func load(event: Event) {
        self.event = event
        updateViews()
    }
    
    @IBAction func favorite(_ sender: Any) {
        event?.favorite.toggle()
        seatGeekController?.save()
    }
    
    private func updateViews() {
        guard let event = event else { return }
        
        headline.text = event.title
        
        var bodyText = event.location ?? ""
        if let date = event.date {
            bodyText += "\n" + EventTableViewCell.dateFormatter.string(from: date)
        }
        subheadline.text = bodyText
        
        previewImageView.sd_setImage(with: event.image)
        previewImageView.layer.cornerRadius = 8
        previewImageView.clipsToBounds = true
        
        favoriteButton.imageView?.image = event.favorite ? #imageLiteral(resourceName: "heart.fill") : #imageLiteral(resourceName: "heart")
    }
    
}
