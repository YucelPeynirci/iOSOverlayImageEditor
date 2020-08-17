//
//  Extensions.swift
//  LyreBirdDemo
//
//  Created by Yücel Peynirci on 15.08.2020.
//  Copyright © 2020 Reminis. All rights reserved.
//

import UIKit
import Kingfisher

struct UIImageProvider: ImageDataProvider {

    let cacheKey: String
    let imageData: Data?

    init(image: UIImage, name: String) {
        cacheKey = name
        imageData = image.pngData()
    }

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        if let data = imageData {
            handler(.success(data))
        } else {
            //handler(.failure(Error))
        }
    }
}
