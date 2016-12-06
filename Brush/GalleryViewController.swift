//
//  GalleryViewController.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit
import CoreData

protocol GalleryViewControllerDelegate {
    func selectedAMasterpiece(galleryVC: GalleryViewController, masterpiece: Masterpiece)
    func deletedAMasterpiece(galleryVC: GalleryViewController, objectId: NSManagedObjectID)
}

class GalleryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var galleryTableView: UITableView!
    private var masterpieces = [Masterpiece]()
    var delegate: GalleryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.delegate = self
        galleryTableView.dataSource = self
        
        masterpieces = CoreDataHelper.sharedInstance.getAllMasterpieces()
    }

    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        galleryTableView.deselectRow(at: indexPath, animated: true)
        delegate?.selectedAMasterpiece(galleryVC: self, masterpiece: masterpieces[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let masterpieceToBeDeleted = masterpieces[indexPath.row]
            CoreDataHelper.sharedInstance.deleteAMasterpiece(masterpiece: masterpieceToBeDeleted)
            masterpieces.remove(at: indexPath.row)
            galleryTableView.deleteRows(at: [indexPath], with: .right)
            
            // need to handle deletting the current masterpiece in drawingViewController
            delegate?.deletedAMasterpiece(galleryVC: self, objectId: masterpieceToBeDeleted.objectID)
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterpieces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = galleryTableView.dequeueReusableCell(withIdentifier: "galleryTableCell", for: indexPath) as! GalleryTableViewCell
        let masterpiece = masterpieces[indexPath.row]
        if let image = masterpiece.image {
            cell.masterpieceImageView.image = UIImage(data: image as Data)
            cell.masterpieceImageView.layer.borderColor = UIColor.gray.cgColor
            cell.masterpieceImageView.layer.borderWidth = 2.0
            cell.masterpieceImageView.backgroundColor = UIColor.white
        }
        cell.masterpieceNameLabel.text = masterpiece.name
        return cell
    }
}
