//
//  PicturesCollectionViewCell.swift
//  chatApp
//
//  Created by michael montalbano on 3/27/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFill
    }
    
    
}
