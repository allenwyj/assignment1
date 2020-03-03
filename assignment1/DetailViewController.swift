//
//  DetailViewController.swift
//  assignment1
//
//  Created by Yujie Wu on 3/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var listenerType: ListenerType = ListenerType.sights
    weak var databaseController: DatabaseProtocol?
    var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel!.text = sight!.title
        descLabel!.text = sight!.subtitle
        imageView.image = loadImageData(fileName: sight!.image!)
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
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSightSegue" {
            let viewController = segue.destination as! EditViewController
            viewController.selectedSight = self.sight
        }
    }
}

