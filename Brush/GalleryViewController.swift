//
//  GalleryViewController.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var galleryTableView: UITableView!
    private var masterpieces = [Masterpiece]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.delegate = self
        galleryTableView.dataSource = self
        
        masterpieces = CoreDataHelper.sharedInstance.getAllMasterpieces()
    }

    //MARK: UITableViewDelegate
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterpieces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = galleryTableView.dequeueReusableCell(withIdentifier: "galleryTableCell", for: indexPath) as! GalleryTableViewCell
        let masterpiece = masterpieces[indexPath.row]
        if let image = masterpiece.image {
            cell.masterpieceImageView.image = UIImage(data: image as Data)
        }
        cell.masterpieceNameLabel.text = masterpiece.name
        return cell
    }
}
