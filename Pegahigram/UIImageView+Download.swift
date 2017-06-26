//
//  UIImageView+Download.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 29/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImage (from url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            let downloadTask = URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            }
            downloadTask.resume()
        }
    }
}
