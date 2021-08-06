//
//  EventsTableViewController.swift
//  SeatGeek
//
//  Created by Isaac Lyons on 8/6/21.
//

import UIKit
import CoreData

class EventsTableViewController: UITableViewController {
    
    var seatGeekController = SeatGeekController()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: PersistenceController.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for events table frc: \(error)")
        }
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        
        seatGeekController.getEvents { _, _ in
            print("Fetch complete")
        }
    }

    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)

        let event = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = event.title

        return cell
    }
    
    #if DEBUG
    // This exists to test the refresh. Swipe to delete an Event and pull to refresh to see that it appears again.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = fetchedResultsController.object(at: indexPath)
            seatGeekController.moc.delete(event)
        }
    }
    #endif

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        seatGeekController.getEvents { _, _ in
            print("Refresh complete")
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
        }
    }

}

//MARK: Search results updating

extension EventsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

//MARK: Fetched Results Controller Delegate

// Boilerplate code pasted from another project
extension EventsTableViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            let rowCount = tableView.numberOfRows(inSection: newIndexPath.section)
            if self.view.window != nil,
               rowCount > 0 {
                let scrollIndexPath: IndexPath
                if newIndexPath.row >= rowCount {
                    scrollIndexPath = IndexPath(row: rowCount - 1, section: newIndexPath.section)
                } else {
                    scrollIndexPath = newIndexPath
                }
                
                tableView.scrollToRow(at: scrollIndexPath, at: .none, animated: true)
            }
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo,
                           atSectionIndex sectionIndex: Int,
                           for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
    }
}

