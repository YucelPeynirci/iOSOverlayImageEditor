//
//  OverlayItem.swift
//  LyreBirdDemo
//
//  Created by Yücel Peynirci on 15.08.2020.
//  Copyright © 2020 Reminis. All rights reserved.
//

import UIKit

class OverlayItem:Codable{
    
    static let overlayUrl = "https://lyrebirdstudio.s3-us-west-2.amazonaws.com/candidates/overlay.json"
    
    static var items:[OverlayItem]?
    
    var overlayId:Int!
    var overlayName:String!
    var overlayPreviewIconUrl:String!
    var overlayUrl:String!
    var selected = false
    
    enum CodingKeys: String, CodingKey {
        case overlayId
        case overlayName
        case overlayPreviewIconUrl
        case overlayUrl
    }
    
    static func fetchItems(){
        DispatchQueue.global().async {
            do{
                let data = try Data(contentsOf: URL(string: overlayUrl)!)
                DispatchQueue.main.async {
                    do{
                        items = try JSONDecoder().decode([OverlayItem].self, from: data)
                        items!.insert(noOverlayItem(), at: 0)
                        ViewController.instance?.loadOverlayItems()
                    }catch let err{
                        print(err)
                    }
                }
            }
            catch let err {
                sleep(3)
                fetchItems()
                print(err)
            }
        }
    }
    
    static func noOverlayItem()->OverlayItem{
        let noOverlayItem = OverlayItem()
        noOverlayItem.overlayId = -1
        noOverlayItem.overlayName = ""
        noOverlayItem.overlayPreviewIconUrl = ""
        noOverlayItem.overlayUrl = ""
        return noOverlayItem
    }
}

class OverlayItemView:UICollectionViewCell{
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var toggleIndicator: UIView!
}
