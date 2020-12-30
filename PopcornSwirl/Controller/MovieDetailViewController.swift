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
    let queue = DispatchQueue.global()
    
    let movieAction = MovieActions.shared
    var passedMovie: MovieDataStore.MovieItem?
    var movie: [MovieDataStore.MovieItem]?
    var error: MovieError?
    
    var actors: [String] = []
    var director: String = ""
    var companies: [String] = []
    var mainImage = UIImage()
    
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

        movieAction.fetchMovie(id: movie.id) { (result) in
            switch result {
                case .success(let response):
                    self.movie = SingleMovieDTOMapper.map(response)
                case .failure(let error):
                    self.error = error
                    print("Error fetching movie: \(error.localizedDescription)")
            }
        }
        // get actor and image for movie
        let posterURL = movie.posterURL
        self.group.enter()
            //FIXME: MovieServiceAPI
        movieAction.fetchImage(imageURL: posterURL) { (success, image) in
            if success, let image = image {
                self.mainImage = image
            } // success
            self.group.leave()
        } // getMovieImage
        
        let actorURL = movieCollections.getCastURL(movieID: movie.id)
        self.group.enter()
            //FIXME: MovieServiceAPI
        MovieServiceAPI.shared.getMovieCast(castURL: actorURL) { (success, cast) in
            if success, let cast = cast {
                self.actors = cast.actor
                self.director = cast.director
            } // success
            self.group.leave()
        } // getMovieCast
        
        let companyURL = movieCollections.getCompanyURL(movieID: movie.id)
        self.group.enter()
            //FIXME: MovieServiceAPI
        MovieServiceAPI.shared.getMovieCompany(companyURL: companyURL) { (success, company) in
            if success, let company = company {
                self.companies = company.company
            } // success
            self.group.leave()
        } // getMovieCompany
        
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                
                self.heroImage.image = self.mainImage
                self.movieTitle.text = movie.title
                self.movieYear.text = Utils.yearFormatter.string(from: movie.releaseDate)
                self.movieOverview.text = movie.overview
                self.movieActor.text = self.actors.joined(separator: ", ")
                self.movieDirector.text = self.director
                self.movieCompany.text = self.companies.joined(separator: ", ")
                
                self.movieRating.text = "Rating: " + String(movie.popularity)
                self.movieAverageScore.text = "Score: " + String(movie.voteAverage)
                self.movieVoteCount.text = "Count: " + String(movie.voteCount)

                print("in moviedetailviewcontroller")
                print("movie passed in: \(movie)")
                print("movie title: \(movie.title)")
                print("backcrop image: \(movie.backdropImage)")
                print("poster image: \(movie.posterImage)")
                let releaseDate = Utils.dateFormatter.string(from: movie.releaseDate)
                print("release data: \(releaseDate)")
                print("overview: \(movie.overview)")
                print("actors: \(movie.actor)")
                print("director: \(movie.director)")
                print("popularity: \(movie.popularity)")
                print("vote average: \(movie.voteAverage)")
                print("vote count: \(movie.voteCount)")
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func buyTapped(_ sender: UIButton) {
        print("buyTapped")
        buyButton.isSelected.toggle()
        changeAlpha(sender: sender)
    }
    
    @IBAction func watchTapped(_ sender: UIButton) {
        print("watchTapped")
        watchedButton.isSelected.toggle()
        changeAlpha(sender: sender)
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("bookmarkTapped")
        bookmarkButton.isSelected.toggle()
        changeAlpha(sender: sender)
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        print("favoriteTapped")
        favoriteButton.isSelected.toggle()
        changeAlpha(sender: sender)
    }
    
    func changeAlpha(sender: UIButton) {
        if sender.isSelected {
            sender.alpha = 1.0
        } else {
            sender.alpha = 0.25
        }
    }
}
