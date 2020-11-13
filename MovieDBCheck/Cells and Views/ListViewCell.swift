//
//  ListViewCell.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/13/20.
//

import UIKit

class ListViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "list-cell-reuse-identifier"
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let yearLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ListViewCell {
    func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(yearLabel)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        descriptionLabel.adjustsFontForContentSizeCategory = false // true
        descriptionLabel.allowsDefaultTighteningForTruncation = false // new
        descriptionLabel.textColor = .placeholderText
        
        yearLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        yearLabel.adjustsFontForContentSizeCategory = true
        yearLabel.textColor = .secondaryLabel
        
        imageView.layer.borderColor = UIColor.systemIndigo.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.5)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            yearLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            yearLabel.heightAnchor.constraint(equalToConstant: 15),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 6),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
        
    }
}

