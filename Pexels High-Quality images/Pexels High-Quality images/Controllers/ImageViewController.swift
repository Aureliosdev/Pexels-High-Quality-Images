//
//  ImageViewController.swift
//  Pexels High-Quality images
//
//  Created by Aurelio Le Clarke on 04.05.2023.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let imageURL: String
    
    init(imageURL: String) {
     
        self.imageURL = imageURL
        super.init(nibName: "ImageViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadimage()
    }


    func loadimage() {
        guard let url = URL(string: imageURL) else {
            return
        }
        self.activityIndicator.startAnimating()
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
//                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
//                }
                
        } else if let data = data {
            print("hELLO")
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                    self.activityIndicator.stopAnimating()
                }
            }
        }.resume()
    }
  

}
extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
