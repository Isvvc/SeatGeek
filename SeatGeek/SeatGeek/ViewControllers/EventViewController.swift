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
        // Example description label
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
        
        // Pinch to zoom
        eventImage.isUserInteractionEnabled = true
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        pinchRecognizer.delegate = self
        eventImage.addGestureRecognizer(pinchRecognizer)
        
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        rotateRecognizer.delegate = self
        eventImage.addGestureRecognizer(rotateRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panRecognizer.delegate = self
        eventImage.addGestureRecognizer(panRecognizer)
        
        // Double tap to zoom or unzoom
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        eventImage.addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc
    private func pinch(_ sender: UIPinchGestureRecognizer) {
        guard sender.view == eventImage else { return }
        if sender.state == .ended,
           // Check if the scale is less than 1
           sqrt(Double(eventImage.transform.a * eventImage.transform.a + eventImage.transform.c * eventImage.transform.c)) < 1 {
            UIView.animate(withDuration: 0.1) {
                sender.view?.transform = .identity
            }
        } else {
            eventImage.transform = eventImage.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    @objc
    private func rotate(_ sender: UIRotationGestureRecognizer) {
        guard sender.view == eventImage else { return }
        eventImage.transform = eventImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    @objc
    private func pan(_ sender: UIPanGestureRecognizer) {
        guard sender.view == eventImage else { return }
        let translation = sender.translation(in: eventImage)
        eventImage.transform = eventImage.transform.translatedBy(x: translation.x, y: translation.y)
        sender.setTranslation(.zero, in: eventImage)
    }
    
    @objc
    private func doubleTap(_ sender: UITapGestureRecognizer) {
        guard let eventImage = sender.view,
              eventImage == self.eventImage else { return }
        UIView.animate(withDuration: 0.1) {
            if eventImage.transform == .identity {
                // Zoom in
                eventImage.transform = eventImage.transform.scaledBy(x: 2, y: 2)
            } else {
                // Reset zoom
                eventImage.transform = .identity
            }
        }
    }

}

extension EventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
