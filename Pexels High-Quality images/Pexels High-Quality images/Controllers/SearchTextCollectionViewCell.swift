//
//  SearchTextCollectionViewCell.swift
//  Pexels High-Quality images
//
//  Created by Aurelio Le Clarke on 04.05.2023.
//

import UIKit

class SearchTextCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "SearchTextCollectionViewCell"
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius =  10
    }

    func set(title: String) {
        titleLabel.text = title
    }
}
