//
//  MapViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import UserNotifications

class MapViewController: UIViewController, DatabaseListener, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var listenerType: ListenerType = ListenerType.sights
    weak var databaseController: DatabaseProtocol?
    let initialViewPoint = CLLocation(latitude: -37.8102, longitude: 144.9628) // Melbourne Central
    var selectedSight: Sight?

    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestPermissionNotifications()
        mapView.delegate = self
        centerMapOnLocation(initialLocation: initialViewPoint)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    // Geo
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left \(region.identifier).", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        postLocalNotifications(eventTitle: "Exited: \(region.identifier)", eventContent: "You are leaving this area.")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You are in \(region.identifier) now.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        postLocalNotifications(eventTitle: "Entered: \(region.identifier)", eventContent: "\(region.identifier) is 100 metres away.")
    }
    

    /**
     Reference from https://www.youtube.com/watch?feature=youtu.be&v=Q5xT_eEaqsQ&app=desktop
     For building notifications pop-up when the app is running at background
     **/
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if error != nil {
                    print(error!)
                }
                else{
                    if isAuthorized {
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    /**
     Reference from https://www.youtube.com/watch?feature=youtu.be&v=Q5xT_eEaqsQ&app=desktop
     For building notifications pop-up when the app is running at background
     **/
    func postLocalNotifications(eventTitle: String, eventContent: String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = eventContent
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    // set the initial view of the map
    func centerMapOnLocation(initialLocation: CLLocation) {
        let zoomRegion = MKCoordinateRegion(center: initialLocation.coordinate,latitudinalMeters: 3000,longitudinalMeters: 3000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // jump into the selected location point
    func focusOn(sightLocation: MKAnnotation) {
        mapView.selectAnnotation(sightLocation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: sightLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
    }

    /*
     reference from https://stackoverflow.com/questions/51091590/swift-storyboard-creating-a-segue-in-mapview-using-calloutaccessorycontroltapp
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "clickAnnotation", sender: nil)
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
    
    func geoRegion (annotation: Sight) {
        let radiusRange = Double(100)
        let geoLocation = CLCircularRegion(center: annotation.coordinate, radius: radiusRange, identifier: annotation.title!)
        locationManager.startMonitoring(for: geoLocation)
        
        geoLocation.notifyOnExit = true
        geoLocation.notifyOnEntry = true
    }
    
    // put markers
    func onSightsListChange(change: DatabaseChange, sights: [SightEntity]) {
        // remove the previous
        for oneAnnotation in mapView.annotations {
            let geoLocation = CLCircularRegion(center: oneAnnotation.coordinate, radius: 100, identifier: oneAnnotation.title!!)
            locationManager.stopMonitoring(for: geoLocation)
        }
        mapView.removeAnnotations(mapView.annotations) // clear all markers first
        
        for location in sights {
            let annotation = Sight(sight: location)
            mapView.addAnnotation(annotation)
            geoRegion(annotation: annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedSight = mapView.selectedAnnotations[0] as? Sight
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? DetailViewController {
            viewController.sight = selectedSight
        }
    }
}

/*
 Customise the annotation pop-up window
 references from
 https://www.raywenderlich.com/548-mapkit-tutorial-getting-started#toc-anchor-007
 http://swiftdeveloperblog.com/code-examples/mkannotationview-display-custom-pin-image/
 */

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let a = annotation as! Sight
//        let iconName = a.sight?.icon
        // 2
        
        guard let annotation = annotation as? Sight else { return nil }
        // 3
        let identifier = "marker"
        //var view: MKMarkerAnnotationView
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view!.canShowCallout = true
            view!.calloutOffset = CGPoint(x: -5, y: 5)
            view!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            view!.annotation = annotation
        }
        
        let selectedSight = view!.annotation as! Sight
        let selectedSightIconName = selectedSight.icon
        view!.image = UIImage(named: selectedSightIconName!)
        
        return view
    }
    
    
}

