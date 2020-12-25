//
//  MovieCell.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/28/20.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    static let reuseIdentifier = "movie-cell-reuse-identifier"
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

extension MovieCell {
    func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        descriptionLabel.adjustsFontForContentSizeCategory = false // true
        descriptionLabel.allowsDefaultTighteningForTruncation = false // new
        descriptionLabel.textColor = .placeholderText
        
        yearLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        yearLabel.adjustsFontForContentSizeCategory = true
        yearLabel.textColor = .secondaryLabel
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.5)
        imageView.image = UIImage(systemName: "film")
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .white
        
        let spacing = CGFloat(6)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -40),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 280),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            yearLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: imageView.heightAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

