//
//  MovieDetailViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

protocol MovieDetailViewControllerDelegate {
    func favoriteTapped(_ movie: MovieDataStore.MovieItem, favoriteStatus: Bool)
    func watchedTapped(_ movie: MovieDataStore.MovieItem, watchedStatus: Bool)
    func bookmarkTapped(_ movie: MovieDataStore.MovieItem, bookmarkStatus: Bool)
    func buyTapped(_ movie: MovieDataStore.MovieItem, buyStatus: Bool)
    func noteAdded(_ movie: MovieDataStore.MovieItem, noteText: String)
}

class MovieDetailViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieActor: UILabel!
    @IBOutlet weak var movieDirector: UILabel!
    @IBOutlet weak var movieCompany: UILabel!
    
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
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    let movieAction = MovieActions.shared
    var passedMovie: MovieDataStore.MovieItem?
    var movieResult: MovieDataStore.MovieItem?
    var error: MovieError?
    
    var actors: [String] = []
    var director: String = ""
    var companies: [String] = []
    var mainImage = UIImage()
    
    var delegate: MovieDetailViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let passedMovie = passedMovie else { return }
        setup(movie: passedMovie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movies"//"\(movie.title)"
        view.backgroundColor = .systemBackground
    }
    
    // called from MovieCollectionViewController prior to segue
    func setup(movie: MovieDataStore.MovieItem) {
        movieAction.fetchMovie(id: movie.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    print("fetchMovie success")
                    self.movieResult = SingleMovieDTOMapper.map(response)
                case .failure(let error):
                    self.error = error
                    print("Error fetching movie: \(error.localizedDescription)")
            }
        }
        // get actor and image for movie
        let posterURL = movie.posterURL
        self.group.enter()
        movieAction.fetchImage(imageURL: posterURL) { (success, image) in
            if success, let image = image {
                self.mainImage = image
            } // success
            self.group.leave()
        } // getMovieImage
        
        
        //TODO: Core Data Methods
        // set status:
        // set movie status from coredata (search on movie id)
        // update UI accordingly:
        // movie.movieNotes = result.notes
        // movie.favorite = result.favorite
        // movie.bookmarked = result.bookmarked
        // movie.watched = result.watched
        // movie.bought = result.bought
        
        if movie.bookmarked {
            bookmarkButton.isSelected = true
            bookmarkButton.tintColor = .systemBlue
        } else {
            bookmarkButton.isSelected = false
            bookmarkButton.tintColor = .systemGray6
        }
        
        if movie.favorite {
            favoriteButton.isSelected = true
            favoriteButton.tintColor = .systemRed
        } else {
            favoriteButton.isSelected = false
            favoriteButton.tintColor = .systemGray6
        }
        
        if movie.watched {
            watchedButton.isSelected = true
            watchedButton.tintColor = .systemPurple
        } else {
            watchedButton.isSelected = false
            watchedButton.tintColor = .systemGray6
        }
        
        if movie.bought {
            buyButton.isSelected = true
            buyButton.tintColor = .systemGreen
        } else {
            buyButton.isSelected = false
            buyButton.tintColor = .systemGray6
        }
        
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                // from passed in movie
                self.heroImage.image = self.mainImage
                let genreTitle = movieResult?.genreText ?? "Genre"
                self.movieTitle.text = genreTitle //movie.title
                self.movieYear.text = Utils.yearFormatter.string(from: movie.releaseDate)
                self.movieOverview.text = movie.overview
                
                // from API result
                guard let result = movieResult else { return }
                self.movieActor.text = result.actor.joined(separator: ", ")
                self.movieDirector.text = result.director.joined(separator: ", ")
                self.movieCompany.text = result.company.joined(separator: ", ")
                
                self.movieRating.text = "Rating: " + result.ratingText
                self.movieAverageScore.text = "Score: " + String(result.voteAverage)
                self.movieVoteCount.text = "Count: " + String(result.voteCount)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func buyTapped(_ sender: UIButton) {
        buyButton.isSelected.toggle()
//        changeAlpha(sender: sender)
        if sender.isSelected {
            sender.tintColor = .systemGreen
        } else {
            sender.tintColor = .systemGray6
        }
        guard let movie = movieResult else { return }
        delegate?.buyTapped(movie, buyStatus: buyButton.isSelected)
    }
    
    @IBAction func watchTapped(_ sender: UIButton) {
        watchedButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemPurple
        } else {
            sender.tintColor = .systemGray6
        }
        guard let movie = movieResult else { return }
        delegate?.watchedTapped(movie, watchedStatus: watchedButton.isSelected)
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        bookmarkButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemBlue
        } else {
            sender.tintColor = .systemGray6
        }
        guard let movie = movieResult else { return }
        delegate?.bookmarkTapped(movie, bookmarkStatus: bookmarkButton.isSelected)

    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        favoriteButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemRed
        } else {
            sender.tintColor = .systemGray6
        }
        guard let movie = movieResult else { return }
        delegate?.favoriteTapped(movie, favoriteStatus: favoriteButton.isSelected)
    }
    
    //TODO: Handle text field (note)
    
    func changeAlpha(sender: UIButton) {
        if sender.isSelected {
            sender.alpha = 1.0
        } else {
            sender.alpha = 0.25
        }
    }
}
