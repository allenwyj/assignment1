//
//  DatabaseProtocol.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case sights
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onSightsListChange(change: DatabaseChange, sights: [SightEntity])
}

protocol DatabaseProtocol: AnyObject {
    func addSight(name: String, desc: String, lat: String, long: String, icon: String, image: String) -> SightEntity
    func deleteSight(sight: SightEntity)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
