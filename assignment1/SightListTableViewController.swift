//
//  LocationTableViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class SightListTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    
    var listenerType: ListenerType = ListenerType.sights
    
    var mapViewController: MapViewController?
    var locationList = [Sight]()
    var filteredSights: [Sight] = []
    //var allSights: [LocationAnnotation] = []

    // coredata
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // coredata
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredSights = locationList
        
        // This view controller decides how the search controller is presented.
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sights"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // coredata
        definesPresentationContext = true
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredSights = locationList.filter({(sight: Sight) -> Bool in
                return sight.name!.lowercased().contains(searchText)
            })
        }
        else {
            filteredSights = locationList
        }
        
        tableView.reloadData()
    }
    
    // load data on the table list
    func onSightsListChange(change: DatabaseChange, sights: [SightEntity]) {
        var loadingList = [Sight]()
        
        for location in sights {
            let annotation = Sight(sight: location)
            loadingList.append(annotation)
            mapViewController?.mapView.addAnnotation(annotation)
        }
        
        locationList = loadingList
        updateSearchResults(for: navigationItem.searchController!)
    }

    func locationAnnotationAdded(annotation: Sight) {
        locationList.append(annotation)
        mapViewController?.mapView.addAnnotation(annotation)
        tableView.insertRows(at: [IndexPath(row: locationList.count - 1, section: 0)], with: .automatic)
    }
    
    // coredata
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSights.count
    }

    // Display text in the list for each cell item
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let annotation = self.locationList[indexPath.row]
        
        cell.textLabel?.text = annotation.name
        cell.detailTextLabel?.text = "Lat: \(annotation.coordinate.latitude) Long: \(annotation.coordinate.longitude)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // landscape has split view on the side, no need to change to map view
        if UIDevice.current.orientation.isLandscape == false {
            self.navigationController?.pushViewController(self.mapViewController!, animated: true)
        }
        mapViewController?.focusOn(annotation: self.locationList[indexPath.row])
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            databaseController!.deleteSight(sight: filteredSights[indexPath.row].sight!)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


}
