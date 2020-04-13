//
//  ChatViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/23/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore
import SKPhotoBrowser

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQAudioRecorderViewControllerDelegate {
    
    let appDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    var chatroomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    var badgeDecremented = false
    var startMessage: String?
    var timeStampDate: Date?
    
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener: ListenerRegistration?
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var typingCounter = 0
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages = [[Any]]()
    
    var initialLoadComplete = false
    
    var jsqAvatarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    var tagNum = 1
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.green)
    
    var incomingBubble =  JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.orange)
    
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    let subtitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        return subTitle
    }()
    
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
        scrollToBottom(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatroomId)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatroomId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTypingObserver()
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(delete))
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        if isGroup! {
            getCurrentGroup(withId: chatroomId)
        }
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        jsqAvatarDictionary = [ : ]
        
        setCustomTitle()
        
        loadMessages()
        
        
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()?.fullname
        
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        
    }
    
    @objc func printme(_ sender: UITapGestureRecognizer) {
        let frame = sender.view?.superview?.frame
        let tag = sender.view!.tag - 1
        let messageDate = Date() //messages[tag].date
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: messageDate)
        let minutes = calendar.component(.minute, from: messageDate)
        let timeLabel = UILabel(frame: frame!)
        sender.view?.superview?.superview?.addSubview(timeLabel)
        //timeLabel.text = " \(hour):\(minutes) "
        timeLabel.text = String(tag)
        timeLabel.layer.cornerRadius = 10
        timeLabel.sizeToFit()
        timeLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        timeLabel.textColor = .white
        
        if frame!.minX > 32 {
            
            timeLabel.center.x -= (timeLabel.frame.width + 10)
            timeLabel.center.y = sender.view?.superview?.center.y as! CGFloat
            
        } else if frame!.minX == 32 {
            timeLabel.center.x += (frame!.width + 10)
            timeLabel.center.y = sender.view?.superview?.center.y as! CGFloat
        }
        UIView.animate(withDuration: 1) {
            timeLabel.alpha = 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let tap = UITapGestureRecognizer(target: self, action: #selector(printme))
        let data = messages[indexPath.row]
        
        
        if data.senderId == FUser.currentId() {
            cell.textView?.contentInset = UIEdgeInsets(top: 6, left: 3, bottom: 0, right: 0)
            cell.textView?.textColor = .black
            cell.textView?.layer.borderColor = UIColor.green.cgColor
            cell.textView?.layer.borderWidth = 2
            cell.textView?.layer.cornerRadius = 15
            cell.textView?.backgroundColor = .white
            
            
        } else {
            cell.textView?.contentInset = UIEdgeInsets(top: 6, left: 3, bottom: 0, right: 0)
            cell.textView?.textColor = .black
            cell.textView?.layer.borderColor = UIColor.orange.cgColor
            cell.textView?.layer.borderWidth = 2
            cell.textView?.layer.cornerRadius = 15
            cell.textView?.backgroundColor = .white
            
        }
        if tagNum <= messages.count {
            cell.textView?.tag = tagNum
            tagNum += 1
            cell.textView?.isUserInteractionEnabled = true
            //cell.textView?.addGestureRecognizer(tap)
        }
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        
        if ((message[kSENDERID] as! String) != FUser.currentId()) && (isGroup == true) {
            if indexPath.row == 0 || shouldShowTimestamp(indexPath: indexPath){
                return NSAttributedString(string: message[kSENDERNAME] as! String)
            } else {
                let lastMessage = objectMessages[indexPath.row - 1]
                if lastMessage[kSENDERID] as! String !=  message[kSENDERID] as! String {
                    return NSAttributedString(string: message[kSENDERNAME] as! String)
                }
            }
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = objectMessages[indexPath.row]
        if ((message[kSENDERID] as! String) != FUser.currentId()) && isGroup == true  {
            return 15.0
        }
        return 0.0
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        if shouldShowTimestamp(indexPath: indexPath) == true {
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    func shouldShowTimestamp(indexPath: IndexPath) -> Bool {
        let message = messages[indexPath.row]
        let currentMessageDate = message.date
        if indexPath.item == 0 {
            return true
        } else {
            let previousMessageDate = messages[indexPath.row - 1].date
            if currentMessageDate! > previousMessageDate! + 600 {
                return true
            }
        }
        return false
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.row]
        if shouldShowTimestamp(indexPath: indexPath) == true {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        
        let status: NSAttributedString!
        
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "✔︎")
        }
        
        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        var avatar: JSQMessageAvatarImageDataSource
        if let testAvatar = jsqAvatarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        return avatar
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.PresentMultyCamera(target: self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        }
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            camera.PresentVideoLibrary(target: self, canEdit: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            if let currentPopoverpresentationcontroller = optionMenu.popoverPresentationController {
                currentPopoverpresentationcontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentationcontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            let audioVC = AudioViewController(delegate_: self)
            audioVC.presentAudioRecorder(target: self)
            
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {

        
        let messageDictionary = objectMessages[indexPath.row]
        let messageType = messageDictionary[kTYPE] as! String
        
        switch messageType {
        case kTEXT:
            let message = messages[indexPath.row]
            print(message)
        case kPICTURE:
            let idx = getPictureNumber(indexPath: indexPath)
            var allImages = [UIImage]()
            for imageLink in allPictureMessages {
                downloadImage(imageUrl: imageLink[0] as! String) { (image) in
                    if image != nil {
                        allImages.append(image!)
                    }
                }
            }
            
            var images = [SKPhoto]()
            for photo in allImages {
                images.append(SKPhoto.photoWithImage(photo))
            }
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(idx)
            present(browser, animated: true, completion: {})

        case kLOCATION:
            
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mapViewController") as! MapViewController
            
            mapView.location = mediaItem.location
            
            self.navigationController?.pushViewController(mapView, animated: true)
            
        case kVIDEO:
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! VideoMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            
            let session = AVAudioSession.sharedInstance()
            
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            
            moviePlayer.player = player
            
            self.present(moviePlayer, animated: true) {
                moviePlayer.player!.play()
            }
        default:
            print("unknown message tapped")
        }
    }
    
    func getPictureNumber(indexPath: IndexPath) -> Int {
        let index = allPictureMessages.count - 1
        let message = messages[indexPath.row]
        let date = message.date
        var i = 0
        while i < allPictureMessages.count {
            if date == (allPictureMessages[i][1] as! Date) {
                return i
            }
            i += 1
        }
        
        return index
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let senderId = messages[indexPath.row].senderId
        var selectedUser: FUser?
        
        if senderId == FUser.currentId() {
            presentUserProfile(forUser: FUser.currentUser()!)
        } else {
            for user in withUsers {
                if user.objectId == senderId {
                    selectedUser = user
                }
            }
            presentUserProfile(forUser: selectedUser!)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if messages[indexPath.row].isMediaMessage {
            if action.description == "delete:" {
                return true
            } else {
                return false
            }
        } else {
            if action.description == "delete:" || action.description == "copy:" {
                return true
            } else {
                return false
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        let messageId = objectMessages[indexPath.row][kMESSAGEID] as! String
        objectMessages.remove(at: indexPath.row)
        messages.remove(at: indexPath.row)
        
        OutgoingMessage.deleteMessage(withId: messageId, chatRoomId: chatroomId)
    }
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        var outgoingMessage : OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        if let text = text {
            let encryptedText = Encryption.encryptText(chatRoomId: chatroomId, message: text)
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        if let pic = picture {
            uploadImage(image: pic, chatRoomId: chatroomId, view: self.navigationController!.view) { (imageLink) in
                if imageLink != nil {
                    
                    let encryptedText = Encryption.encryptText(chatRoomId: self.chatroomId, message: "[\(kPICTURE)]")
                    
                    outgoingMessage = OutgoingMessage(message: encryptedText, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatroomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush, title: self.titleName)
                    
                    self.allPictureMessages.append([imageLink!,date])
                }
            }
            
            return
        }
        // send video
        
        if let video = video {
            let videoData = NSData(contentsOfFile: video.path!)
            let datathumbNail = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
            uploadVideo(video: videoData!, chatRoomId: chatroomId, view: self.navigationController!.view) { (videoLink) in
                if videoLink != nil {
                    let encryptedText = Encryption.encryptText(chatRoomId: self.chatroomId, message: "[\(kVIDEO)]")
                    outgoingMessage = OutgoingMessage(message: encryptedText, video: videoLink!, thumbnail: datathumbNail! as NSData, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kVIDEO)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatroomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush, title: self.titleName)
                }
            }
            
            return
        }
        
        // send audio
        
        if let audioPath = audio {
            uploadAudio(autioPath: audioPath, chatRoomId: chatroomId, view: self.navigationController!.view) { (audioLink) in
                if audioLink != nil {
                    let encryptedText = Encryption.encryptText(chatRoomId: self.chatroomId, message: "[\(kPICTURE)]")
                    outgoingMessage = OutgoingMessage(message: encryptedText, audio: audioLink!, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kAUDIO)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage!.sendMessage(chatRoomId: self.chatroomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush, title: self.titleName)
                }
            }
            return
        }
        
        //send location message
        
        if location != nil {
            
            let lat: NSNumber = NSNumber(value: appDelegate.coordinates!.latitude)
            let long: NSNumber = NSNumber(value: appDelegate.coordinates!.longitude)
            
            let encryptedText = Encryption.encryptText(chatRoomId: self.chatroomId, message: "[\(kPICTURE)]")
            
            outgoingMessage = OutgoingMessage(message: encryptedText, latitude: lat, longitude: long, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kLOCATION)
            
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        loadedMessagesCount += 1
        loadedMessages.append(outgoingMessage!.messageDictionary)
        outgoingMessage!.sendMessage(chatRoomId: chatroomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush, title: self.titleName)
    }
    
    func loadMessages() {
        
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatroomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                snapshot.documentChanges.forEach { (diff) in
                    if diff.type == .modified {
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                }
            }
            
        })
        reference(.Message).document(FUser.currentId()).collection(chatroomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                self.listenForNewChats()
                return
            }
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            self.getPictureMessages()
            self.getOldMessagesInBackground()
            self.listenForNewChats()
        }
    }
    
    
    
    func listenForNewChats() {
        var lastMessageDate = "0"
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatroomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if (diff.type == .added) {
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE] {
                            if self.legitTypes.contains(type as! String) {
                                if type as! String == kPICTURE {
                                    self.addNewPictureMessageLink(link: item[kPICTURE] as! String, date: dateFormatter().date(from: item[kDATE] as! String)!)
                                }
                                if self.insertInitialLoadMessages(messageDictionary: item) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func getOldMessagesInBackground() {
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            reference(.Message).document(FUser.currentId()).collection(chatroomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                self.getPictureMessages()
                
                self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
            }
        }
    }
    
    func insertMessages() {
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
        
    }
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            OutgoingMessage.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatroomId: chatroomId, memberIds: memberIds)
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatroomId)
        
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    func updateMessage(messageDictionary: NSDictionary) {
        for index in 0 ..< objectMessages.count {
            let temp = objectMessages[index]
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objectMessages[index] = messageDictionary
                self.collectionView!.reloadData()
            }
        }
    }
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        if loadOld {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatroomId)
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    @objc func backAction() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "tabBar") as! UITabBarController
        
        mainView.selectedIndex = 1
        
        let window = self.view.window
        window?.rootViewController = mainView
        UIView.transition(with: window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    @objc func infoButtonPressed() {
        let mediaVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "mediaView") as! PicturesCollectionViewController
        var allImages = [String]()
        for img in allPictureMessages {
            allImages.append(img[0] as! String)
        }
        mediaVC.allImageLinks = allImages
        
        self.navigationController?.pushViewController(mediaVC, animated: true)
    }
    
    @objc func showGroup() {
        let groupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "groupView") as! GroupViewController
        groupVC.group = group!
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    @objc func showProfile() {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = withUsers.first!
            self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    func presentUserProfile(forUser: FUser) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = forUser
            self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func createTypingObserver() {
        typingListener = reference(.Typing).document(chatroomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != FUser.currentId() {
                        let typing = data.value as! Bool
                        self.showTypingIndicator = typing
                        
                        if typing {
                            //MONTE
                            self.scrollToBottom(animated: true)
                            
                        }
                    }
                }
            } else {
                reference(.Typing).document(self.chatroomId).setData([FUser.currentId() : false])
            }
        })
    }
    
    func typingCounterStart() {
        typingCounter += 1
        typingCounterSave(typing: true)
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            typingCounterSave(typing: false)
        }
    }
    
    func typingCounterSave(typing: Bool) {
        reference(.Typing).document(chatroomId).updateData([FUser.currentId() : typing])
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        typingCounterStart()
        return true
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool) {
        if isSend { self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        } else { self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func setCustomTitle() {
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        } else {
            avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
        }
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            self.getAvatarImages()
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
        }
    }
    
    func setUIForSingleChat() {
        let withUser = withUsers.first!
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        titleName = withUser.fullname
        titleLabel.text = titleName
        if withUser.isOnline {
            subtitleLabel.text = "Online"
        } else {
            subtitleLabel.text = "Offline"
        }
        avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
    }
    
    func setUIForGroupChat() {
        imageFromData(pictureData: (group![kAVATAR] as! String)) { (image) in
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: [])
            }
        }
        
        titleLabel.text = titleName
        subtitleLabel.text = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func getAvatarImages() {
        if showAvatars {
            collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            avatarImageFrom(fUser: FUser.currentUser()!)
            
            for user in withUsers {
                avatarImageFrom(fUser: user)
            }
        }
    }
    
    func avatarImageFrom( fUser: FUser) {
        if fUser.avatar != "" {
            dataImageFromString(pictureString: fUser.avatar) { (imageData) in
                if imageData == nil {
                    return
                }
                if self.avatarImageDictionary != nil {
                    //update avatar if we have one
                    self.avatarImageDictionary!.removeObject(forKey: fUser.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: fUser.objectId as NSCopying)
                } else {
                    self.avatarImageDictionary = [fUser.objectId: imageData!]
                }
                
                self.createJSQAvatars(avatarDictionary: self.avatarImageDictionary)
                
            }
        }
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?) {
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        if avatarDictionary != nil {
            
            for userId in memberIds {
                if let avatarImageData = avatarDictionary![userId] {
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImageData as! Data), diameter: 70)
                    self.jsqAvatarDictionary?.setValue(jsqAvatar, forKey: userId)
                } else {
                    self.jsqAvatarDictionary!.setValue(defaultAvatar, forKey: userId)
                }
            }
            
            self.collectionView.reloadData()
            
        }
    }
    
    func haveAccessToUserLocation() -> Bool {
        if appDelegate.locationManager != nil {
            return true
        } else {
            ProgressHUD.showError("Please give access to location in settings")
            return false
        }
    }
    
    func addNewPictureMessageLink(link: String, date: Date) {
        allPictureMessages.append([link, date])
    }
    
    func getPictureMessages() {
        allPictureMessages = []
        
        for message in loadedMessages {
            if message[kTYPE] as! String == kPICTURE {
                allPictureMessages.append([message[kPICTURE] as! String, dateFormatter().date(from: message[kDATE] as! String)])
            }
        }
    }
    
    func readTimeFrom(dateString: String) -> String {
        let date = dateFormatter().date(from: dateString)
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        return currentDateFormat.string(from: date!)
    }
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tempMessages = allMessages
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    //remove message
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
        
    }
    
    func removeListeners() {
        if typingListener != nil {
            typingListener!.remove()
        }
        if newChatListener != nil {
            newChatListener?.remove()
        }
        if updatedChatListener != nil {
            updatedChatListener?.remove()
        }
    }
    
    func getCurrentGroup(withId: String) {
        reference(.Group).document(withId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                self.group = snapshot.data() as! NSDictionary
                self.setUIForGroupChat()
            }
        }
    }
    
}

extension JSQMessagesInputToolbar {

    override open func didMoveToWindow() {

        super.didMoveToWindow()

        guard let window = window else { return }

        if #available(iOS 11.0, *) {

            let anchor = window.safeAreaLayoutGuide.bottomAnchor

            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true

        }

    }

}
