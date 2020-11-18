//
//  MovieDetailViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieActor: UILabel!
    @IBOutlet weak var movieDirector: UILabel!
    
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var movieAverageScore: UILabel!
    @IBOutlet weak var movieVoteCount: UILabel!
    
    @IBOutlet weak var movieNotes: UITextField!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var relatedCollectionView: UICollectionView!
    
    
    //MARK: - Properties
    let movie: MovieDataController.Movie
    
    init(with movie: MovieDataController.Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        self.view.backgroundColor = .systemBackground
        
        heroImage.image = movie.backdropImage
        movieTitle.text = movie.title
        movieYear.text = formatter.string(from: movie.releaseDate)
        movieOverview.text = movie.overview
        movieActor.text = movie.actor[0]
        movieDirector.text = movie.director
        movieRating.text = String(movie.popularity)
        movieAverageScore.text = String(movie.voteAverage)
        movieVoteCount.text = String(movie.voteCount)
    }
    
    //MARK: - Actions
    
    @IBAction func buyTapped(_ sender: UIButton) {
        print("buyTapped")
        buyButton.isSelected.toggle()
        
    }
    
    @IBAction func watchTapped(_ sender: UIButton) {
        print("watchTapped")
        watchedButton.isSelected.toggle()
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("bookmarkTapped")
        bookmarkButton.isSelected.toggle()
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        print("favoriteTapped")
        favoriteButton.isSelected.toggle()
    }
    
    
}
