//
//  PushNotifications.swift
//  monTalk
//
//  Created by michael montalbano on 4/3/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import Foundation
import OneSignal

func sendPushNotification(membersToPush: [String], message: String) {
    
    
    let updatedMembers = removeCurrentUserFromMembersArray(members: membersToPush)
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        
        
        let currentUser = FUser.currentUser()!
        
        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.fullname) \n\(message)" ], "ios_badgeType" : "Increase", "ios_badgeCount"  : "1", "include_player_ids" : userPushIds])
    }
    
    
}

func removeCurrentUserFromMembersArray(members: [String]) -> [String] {
    
    var updatedMembers : [String] = []
    for memberID in members {
        if memberID != FUser.currentId() {
            updatedMembers.append(memberID)
        }
    }
    return updatedMembers
}

func getMembersToPush(members: [String], completion: @escaping (_ usersArray: [String]) -> Void) {
    var pushIds : [String] = []
    var count = 0
    
    for memberID in members {
        reference(.User).document(memberID).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else { completion(pushIds); return }
            
            if snapshot.exists {
                let userDictionary = snapshot.data() as! NSDictionary
                
                let fUser = FUser.init(_dictionary: userDictionary)
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count {
                    completion(pushIds)
                }
                
            } else {
                completion(pushIds)
            }
        }
    }
}
