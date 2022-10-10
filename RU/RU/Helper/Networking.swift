//
//  Networking.swift
//  RU
//
//  Created by Ehtisham Khalid on 10.10.22.
//

import Foundation
import UIKit

extension URLSession {
    
    func fetchData(at url: URL, completion: @escaping (Swift.Result<Users, Error>) -> Void) {
        self.dataTask(with: url) { data, response, error in
            if data != nil && error == nil {
                do {
                    let fetchData = try JSONDecoder().decode(Users.self, from: data!)
                    completion(.success(fetchData))
                }catch {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
}

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center

        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
            }

        }).resume()
    }
    
    func withRoundedAndBorder() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 2.0
    }
}
