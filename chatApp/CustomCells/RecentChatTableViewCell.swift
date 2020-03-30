//
//  RecentChatTableViewCell.swift
//  chatApp
//
//  Created by michael montalbano on 3/23/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

protocol RecentChatTableViewDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var messageCounterBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageCounter: UILabel!
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageCounterBackgroundView.layer.cornerRadius = messageCounterBackgroundView.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.messageCounter.text = recentChat[kCOUNTER] as? String
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImg) in
                if avatarImg != nil {
                    self.avatarImage.image = avatarImg!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounter.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBackgroundView.isHidden = false
            self.messageCounter.isHidden = false
        } else {
            self.messageCounterBackgroundView.isHidden = true
            self.messageCounter.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14{
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
    
    

}
