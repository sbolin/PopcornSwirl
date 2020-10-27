//
//  ViewController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/21/20.
//

import CoreData
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var backdropImageView: UIImageView!
    
    // MARK: - Properties
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<MovieCollection, MovieListData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<MovieCollection, MovieListData>! = nil
    var movieCollections = [MovieCollection]()
    var movies = [MovieListData]()
    var castData = [CastData]()
    var actor = [String]()
    var director = ""
    
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"
    
    // get genre id (int) from Section
    let genres: [MovieCollection.Sections : Int] = [
        .Adventure       : 12,
        .Animation       : 16,
        .Drama           : 18,
        .Action          : 28,
        .Comedy          : 35,
        .Thriller        : 53,
        .Documentary     : 99,
        .Mystery         : 9648,
        .Family          : 10751
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInitialMovieData()
        let cast = getCastData(movieID: 550)
        let movie = getMovieFromID(movieID: 550)
        let company = getCompanyData(movieID: 550)
        getImages(imageSize: "w780", imageEndpoint: "/plzV6fap5bGqMaIpOrihmhtd7lW.jpg")
        
        // call movieserviceapi to get movies from given genre response
        posterImageView.layer.cornerRadius = 8
        backdropImageView.layer.cornerRadius = 8
        
    }
    
    func getInitialMovieData() {
        let page = 1

        for section in MovieCollection.Sections.allCases  {
//            let genreName = section.rawValue
            let genreID = genres[section]!
            MovieDBCheck.MovieServiceAPI.shared.fetchMovies(from: genreID, page: page) { (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let response):
//                        print("fetchMovies success")
//                        for movie in response.results {
//                            let movieResponse = MovieListData(
//                                id: movie.id,
//                                title: movie.title,
//                                overview: movie.overview,
//                                genreID: movie.genreIds,
//                                releaseDate: movie.releaseDate,
//                                voteAverage: movie.voteAverage,
//                                voteCount: movie.voteCount,
//                                adult: movie.adult,
//                                video: movie.video,
//                                popularity: movie.popularity,
//                                posterPath: movie.posterPath,
//                                backdropPath: movie.backdropPath)
//                            self.movies.append(movieResponse)
//                        }
                        self.movies = MovieDTOMapper.map(response)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
            movieCollections.append(MovieCollection(genreID: genreID, movieData: movies))
        }
    }
    
    func getCastData(movieID: Int) -> CastData? {
        var castData: CastData?
        MovieDBCheck.MovieServiceAPI.shared.fetchCast(movieID: movieID) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
//                    print("Cast and Crew for movie: \(response.id)")
//                    print("Cast:")
//                    for cast in response.cast {
//                        print("Character: \(cast.character)")
//                        print("id: \(cast.id)")
//                        print("Actor: \(cast.name)")
//                        print("\n")
//                    }
//                    print("Crew:")
//                    for crew in response.crew {
//                        print("Crew for movie 550")
//                        print("Position: \(crew.job)")
//                        print("id: \(crew.id)")
//                        print("Name: \(crew.name)")
//                        print("\n")
//                    }
                    castData = CastDTOMapper.map(dto: response)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return castData
    }
        
    func getMovieFromID(movieID: Int) -> [MovieListData] {
        // call movieserviceapi to get single movie response
        MovieDBCheck.MovieServiceAPI.shared.fetchMovie(movieId: movieID) { (result: Result<MovieData, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let movie):
//                    print("Title: \(movie.title)")
//                    print("id: \(movie.id)")
//                    print("Overview: \(movie.overview)")
//                    print("Release date: \(movie.releaseDate)")
//                    print("Vote Average: \(movie.voteAverage)")
//                    print("Vote Count: \(movie.voteCount)")
//                    print("Video: \(movie.video)")
//                    print("Popularity: \(movie.popularity)")
//                    print("Poster Path: \(movie.posterPath)")
//                    print("Backdrop Path: \(movie.backdropPath)")
//                    print("\n")
                    self.movies = MovieDTOMapper.map(movie)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return movies
    }
    
        
    func getCompanyData(movieID: Int) -> CompanyData? {
        var companyData: CompanyData?
        MovieDBCheck.MovieServiceAPI.shared.fetchCompany(movieID: 550) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
            switch result {
                case .success(let response):
                    print("Companies for movie: \(response.id)")
                    for company in response.productionCompanies {
                        print("Company: \(company.name)")
                        print("Company ID: \(company.id)")
                        print("Country: \(company.originCountry)")
                        print("\n")
                    }
                    companyData = CompanyDTOMapper.map(response)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        return companyData
    }
        // https://image.tmdb.org/t/p/w780/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
        
    func getImages(imageSize: String, imageEndpoint: String) {
        MovieServiceAPI.shared.fetchImage(imageSize: imageSize, imageEndpoint: imageEndpoint) { (success, error, image)  in
            if success {
                print("success getting image")
                self.posterImageView.image = image
            } else {
                print("could not get image, error thrown \(error?.localizedDescription ?? "" )")
            }
        }
    }
/*
        // call movieserviceapi to get movies from endpoint
        let endpoints = MovieServiceAPI.Endpoint.allCases
        endpoints.forEach { (endPoint) in
            MovieServiceAPI.shared.fetchMovies(from: endPoint) { (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
                switch result {
                    case .success(let movieResponse):
                        print("\(endPoint):")
                        for (num, movie) in movieResponse.results.enumerated() {
                            print("MovieData \(num):")
                            print("Title: \(movie.title)")
                            print("id: \(movie.id)")
                            print("Overview: \(movie.overview)")
                            print("Release date: \(movie.releaseDate)")
                            print("Vote Average: \(movie.voteAverage)")
                            print("Vote Count: \(movie.voteCount)")
                            print("\n")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
*/
}


extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = collectionView?.dataSource as? UICollectionViewDiffableDataSource<Int, NSManagedObjectID> else {
            assertionFailure("The data source has not implemented snapshot support while it should")
            return
        }
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        
        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)
        
        let shouldAnimate = collectionView?.numberOfSections != 0
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: shouldAnimate)
    }
}
