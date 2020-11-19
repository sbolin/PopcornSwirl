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
    var movieCollections = MovieDataController()
    var movie: MovieDataController.MovieItem
    let formatter = DateFormatter()
    
    init(with movie: MovieDataController.MovieItem) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        // get actor and image for movie
        let posterURL = movieCollections.getImageURL(imageSize: "w780", endPoint: movie.posterPath)
        movieCollections.getMovieImage(imageURL: posterURL) { (success, image) in
            if success, let image = image {
                DispatchQueue.main.async {
                    self.heroImage.image = image
                } // DispatchQueue
            } // success
        } // getMovieImage
        
        let actorURL = movieCollections.getCastURL(movieID: movie.id)
        movieCollections.getMovieCast(castURL: actorURL) { (success, cast) in
            if success, let cast = cast {
                DispatchQueue.main.async {
                    self.movie.actor = cast.actor
                    self.movie.director = cast.director
                    self.movieActor.text = cast.actor.joined(separator: ", ")
                    self.movieDirector.text = cast.director
                } // DispatchQueue
            } // success
        } // getMovieCast
        
        let companyURL = movieCollections.getCompanyURL(movieID: movie.id)
        movieCollections.getMovieCompany(companyURL: companyURL) { (success, company) in
            if success, let company = company {
                DispatchQueue.main.async {
                    self.movie.company = company.company
                    self.movieCompany.text = company.company.joined(separator: ", ")
                } // DispatchQueue
            } // success
        } // getMovieCompany


        formatter.dateFormat = "yyyy"
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
        
//        heroImage.image = self.movie.backdropImage
//        movieTitle.text = movie.title
//        movieYear.text = formatter.string(from: movie.releaseDate)
//        movieOverview.text = self.movie.overview
//        movieActor.text = self.movie.actor[0]
//        movieDirector.text = self.movie.director
//        movieRating.text = String(self.movie.popularity)
//        movieAverageScore.text = String(self.movie.voteAverage)
//        movieVoteCount.text = String(self.movie.voteCount)
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
