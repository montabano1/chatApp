//
//  OrgTeamRegistrationViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/3/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import SearchTextField

class OrgTeamRegistrationViewController: UIViewController {

    var joinOrgButton = UIButton()
    var joinOrgLabel = UILabel()
    var startOrgButton = UIButton()
    var startOrgLabel = UILabel()
    var skipButton = UIButton()
    var skipLabel = UILabel()
    var threeButtons = [UIButton]()
    var threeLabels = [UILabel]()
    var searchField = SearchTextField()
    
    var allOrgs = [String]()
    
    
    
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = view.bounds.width
        
        threeButtons = [joinOrgButton, startOrgButton, skipButton ]
        threeLabels = [joinOrgLabel, startOrgLabel, skipLabel]
        var i = 1
        for button in threeButtons {
            button.layer.borderWidth = 1
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            button.layer.cornerRadius = 10
            button.tag = i
            i += 1
        }
        view.addSubview(searchField)
        searchField.alpha = 0
        joinOrgButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        joinOrgButton.setImage(UIImage(named: "joinTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        joinOrgButton.imageView?.contentMode = .center
        joinOrgButton.center.x = view.center.x
        joinOrgButton.center.y = view.center.y / 2
        joinOrgButton.addTarget(self, action: #selector(joinOrganization), for: .touchUpInside)
        view.addSubview(joinOrgButton)
        joinOrgLabel.frame = CGRect(x: joinOrgButton.frame.minX, y: joinOrgButton.frame.maxY + 5, width: width/4, height: 30)
        joinOrgLabel.text = "Join an \n organization"
        joinOrgLabel.numberOfLines = 2
        joinOrgLabel.textAlignment = .center
        joinOrgLabel.font = UIFont.systemFont(ofSize: 17.5)
        joinOrgLabel.sizeToFit()
        joinOrgLabel.center.x = joinOrgButton.center.x
        view.addSubview(joinOrgLabel)
        
        startOrgButton.frame = CGRect(x: 7*width/12, y: 1, width: width/4, height: width/4)
        startOrgButton.setImage(UIImage(named: "createTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        startOrgButton.imageView?.contentMode = .center
        startOrgButton.center.x = view.center.x
        startOrgButton.center.y = view.center.y
        startOrgButton.addTarget(self, action: #selector(startOrganization), for: .touchUpInside)
        view.addSubview(startOrgButton)
        startOrgLabel.frame = CGRect(x: startOrgButton.frame.minX, y: startOrgButton.frame.maxY + 5, width: width/4, height: 30)
        startOrgLabel.text = "Create an \n organization"
        startOrgLabel.numberOfLines = 2
        startOrgLabel.textAlignment = .center
        startOrgLabel.font = UIFont.systemFont(ofSize: 17.5)
        startOrgLabel.sizeToFit()
        startOrgLabel.center.x = startOrgButton.center.x
        view.addSubview(startOrgLabel)
        
        skipButton.frame = CGRect(x: width/6, y: 1, width: width/4, height: width/4)
        skipButton.setImage(UIImage(named: "skipTeam")?.scaleImageToSize(newSize: CGSize(width: width/5, height: width/5)), for: [])
        skipButton.imageView?.contentMode = .center
        skipButton.center.x = view.center.x
        skipButton.center.y = view.center.y * 1.5
        skipButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        view.addSubview(skipButton)
        skipLabel.frame = CGRect(x: skipButton.frame.minX, y: skipButton.frame.maxY + 5, width: width/4, height: 30)
        skipLabel.text = "Skip \n joining"
        skipLabel.numberOfLines = 2
        skipLabel.textAlignment = .center
        skipLabel.font = UIFont.systemFont(ofSize: 17.5)
        skipLabel.sizeToFit()
        skipLabel.center.x = skipButton.center.x
        view.addSubview(skipLabel)
    }
    
    @objc func joinOrganization() {
        reference(.Organization).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { print("yyyy") ; return }
            for recent in snapshot.documents {
                let data = recent.data()
                self.allOrgs.append(data["Name"] as! String)
            }

            self.searchField.filterStrings(self.allOrgs)
        }
        self.searchField.frame = CGRect(x: 0, y: 0, width: self.width * 0.8, height: 50)
        self.searchField.center = self.view.center
        UIView.animate(withDuration: 0.5) {
            for button in self.threeButtons {
                button.alpha = 0
            }
            
            for button in self.threeLabels {
                button.alpha = 0
            }
            self.searchField.layer.borderWidth = 2
            self.searchField.layer.cornerRadius = 5
            self.searchField.setLeftPaddingPoints(10)
            self.searchField.placeholder = "Enter Organization Name"
            
            
            self.searchField.theme.cellHeight = 50
            self.searchField.theme.font = UIFont.systemFont(ofSize: 20)
            self.searchField.maxNumberOfResults = 5
            self.searchField.maxResultsListHeight = 200
            self.searchField.alpha = 1
        }
        
    }
    
    @objc func startOrganization() {
        
    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true)
    }


}
