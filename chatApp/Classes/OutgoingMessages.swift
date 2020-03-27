//
//  OutgoingMessages.swift
//  chatApp
//
//  Created by michael montalbano on 3/23/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import Foundation

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
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        //update recent chat
        
        //send push notification
    }
    
    class func deleteMessage(withId: String, chatRoomId: String) {
        
    }
    
    class func updateMessage(withId: String, chatroomId: String, memberIds: [String]) {
        let readDate = dateFormatter().string(from: Date())
        
        let values = [kSTATUS : kREAD, kREADDATE : readDate]
        
        for userId in memberIds {
            reference(.Message).document(userId).collection(chatroomId).document(withId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    reference(.Message).document(userId).collection(chatroomId).document(withId).updateData(values)
                }
            }
        }
    }
}
