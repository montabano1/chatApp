//
//  OutgoingMessages.swift
//  chatApp
//
//  Created by michael montalbano on 3/23/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import Foundation
import UIKit
import OneSignal

class OutgoingMessage {
    let messageDictionary: NSMutableDictionary
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //audio message
    init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, audio, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kAUDIO as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //video message
    init(message: String, video: String, thumbnail: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        let picThumb = thumbnail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        messageDictionary = NSMutableDictionary(objects: [message, video, picThumb, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kLATITUDE as NSCopying, kLONGITUDE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String], title:String) {
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        var group = "private"
        if memberIds.count > 2 {
            group = "group"
        }
        if messageDictionary[kTYPE] as! String == kTEXT {
            reference(.Text).document(messageId).setData(["sender": FUser.currentId(), "receivers": memberIds, "text" : messageDictionary[kMESSAGE], "chatroomId" : chatRoomId, "date" : dateFormatter().string(from: Date()), "messageId": messageId, "avatar": FUser.currentUser()?.avatar, "deleters":[], "type":group, "title":title])
        }
        
        updateRecents(chatRoomId: chatRoomId, lastMessage: messageDictionary[kMESSAGE] as! String)
        
        
        let pushText = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: (messageDictionary[kMESSAGE] as! String))
        
        
        sendNotification(message: pushText, chatroomId: chatRoomId, members: membersToPush)
    }
    
    class func deleteMessage(withId: String, chatRoomId: String) {
        var decryptedMessage = ""
        var x = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kMESSAGEID, isEqualTo: withId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                for recent in snapshot.documents {
                    let recent = recent.data() as NSDictionary
                    decryptedMessage = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: recent[kMESSAGE] as! String)
                    reference(.Message).document(FUser.currentId()).collection(chatRoomId).document(withId).delete()
                    
                    reference(.Text).document(withId).getDocument { (snapshot, error) in
                        guard let snapshot = snapshot else {return}
                        var peeps = snapshot.data()!["receivers"] as! [String]
                        var deleters = snapshot.data()!["deleters"] as! [String]
                        if deleters.contains(FUser.currentId()) {
                            print("This shouldnt happen")
                        } else {
                            deleters.append(FUser.currentId())
                        }
                        if deleters.count == peeps.count {
                            reference(.Text).document(withId).delete()
                        } else {
                            reference(.Text).document(withId).updateData(["deleters" : deleters]) { (error) in
                                if error != nil {
                                    print("error updating deleters")
                                } else {
                                    print("added user to deleters")
                                }
                            }
                        }
                    }
                    
                    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
                        guard let snapshot = snapshot else { return }
                        if !snapshot.isEmpty {
                            for recent in snapshot.documents {
                                let recent = recent.data() as NSDictionary
                                if recent[kUSERID] as! String == FUser.currentId() {
                                    let lastMessageEncrypted = recent[kLASTMESSAGE] as! String
                                    var lastMessage = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: lastMessageEncrypted)
                                    print("\(lastMessage) =?= \(decryptedMessage)")
                                    if lastMessage == decryptedMessage {
                                        lastMessage = "(deleted) " + lastMessage
                                        let encryptedMessageUpdated = Encryption.encryptText(chatRoomId: chatRoomId, message: lastMessage)
                                        updateRecentItem(recent: recent, lastMessage: encryptedMessageUpdated)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    class func updateMessage(withId: String, chatroomId: String, memberIds: [String]) {
        let readDate = dateFormatter().string(from: Date())
        
        let values = [kSTATUS : kREAD, kREADDATE : readDate]
        
        for userId in memberIds {
            reference(.Message).document(userId).collection(chatroomId).document(withId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    if snapshot.data()![kSTATUS] as! String != kREAD {
                        let badgeNum = UIApplication.shared.applicationIconBadgeNumber
                        if badgeNum >= 1 {
                            UIApplication.shared.applicationIconBadgeNumber -= 1
                        }
                    }
                    
                    reference(.Message).document(userId).collection(chatroomId).document(withId).updateData(values)
                }
            }
        }
    }
}
