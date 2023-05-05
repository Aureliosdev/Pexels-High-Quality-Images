//
//  PhotoCollectionViewCell.swift
//  Pexels High-Quality images
//
//  Created by Aurelio Le Clarke on 03.05.2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let identifier: String = "PhotoCollectionViewCell"
    var photo: Photo?
    override func awakeFromNib() {
        super.awakeFromNib()
   
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(systemName: "photo")
    }
    
    func setup(photo: Photo) {
        self.photo = photo
        
        let mediumPhotoURLString: String = photo.src.medium
        guard let mediumPhotoURL = URL(string: mediumPhotoURLString) else {
            print("Couldnt create URL with given mediumPhotoURLString \(mediumPhotoURLString)")
            return
        }
        self.activityIndicator.startAnimating()
        URLSession.shared.dataTask(with: mediumPhotoURL) { data, response, error in
            if self.urlSame(response: response?.url?.absoluteString) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data  {
                guard self.urlSame(response: response?.url?.absoluteString) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
              
                    
                
            }
            
        }.resume()
    }
    func urlSame(response: String?) -> Bool {
        guard let currentPhotoURL = self.photo?.src.medium, let responseURL  = response else {
            print("Current photo url or response url are absent")
            return false
        }
        
        guard currentPhotoURL == responseURL else  {
            return false
        }
        return true
    }

}
