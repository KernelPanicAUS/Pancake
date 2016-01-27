//
//  PhotoLibraryViewController.swift
//  Pancake
//
//  Created by Angel Vazquez on 1/26/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var fetchResults = PHFetchResult()
    
    weak var firstViewController = TimeSelectorViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // For positioning UICollectionView directly below Custom Nav Bar View
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(animated: Bool) {
        self.fetchImages()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        // Goes back to previous view
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchImages() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
        
        // For debugging purposes only
        print("There are \(fetchResults.count) images in library.")
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Returns the number of images in library
        return fetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath)
        
        return cell
    }
    
    // Sets the size of the cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        // Adjusts cell size so that only 3 cells fit per row
        let cellSize = (UIScreen.mainScreen().bounds.size.width / 3.0) - 1
        
        // Returns size of cell - Square
        return CGSize(width: cellSize, height: cellSize)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
