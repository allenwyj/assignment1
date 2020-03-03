//
//  NewLocationViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit



class CreateNewSightViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var iconSegment: UISegmentedControl!
    
    // var delegate: NewLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is using for hiding keyboard when tapped anywhere on the view
        // reference from https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
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

    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // check if it is double
    func isValidatedLat(latString: String) -> Bool {
        if !latString.isdouble {
            return false
        }
        
        let lat = (latString as NSString).doubleValue
        
        if lat > -90 && lat < 90 {
            return true
        } else {
            return false
        }
    }

    // check if it is double
    func isValidatedLong(longString: String) -> Bool {
        if !longString.isdouble {
            return false
        }
        
        let long = (longString as NSString).doubleValue
        
        if long > -180 && long < 180 {
            return true
        } else {
            return false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let name = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = descriptionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lat = latitudeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let long = longitudeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let selectedIcon = iconSegment.titleForSegment(at: iconSegment.selectedSegmentIndex)!
        
        if segue.identifier == "addImageSegue" && name != "" && desc != "" && lat != "" && long != "" && isValidatedLat(latString: lat) && isValidatedLong(longString: long) {
            
            let controller = segue.destination as! CameraViewController
            controller.messageExceptImageData.append(name)
            controller.messageExceptImageData.append(desc)
            controller.messageExceptImageData.append(lat)
            controller.messageExceptImageData.append(long)
            controller.messageExceptImageData.append(selectedIcon)
            

        } else {
            var errorMsg = "Please ensure all fields are filled:\n"
            
            if name == "" {
                errorMsg += "- Must provide a name\n"
            }
            if desc == "" {
                errorMsg += "- Must provide description\n"
            }
            if lat == "" {
                errorMsg += "- Must provide latitude\n"
            }
            if long == "" {
                errorMsg += "- Must provide longitude\n"
            }
            if !isValidatedLong(longString: long) || !isValidatedLat(latString: lat) {
                errorMsg += "- Must provide a validate coordinator\n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
        }
    }
}

/* Reference from
 https://stackoverflow.com/questions/44243002/check-string-is-int-or-double-with-extension-in-swift-3
 To check a String is Double or not
 */
extension String  {
    var isdouble: Bool { return Double(self) != nil }
}
