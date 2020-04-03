//
//  GroupMemberCollectionViewCell.swift
//  monTalk
//
//  Created by michael montalbano on 3/31/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCollectionViewCell: UICollectionViewCell {
    var indexPath: IndexPath!
    var delegate: GroupMemberCollectionViewDelegate?
    
    
    
    
    @IBOutlet weak var myView: UIView!
    var firstNameLabel = UILabel()
    var lastNameLabel = UILabel()
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    func generateCell(user:FUser, indexPath: IndexPath) {
        self.indexPath = indexPath
        firstNameLabel.text = user.firstname
        lastNameLabel.text = user.lastname
        
        firstNameLabel.font = UIFont.systemFont(ofSize: 18)
        firstNameLabel.frame = CGRect(x: 0, y: 80, width: 100, height: 20)
        firstNameLabel.textAlignment = .center
        firstNameLabel.sizeToFit()
        firstNameLabel.center.x = myView.center.x
        myView.addSubview(firstNameLabel)
        
        lastNameLabel.font = UIFont.systemFont(ofSize: 18)
        lastNameLabel.frame = CGRect(x: 0, y: firstNameLabel.frame.maxY, width: 100, height: 1)
        lastNameLabel.textAlignment = .center
        lastNameLabel.sizeToFit()
        lastNameLabel.center.x = myView.center.x
        myView.addSubview(lastNameLabel)
        
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        deleteButton.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        deleteButton.layer.borderWidth = 1
        
        //avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                    
                }
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
}
