//
//  ViewController.swift
//  LyreBirdDemo
//
//  Created by Yücel Peynirci on 15.08.2020.
//  Copyright © 2020 Reminis. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var renderLayout: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var overlaySpinner: UIActivityIndicatorView!
    @IBOutlet weak var overlayCollection: UICollectionView!
    static var instance:ViewController?
    @IBOutlet weak var overlayImage: UIImageView!
    @IBOutlet weak var overlayLoader: UIActivityIndicatorView!
    var panGesture = UIPanGestureRecognizer()
    var rotationGesture = UIRotationGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.instance = self
        overlayCollection.delegate = self
        overlayCollection.allowsSelection = true
        overlayCollection.allowsMultipleSelection = false
        OverlayItem.fetchItems()
        
        overlayImage.isUserInteractionEnabled = true
        self.view.bringSubviewToFront(overlayImage)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragView(_:)))
        panGesture.delegate = self
        overlayImage.addGestureRecognizer(panGesture)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotateView(_:)))
        rotationGesture.delegate = self
        overlayImage.addGestureRecognizer(rotationGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchView(_:)))
        pinchGesture.delegate = self
        overlayImage.addGestureRecognizer(pinchGesture)
    }
    
    @objc func dragView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        overlayImage.center = CGPoint(x: overlayImage.center.x + translation.x, y: overlayImage.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func rotateView(_ sender:UIRotationGestureRecognizer){
        overlayImage.transform = overlayImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    @objc func pinchView(_ sender:UIPinchGestureRecognizer){
        overlayImage.transform = overlayImage.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func saveAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(mergeImages(imageView: image), nil, nil, nil)
    }
    
    func mergeImages(imageView: UIImageView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
        imageView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func loadOverlayItems(){
        overlayCollection.dataSource = self
        overlayCollection.reloadData()
        overlaySpinner.stopAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OverlayItem.items!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = OverlayItem.items![indexPath.row]
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "overlayItem", for: indexPath) as! OverlayItemView
        if(item.overlayPreviewIconUrl != ""){
            cell.preview.kf.setImage(with: URL(string: item.overlayPreviewIconUrl))
        }else{
            let imageProvider = UIImageProvider(image: UIImage(systemName: "nosign")!, name: "nosign")
            cell.preview.kf.setImage(with: imageProvider)
        }
        cell.toggleIndicator.isHidden = !item.selected
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        overlayLoader.stopAnimating()
        overlayImage.isHidden = true
        let item = OverlayItem.items![indexPath.row]
        item.selected = !item.selected
        for i in OverlayItem.items!{
            if(i.overlayId != item.overlayId){
                i.selected = false
            }
        }
        overlayCollection.reloadData()
        if(item.overlayId == -1){
            DispatchQueue.global(qos: .userInteractive).async {
                usleep(30000)
                DispatchQueue.main.async {
                    item.selected = false
                    self.overlayCollection.reloadData()
                }
            }
        }else if(item.selected){
            overlayImage.isHidden = false
            overlayLoader.isHidden = false
            overlayLoader.startAnimating()
            overlayImage.kf.setImage(with: URL(string: item.overlayUrl)){
                result in
                switch result{
                case .success(let value):
                    self.overlayLoader.stopAnimating()
                    break
                case .failure(let error):
                    break
                }
            }
        }
    }
}
