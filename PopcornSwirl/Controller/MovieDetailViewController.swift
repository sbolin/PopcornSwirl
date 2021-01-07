//
//  MovieDetailViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

class MovieDetailViewController: UIViewController, UITextFieldDelegate {
    
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    var oldNote: String = ""
    var validation = Validation()
    let coreDataController = CoreDataController()
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let passedMovie = passedMovie else { return }
        setup(movie: passedMovie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navTitle = passedMovie?.title ?? "Movie Detail"
        navigationItem.title = navTitle
        view.backgroundColor = .systemBackground
    }
    
    // called from MovieCollectionViewController prior to segue
    func setup(movie: MovieDataStore.MovieItem) {
        self.group.enter()
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
            self.group.leave()
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
        
        let movieEntity = coreDataController.findMovieByID(using: movie.id, in: coreDataController.persistentContainer.viewContext)
        
        movieResult?.bookmarked =  movieEntity.bookmarked
        movieResult?.favorite = movieEntity.favorite
        movieResult?.watched = movieEntity.watched
        movieResult?.bought = movieEntity.bought
        movieResult?.note = movieEntity.note ?? ""
        // set needs display
        
        movie.bookmarked ? (bookmarkButton.tintColor = .systemBlue) : (bookmarkButton.tintColor = .placeholderText)
        
        movie.favorite ? (favoriteButton.tintColor = .systemRed) : (favoriteButton.tintColor = .placeholderText)
        
        movie.watched ? (watchedButton.tintColor = .systemPurple) : (watchedButton.tintColor = .placeholderText)
        
        movie.bought ? (buyButton.tintColor = .systemGreen) : (buyButton.tintColor = .placeholderText)
        
        
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                // from passed in movie
                self.heroImage.image = self.mainImage
                let genreTitle = movieResult?.genreText ?? "Genre"
                let movieTitle = movieResult?.title ?? "Title"
                self.movieTitle.text = movieTitle + " (" + genreTitle + ")"
                self.movieYear.text = Utils.yearFormatter.string(from: movie.releaseDate)
                self.movieOverview.text = movie.overview
                
                // from API result
                guard let result = movieResult else { return }
                var actorResult = [""]
                var directorResult = [""]
                var companyResult = [""]
                
                result.actor.prefix(5).forEach { actor in
                    actorResult.append(actor)
                }
                result.director.prefix(3).forEach { director in
                    directorResult.append(director)
                }
                result.company.prefix(3).forEach { company in
                    companyResult.append(company)
                }
                self.movieActor.text = actorResult.joined(separator: "\n")
                self.movieDirector.text = directorResult.joined(separator: "\n")
                self.movieCompany.text = companyResult.joined(separator: "\n")
                
                self.movieRating.text = "Rating: " + result.ratingText
                self.movieAverageScore.text = "Score: " + String(result.voteAverage)
                self.movieVoteCount.text = "Count: " + String(result.voteCount)
                
                self.view.setNeedsDisplay()
            }
        }
    }
    //MARK: - Process note text
    func processInput() {
        guard let movieNote = movieNotes.text else {
            return
        }
        let isValidated = validation.validatedText(newText: movieNote, oldText: oldNote)
        if isValidated {
            guard let movie = movieResult else { return }
            coreDataController.updateNote(movie, noteText: movieNote)
        } else {
            movieNotes.text = oldNote
        }
        movieNotes.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            oldNote = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // return key tapped
        if textField.text?.count == 0 {
            return false
        }
        processInput()
        return true
    }
    
    //MARK: - Actions
    
    @IBAction func buyTapped(_ sender: UIButton) {
        buyButton.isSelected.toggle()
//        changeAlpha(sender: sender)
        if sender.isSelected {
            sender.tintColor = .systemGreen
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        coreDataController.buyTapped(movie, buyStatus: buyButton.isSelected)
    }
    
    @IBAction func watchTapped(_ sender: UIButton) {
        watchedButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemPurple
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        coreDataController.watchedTapped(movie, watchedStatus: watchedButton.isSelected)
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        bookmarkButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemBlue
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        coreDataController.bookmarkTapped(movie, bookmarkStatus: bookmarkButton.isSelected)

    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        favoriteButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemRed
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        coreDataController.favoriteTapped(movie, favoriteStatus: favoriteButton.isSelected)
    }
    
    //TODO: Handle text field (note)
    @IBAction func notesEditingEnded(_ sender: UITextField) {
        processInput()
    }

    /*
    func changeAlpha(sender: UIButton) {
        if sender.isSelected {
            sender.alpha = 1.0
        } else {
            sender.alpha = 0.25
        }
    }
 */
}
