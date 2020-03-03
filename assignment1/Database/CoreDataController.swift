//
//  CoreDataController.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    
    //let DEFAULT_TEAM_NAME = "Default Team"
    var listeners = MulticastDelegate<DatabaseListener>()

    var persistantContainer: NSPersistentContainer
    
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<SightEntity>?
    //var teamHeroesFetchedResultsController: NSFetchedResultsController<SuperHero>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "Model")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // If there are no heroes in the database assume that the app is running
        // for the first time. Create the default team and initial superheroes.
        if fetchAllSights().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSight(name: String, desc: String, lat: String, long: String, icon: String, image: String) -> SightEntity {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "SightEntity", into:
            persistantContainer.viewContext) as! SightEntity
        sight.name = name
        sight.desc = desc
        sight.lat = lat
        sight.long = long
        sight.icon = icon
        sight.image = image
        
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return sight
    }

    func deleteSight(sight: SightEntity) {
        persistantContainer.viewContext.delete(sight)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
      
        if listener.listenerType == ListenerType.sights {
            listener.onSightsListChange(change: .update, sights: fetchAllSights())
//            listener.onSightsListChange(change: .remove, sights: fetchAllSights())
//            listener.onSightsListChange(change: .add, sights: fetchAllSights())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSights() -> [SightEntity] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<SightEntity> = SightEntity.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<SightEntity>(fetchRequest:
                fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                              cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            do {
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [SightEntity]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.sights {
                    listener.onSightsListChange(change: .update, sights: fetchAllSights())
//                    listener.onSightsListChange(change: .remove, sights: fetchAllSights())
//                    listener.onSightsListChange(change: .add, sights: fetchAllSights())
                }
            }
        }
    }

    // images and descriptions are from google and wikipeida
    func createDefaultEntries() {
        let _ = addSight(name: "Queen Victoria Market", desc: "The Queen Victoria Market is the largest and most intact surviving 19th century market in the city. The Melbourne central business district once hosted three major markets, but two of them, the Eastern Market and Western Market, both opened before the Queen Victoria, and were both closed and demolished in the 1960s. Other historic markets survive in Melbourne, such as the inner suburban Prahran Market and South Melbourne Market, though only Prahran has any early buildings. The Queen Victoria Market is historically, architecturally and socially significant and has been listed on the Victorian Heritage Register. It has become an increasingly important tourist attraction in the city of Melbourne.", lat: "-37.8076", long: "144.9568", icon: "two star", image: "qv")
        let _ = addSight(name: "Federation Square", desc: "Federation Square is a venue for arts, culture and public events on the edge of the Melbourne central business district. It covers an area of 3.2 ha at the intersection of Flinders and Swanston Streets built above busy railway lines and across the road from Flinders Street station.", lat: "-37.8180", long: "144.9691", icon: "one star", image: "federation-square")
        let _ = addSight(name: "Old Melbourne Gaol", desc: "The Old Melbourne Gaol is a museum on Russell Street, in Melbourne, Victoria, Australia. It consists of a bluestone building and courtyard, and is located next to the old City Police Watch House and City Courts buildings.", lat: "-37.8078", long: "144.9653", icon: "three star", image: "gaol")
        let _ = addSight(name: "Melbourne Museum", desc: "Melbourne Museum is a natural and cultural history museum located in the Carlton Gardens in Melbourne, Australia.", lat: "-37.8033", long: "144.9717", icon: "one star", image: "melbourne-museum")
        let _ = addSight(name: "State Library Victoria", desc: "Reading makes me happy", lat: "-37.8098", long: "144.9652", icon: "one star", image: "state-library-melbourne")
        let _ = addSight(name: "Shrine of Remembrance", desc: "The Shrine of Remembrance is a war memorial in Melbourne, Victoria, Australia, located in Kings Domain on St Kilda Road.", lat: "-37.8305", long: "144.9734", icon: "three star", image: "shrine-of-remembrance")
        let _ = addSight(name: "Royal Exhibition Building", desc: "The Royal Exhibition Building is a World Heritage Site-listed building in Melbourne, Australia, completed on October 1, 1880, in just 18 months, during the time of the international exhibition movement which presented over 50 exhibitions between 1851 and 1915 in various different places.", lat: "-37.8047", long: "144.9717", icon: "two star", image: "royal-exhibition-building")
        let _ = addSight(name: "Royal Botanic Gardens Victoria - Melbourne Gardens", desc: "Melbourne Gardens was founded in 1846 when land was reserved on the south side of the Yarra River for a new botanic garden.", lat: "-37.8304", long: "144.9796", icon: "one star", image: "royal-botanic-gardens-victoria")
        let _ = addSight(name: "Flinders Street Railway Station", desc: "Flinders Street railway station is a railway station on the corner of Flinders and Swanston Streets in Melbourne, Victoria, Australia.", lat: "-37.8183", long: "144.9671", icon: "one star", image: "flinders-street-railway-station")
        let _ = addSight(name: "St Paul's Cathedral, Melbourne", desc: "St Paul's Cathedral is an Anglican cathedral in Melbourne, Victoria, Australia.", lat: "-37.8170", long: "144.9677", icon: "one star", image: "st-pauls")
        let _ = addSight(name: "The Block Arcade", desc: "The Block Arcade is a shopping arcade in the central business district of Melbourne, Victoria, Australia.", lat: "-37.8158", long: "144.9645", icon: "one star", image: "block-arcade")
        let _ = addSight(name: "The Old Treasury Building", desc: "The Old Treasury Building on Spring Street in Melbourne, was once home to the Treasury Department of the Government of Victoria, but is now a museum of Melbourne history, known as the Old Treasury Building.", lat: "-37.8132", long: "144.9744", icon: "one star", image: "the-old-treasury-building")
        
    }
}

