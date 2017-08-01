//
//  ImageBroswerController.swift
//  Tachograph
//
//  Created by larryhou on 31/07/2017.
//  Copyright © 2017 larryhou. All rights reserved.
//

import Foundation
import UIKit

class ImageCell:UICollectionViewCell
{
    @IBOutlet var ib_image:UIImageView!
}

class ImageBrowserController:UICollectionViewController, UICollectionViewDelegateFlowLayout, CameraModelDelegate
{
    var takenImages:[CameraModel.CameraAsset] = []
    private var size = CGSize()
    private var insets = UIEdgeInsets()
    private var column = 3
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let fit = fitsize(length: view.frame.width)
        size = CGSize(width: fit.0, height: fit.0/4*3)
        insets = UIEdgeInsets(top: fit.1, left: fit.1, bottom: fit.1, right: fit.1)
        column = fit.2
    }
    
    func fitsize(length:CGFloat, column:CGFloat = 2, margin:CGFloat = 10, limitWidth:CGFloat = 120, limitMargin:CGFloat = 20)->(CGFloat, CGFloat, Int)
    {
        var margin = margin
        var width = (length - (column + 1) * margin)/column
        if width > limitWidth
        {
            width = limitWidth
            let remain = length - column * width - margin * (column + 1)
            if remain > width
            {
                return fitsize(length: length, column: column + 1, margin: margin)
            }
            else
            {
                let gap = (length - column * width)/(column + 1)
                if gap > limitMargin
                {
                    return fitsize(length: length, column: column + 1, margin: margin)
                }
                
                margin = gap
            }
        }
        
        return (width, margin, Int(column))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        CameraModel.shared.delegate = self
        loadModel()
    }
    
    func loadModel()
    {
        CameraModel.shared.fetchImages()
    }
    
    func model(assets: [CameraModel.CameraAsset], type: CameraModel.AssetType)
    {
        takenImages = assets
        collectionView?.reloadData()
    }
    
    func model(update: CameraModel.CameraAsset, type: CameraModel.AssetType)
    {
        takenImages.insert(update, at: 0)
        let index = IndexPath(row: 0, section: 0)
        collectionView?.insertItems(at: [index])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return self.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return self.insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return self.insets.bottom
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return takenImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let data = takenImages[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell
        {
            if let url = AssetManager.shared.get(cache: data.icon)
            {
                cell.ib_image.image = try! UIImage(data: Data(contentsOf: url))
            }
            else
            {
                cell.ib_image.image = UIImage(named: "icon.thm")
                AssetManager.shared.load(url: data.icon, completion:
                {
                    cell.ib_image.image = UIImage(data: $1)
                })
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let max = takenImages.count / column
        if (indexPath.row + 1) / column == max
        {
            loadModel()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print(indexPath)
    }
}
