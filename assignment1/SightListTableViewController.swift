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
    
    //@IBOutlet weak var iconView: NSLayoutConstraint!
    var listenerType: ListenerType = ListenerType.sights
    var mapViewController: MapViewController?
    var locationList = [Sight]()
    var filteredSights: [Sight] = []
    var isAToZ = true
    // coredata
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // coredata
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        //filteredSights = locationList
        
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
    
    // the button allows to sort the list by A-Z and Z-A
    @IBAction func sortButton(_ sender: Any) {
        if isAToZ {
            filteredSights = filteredSights.sorted(by: {$0.title!.lowercased() > $1.title!.lowercased()})
            isAToZ = false
        } else if !isAToZ {
            filteredSights = filteredSights.sorted(by: {$0.title!.lowercased() < $1.title!.lowercased()})
            isAToZ = true
        }
        tableView.reloadData()
    }
    
    // search on list, and it's case senstive
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredSights = locationList.filter({(sight: Sight) -> Bool in
                return sight.title!.contains(searchText)
            })
        } else {
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
        }
        
        locationList = loadingList
        updateSearchResults(for: navigationItem.searchController!)
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
    
    // display information for each row of the list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! SightListViewCell
        let location = self.filteredSights[indexPath.row]

        cell.titleLabel?.text = location.title
        cell.subtitleLabel?.text = location.subtitle
        cell.iconImage?.image = UIImage(named: location.icon!)
        
        return cell
    }
    
    // when user tap on the row, it will jump to the map and focus on the point
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // landscape has split view on the side, no need to change to map view
        if UIDevice.current.orientation.isLandscape == false {
            self.navigationController?.pushViewController(self.mapViewController!, animated: true)
            mapViewController?.focusOn(sightLocation: self.filteredSights[indexPath.row])
        }
        mapViewController?.focusOn(sightLocation: self.filteredSights[indexPath.row])
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // mapViewController?.mapView.removeAnnotation(filteredSights[indexPath.row])
            databaseController!.deleteSight(sight: filteredSights[indexPath.row].sight!)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
