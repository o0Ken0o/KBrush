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
        
        self.galleryTableView.backgroundColor = ColorScheme.PaleYellow
    }

    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        galleryTableView.deselectRow(at: indexPath, animated: true)
        delegate?.selectedAMasterpiece(galleryVC: self, masterpiece: masterpieces[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "-", handler: {(action: UITableViewRowAction, indexPath: IndexPath) in
            let masterpieceToBeDeleted = self.masterpieces[indexPath.row]
            CoreDataHelper.sharedInstance.deleteAMasterpiece(masterpiece: masterpieceToBeDeleted)
            self.masterpieces.remove(at: indexPath.row)
            self.galleryTableView.deleteRows(at: [indexPath], with: .right)
            
            // need to handle deletting the current masterpiece in drawingViewController
            self.delegate?.deletedAMasterpiece(galleryVC: self, objectId: masterpieceToBeDeleted.objectID)
            
            tableView.isEditing = false
        })
        deleteAction.backgroundColor = UIColor(red: 255.0 / 255.0, green: 117.0 / 255.0, blue: 0.0, alpha: 1.0)
        
        return [deleteAction]
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
            cell.masterpieceImageView.layer.borderColor = ColorScheme.Orange.cgColor
            cell.masterpieceImageView.layer.borderWidth = 1.5
            cell.masterpieceImageView.layer.cornerRadius = 5.0
            cell.masterpieceImageView.backgroundColor = ColorScheme.PaleYellow
        }
        cell.masterpieceNameLabel.text = masterpiece.name
        return cell
    }
}
