//
//  CameraViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 6/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import CoreData

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var editImageView: UIImageView!
    weak var databaseController: DatabaseProtocol?
    
    var messageExceptImageData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    @IBAction func takePhoto(_ sender: Any) {
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
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = editImageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
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
            
            // save file name
            let _ = databaseController!.addSight(name: messageExceptImageData[0], desc: messageExceptImageData[1], lat: messageExceptImageData[2], long: messageExceptImageData[3], icon: messageExceptImageData[4], image: "\(date)")
            
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            editImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        displayMessage("Error", "There was an error in getting the image.")
    }
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
