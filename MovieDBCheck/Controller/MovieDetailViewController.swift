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
    let queue = DispatchQueue.global(qos: .userInteractive)
    
    var movieCollections = MovieDataController()
    var movie: MovieDataController.MovieItem
    let formatter = DateFormatter()
    
    var actors: [String] = []
    var director: String = ""
    var companies: [String] = []
    var mainImage = UIImage()
    
    init(with movie: MovieDataController.MovieItem) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        // prevent user from dismissing view
        isModalInPresentation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(movie.title)"
        view.backgroundColor = .systemBackground
        
        // get actor and image for movie
        let posterURL = movieCollections.getImageURL(imageSize: "w780", endPoint: movie.posterPath)
        movieCollections.getMovieImage(imageURL: posterURL) { [self] (success, image) in
            if success, let image = image {
                mainImage = image
            } // success
        } // getMovieImage
        
        let actorURL = movieCollections.getCastURL(movieID: movie.id)
        movieCollections.getMovieCast(castURL: actorURL) { [self] (success, cast) in
            if success, let cast = cast {
                actors = cast.actor
                director = cast.director
            } // success
        } // getMovieCast
        
        let companyURL = movieCollections.getCompanyURL(movieID: movie.id)
        movieCollections.getMovieCompany(companyURL: companyURL) { [self] (success, company) in
            if success, let company = company {
                companies = company.company
            } // success
        } // getMovieCompany
        
        formatter.dateFormat = "yyyy"
        group.notify(queue: queue) {
            self.heroImage.image = self.mainImage
            self.movieTitle.text = self.movie.title
            self.movieYear.text = self.formatter.string(from: self.movie.releaseDate)
            self.movieOverview.text = self.movie.overview
            self.movieActor.text = self.actors.joined(separator: ", ")
            self.movieDirector.text = self.director
            self.movieCompany.text = self.companies.joined(separator: ", ")
            self.movieRating.text = String(self.movie.popularity)
            self.movieAverageScore.text = String(self.movie.voteAverage)
            self.movieVoteCount.text = String(self.movie.voteCount)
            /*
             print("in moviedetailviewcontroller")
             print("movie passed in: \(movie)")
             print("movie title: \(movie.title)")
             print("backcrop image: \(movie.backdropImage)")
             print("poster image: \(movie.posterImage)")
             let releaseDate = formatter.string(from: movie.releaseDate)
             print("release data: \(releaseDate)")
             print("overview: \(movie.overview)")
             print("actors: \(movie.actor)")
             print("director: \(movie.director)")
             print("popularity: \(movie.popularity)")
             print("vote average: \(movie.voteAverage)")
             print("vote count: \(movie.voteCount)")
             */
        }
        
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
