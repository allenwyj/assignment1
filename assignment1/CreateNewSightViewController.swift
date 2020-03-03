//
//  NewLocationViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit

//protocol NewLocationDelegate {
//    func locationAnnotationAdded(annotation: LocationAnnotation)
//}

class CreateNewSightViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    // var delegate: NewLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
        latitudeTextField.text = "\(currentLocation.latitude)"
        longitudeTextField.text = "\(currentLocation.longitude)"
    } else {
            let alertController = UIAlertController(title: "Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveLocation(_ sender: Any) {
//        let location = LocationAnnotation(newTitle: titleTextField.text!, newSubtitle: descriptionTextField.text!, lat: Double(latitudeTextField.text!)!, long: Double(longitudeTextField.text!)!)
//        delegate?.locationAnnotationAdded(annotation: location)
        if titleTextField.text != "" && descriptionTextField.text != "" && latitudeTextField.text != "" && longitudeTextField.text != "" {
            let name = titleTextField.text!
            let desc = descriptionTextField.text!
            let lat = latitudeTextField.text!
            let long = longitudeTextField.text!
            
            let _ = databaseController!.addSight(name: name, desc: desc, lat: lat, long: long, icon: "a", image: "bbb")
            navigationController?.popViewController(animated: true)
            
        }
        
        var errorMsg = "Please ensure all fields are filled:\n"
        
        if titleTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if descriptionTextField.text == "" {
            errorMsg += "- Must provide description\n"
        }
        if latitudeTextField.text == "" {
            errorMsg += "- Must provide latitude\n"
        }
        if longitudeTextField.text == "" {
            errorMsg += "- Must provide longitude\n"
        }
        
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
