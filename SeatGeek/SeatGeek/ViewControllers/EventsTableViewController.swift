//
//  EventsTableViewController.swift
//  SeatGeek
//
//  Created by Elaine Lyons on 8/6/21.
//

import UIKit
import CoreData

class EventsTableViewController: UITableViewController {
    
    var seatGeekController = SeatGeekController()
    var dataTask: URLSessionDataTask?
    var previousSearchResults: [Event] = []
    
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
        
        dataTask = seatGeekController.getEvents { _, _ in
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

        if let eventCell = cell as? EventTableViewCell {
            let event = fetchedResultsController.object(at: indexPath)
            eventCell.seatGeekController = seatGeekController
            eventCell.load(event: event)
        }

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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventVC = segue.destination as? EventViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            eventVC.event = fetchedResultsController.object(at: indexPath)
            eventVC.seatGeekController = seatGeekController
        }
    }
    
    //MARK: Private
    
    @objc
    private func refresh(_ refreshControl: UIRefreshControl) {
        dataTask?.cancel()
        dataTask = seatGeekController.getEvents { _, _ in
            print("Refresh complete")
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
        }
    }
    
    private func frcPredicate(searchString: String?, events: Set<Event>? = nil) -> NSPredicate? {
        guard let searchString = searchString,
              !searchString.isEmpty else { return nil }
        let lowercaseSearch = searchString.lowercased()
        
        var predicates = [NSPredicate(format: "title CONTAINS[c] %@", lowercaseSearch)]
        
        if let events = events {
            predicates.append(NSPredicate(format: "self IN %@", events))
        }
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }

}

//MARK: Search Results Updating

extension EventsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Perform fast, local search if there is no ongoing networking search.
        let searchString = searchController.searchBar.text
        if searchString?.isEmpty ?? true || self.previousSearchResults.isEmpty {
            self.previousSearchResults.removeAll()
            fetchedResultsController.fetchRequest.predicate = frcPredicate(searchString: searchString)
            try? fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        
        // Query the server
        if let searchString = searchString {
            dataTask?.cancel()
            dataTask = seatGeekController.getEvents(search: searchString, completion: { [weak self] events, error in
                guard let events = events,
                      let self = self else { return }
                DispatchQueue.main.async {
                    // Update the FRC to show search results
                    self.fetchedResultsController.fetchRequest.predicate = self.frcPredicate(searchString: searchString, events: Set(events))
                    
                    try? self.fetchedResultsController.performFetch()
                    
                    // Only refrush the table if there are changes.
                    if self.fetchedResultsController.fetchedObjects != self.previousSearchResults {
                        self.tableView.reloadData()
                        self.previousSearchResults = self.fetchedResultsController.fetchedObjects ?? []
                    }
                }
            })
        }
    }
}

//MARK: Fetched Results Controller Delegate

// Boilerplate code pasted from another project
// Animates updates to the table observed by the Fetched Results Controller
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

