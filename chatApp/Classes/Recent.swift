//
//  Recent.swift
//  chatApp
//
//  Created by michael montalbano on 3/20/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    
    var chatRoomId = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserUsername: "", type: kPRIVATE, users: [user1, user2], avatarOfGroup: nil)
    
    return chatRoomId
}

func createRecent(members: [String], chatRoomId: String, withUserUsername: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    var tempMembers = members
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserId = currentRecent[kUSERID] {
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        for userId in tempMembers {
            createRecentItems(userID: userId, chatroomID: chatRoomId, members: members, withUserUsername: withUserUsername, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
    }
    
}

func createRecentItems(userID: String, chatroomID: String, members: [String], withUserUsername: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    let localreference = reference(.Recent).document()
    let recentId = localreference.documentID
    let date = dateFormatter().string(from: Date())
    var recent: [String:Any]!
    if type == kPRIVATE {
        //private
        var withUser: FUser?
        if users != nil && users!.count > 0 {
            if userID == FUser.currentId() {
                
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
        
        recent = [kRECENTID: recentId, kUSERID: userID, kCHATROOMID: chatroomID, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUser!.fullname, kWITHUSERUSERID: withUser!.objectId, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: type, kAVATAR: withUser!.avatar] as [String:Any]
        
    } else {
        //group
        if avatarOfGroup != nil {
            recent = [kRECENTID: recentId, kUSERID: userID, kCHATROOMID: chatroomID, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUserUsername, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: type, kAVATAR: avatarOfGroup!] as [String:Any]
        }
    }
    
    localreference.setData(recent)
    
}

func restartRecentChat(recent: NSDictionary) {
    if recent[kTYPE] as! String == kPRIVATE {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUsername: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    if recent[kTYPE] as! String == kGROUP {
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUsername: recent[kWITHUSERUSERNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
}

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    if let recentId = recentChatDictionary[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}
