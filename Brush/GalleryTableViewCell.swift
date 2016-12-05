//
//  GalleryTableViewCell.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var masterpieceImageView: UIImageView!
    @IBOutlet weak var masterpieceNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
