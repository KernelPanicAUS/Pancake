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
    
    weak var firstViewController = CreateNewViewController()
    
    var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // For positioning UICollectionView directly below Custom Nav Bar View
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // Goes back one view and adds image to background in Alarm Setup
    @IBAction func success(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
        // Adds background image to Alarm Setup 
        self.firstViewController?.backgroundImage = selectedImage
        self.firstViewController?.firstOpened = false
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
    
    // Fetches image assets
    func fetchImages() {
        // Manipulate fetching options
        let options = PHFetchOptions()
        // Displays images in order - Newest first
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Gets the number of images in library
        fetchResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
        
        // For debugging purposes only
        //print("There are \(fetchResults.count) images in library.")
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
        
        // Creates cell from Storyboard
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath)
        
        // ImageView in cell.
        let cellImageView = cell.viewWithTag(500) as! UIImageView
        
        // Grabs images from library
        let asset = fetchResults.objectAtIndex(indexPath.row) as! PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset,
            targetSize: CGSizeMake(200, 200),
            contentMode: PHImageContentMode.AspectFill,
            options: PHImageRequestOptions(),
            resultHandler: {(result, info) -> Void in
            
                cellImageView.image = result
                
            })
        
        //cellImageView.image = UIImage(named: "setupBG")
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Grabs images from library
        let asset = fetchResults.objectAtIndex(indexPath.row) as! PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset,
            targetSize: CGSizeMake(1000, 1000), // Good Quality Image
            contentMode: PHImageContentMode.AspectFill,
            options: PHImageRequestOptions(),
            resultHandler: {(result, info) -> Void in
                
                // Sets Alarm Setup background image - User Selected Image
                self.selectedImage = result!
                
                
        })

        // Checks selected image
        let cellImageView = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(500)
        let checkmark = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(700)

        // Make background darker and show checkmark
        cellImageView?.alpha = 0.5
        checkmark?.hidden = false
        
    }
    
    // Used to toggle images
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // Unchecks old image
        let cellImageView = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(500)
        let checkmark = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(700)

        // Make background original and hide checkmark
        cellImageView?.alpha = 1
        checkmark?.hidden = true

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
