//
//  EditViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 6/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var updateDesc: UITextField!
    @IBOutlet weak var updateName: UITextField!
    
    var selectedSight: Sight?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tap anywhere to hide keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        updateName.text = selectedSight!.sight!.name
        updateDesc.text = selectedSight!.sight!.desc
        currentImage.image = loadImageData(fileName: selectedSight!.image!)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    

    @IBAction func changeImage(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func saveChange(_ sender: Any) {
        guard let image = currentImage.image else {
            displayMessage(title: "Cannot save until a photo has been taken!", message: "Error")
            return
        }
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
        
        // save new entity
        let name = updateName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = updateDesc.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name != "" && desc != "" {
            
            let lat = selectedSight!.sight!.lat
            let long = selectedSight!.sight!.long
            let icon = selectedSight!.sight!.icon
            
            databaseController!.deleteSight(sight: selectedSight!.sight!)
            
            let _ = databaseController!.addSight(name: name, desc: desc, lat: lat!, long: long!, icon: icon!, image: "\(date)")
            
            _ = navigationController?.popToRootViewController(animated: true) // jump back to the list view
        } else {
            var errorMsg = "Please ensure all fields are filled:\n"
            
            if name == "" {
                errorMsg += "- Must provide a name\n"
            }
            if desc == "" {
                errorMsg += "- Must provide description\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
        }
    }
    
    // Load image from application by using path name
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            if fileData == nil {
                image = UIImage(named: "\(fileName)")
            } else {
                image = UIImage(data: fileData!)
            }
        }
        return image
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            currentImage.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        displayMessage(title: "Error", message: "There was an error in getting the image")
    }
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
