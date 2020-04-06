//
//  CallTableViewCell.swift
//  monTalk
//
//  Created by michael montalbano on 4/6/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(call: CallClass) {
        
        dateLabel.text = formatCallTime(date: call.callDate)
        if call.callerId == FUser.currentId() {
            statusLabel.text = "Outgoing"
            fullnameLabel.text = call.withUserFullName
            avatarImageView.image = UIImage(named: "outgoing")
        } else {
            statusLabel.text = "Incoming"
            fullnameLabel.text = call.callerFullName
            avatarImageView.image = UIImage(named: "incoming")
        }
        
    }

}
