//
//  VideoMessage.swift
//  chatApp
//
//  Created by michael montalbano on 3/25/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class VideoMessage: JSQMediaItem {
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        videoImageView = nil
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        if let st = status {
            if st == 1 {
                return nil
            }
            if st == 2 && (self.videoImageView == nil) {
                let size = self.mediaViewDisplaySize()
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                let icon = UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: .white)
                let iconview = UIImageView(image: icon)
                
                iconview.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                iconview.contentMode = .center
                
                let imageView = UIImageView(image: self.image!)
                
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconview)
                
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                
                self.videoImageView = imageView
            }
        }
        
        return self.videoImageView
    }
}
