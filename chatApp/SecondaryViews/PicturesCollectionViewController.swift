//
//  PicturesCollectionViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/27/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import SKPhotoBrowser

class PicturesCollectionViewController: UICollectionViewController {

    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var allImages: [UIImage] = []
    var allImageLinks: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "All Pictures"
        if allImageLinks.count > 0 {
            downloadImages()
        }
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: screenWidth/4 - 8, height: screenWidth/4 - 8 )
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        collectionView!.collectionViewLayout = layout
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PicturesCollectionViewCell
    
        cell.generateCell(image: allImages[indexPath.row])
        return cell
    }
    

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var images = [SKPhoto]()
        for photo in allImages {
            images.append(SKPhoto.photoWithImage(photo))
        }
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }
    
    func downloadImages() {
        for imageLink in allImageLinks {
            downloadImage(imageUrl: imageLink) { (image) in
                if image != nil {
                    self.allImages.append(image!)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
