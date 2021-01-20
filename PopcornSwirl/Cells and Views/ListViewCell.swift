//
//  ListViewCell.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/13/20.
//

import UIKit

/// ListView Cell used in BookmarkView, WatchedView, FavoritesView, and BoughtView Controllers
class ListViewCell: UICollectionViewListCell {
        
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let yearLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// configure cell
extension ListViewCell {
    func configure() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        descriptionLabel.adjustsFontForContentSizeCategory = false // true
        descriptionLabel.allowsDefaultTighteningForTruncation = false // new
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 4
        
        yearLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        yearLabel.adjustsFontForContentSizeCategory = true
        yearLabel.textColor = .secondaryLabel
        
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "film")
        imageView.contentMode = .scaleAspectFit
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .white
        
        let topImageAnchor = imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        // must decrease centerAnchorImage priority to avoid constraint errors.
        let centerImageAnchor = imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        centerImageAnchor.priority = UILayoutPriority(999)
        let leadingImageAnchor = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4)
        let widthImageAnchor = imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4)
        let heightImageAnchor = imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25)

        // cell constraints
        NSLayoutConstraint.activate([
            topImageAnchor,
            centerImageAnchor,
            leadingImageAnchor,
            widthImageAnchor,
            heightImageAnchor,
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            yearLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 0),
            
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.75)
        ])
        
    }
}

