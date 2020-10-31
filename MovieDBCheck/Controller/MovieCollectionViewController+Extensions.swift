//
//  MovieCollectionViewController+Extensions.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/28/20.
//

import CoreData
import UIKit

// MARK: - Fetch JSON Data
extension MovieCollectionViewController {
//    func getInitialMovieData() {
//        let page = 1
//
//        for section in MovieCollection.Sections.allCases  {
//            let genreID = genres[section]!
//            MovieDBCheck.MovieServiceAPI.shared.fetchMovies(from: genreID, page: page) {
//                (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
//                switch result {
//                    case .success(let response):
////                        for movie in response.results {
////                            let movieResponse = MovieListData(
////                                id: movie.id,
////                                title: movie.title,
////                                overview: movie.overview,
////                                genreID: movie.genreIds,
////                                releaseDate: movie.releaseDate,
////                                voteAverage: movie.voteAverage,
////                                voteCount: movie.voteCount,
////                                adult: movie.adult,
////                                video: movie.video,
////                                popularity: movie.popularity,
////                                posterPath: movie.posterPath,
////                                backdropPath: movie.backdropPath)
////                            self.movies.append(movieResponse)
////                        }
//                        self.movies = MovieDTOMapper.map(response)
//                        print("getInitialMovieData:, fetchMovie sucess")
//                        print("movies:")
//                        print(self.movies)
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                }
//            }
//            movieCollections.append(MovieCollection(genreID: genreID, movieData: movies))
//        }
//    }
    
//    func getCastData(movieID: Int) -> CastData? {
//        var castData: CastData?
//        MovieDBCheck.MovieServiceAPI.shared.fetchCast(movieID: movieID) { (result: Result<CastResponse, MovieServiceAPI.APIServiceError>) in
//            switch result {
//                case .success(let response):
////                    for cast in response.cast {
////                        print("Character: \(cast.character)")
////                        print("id: \(cast.id)")
////                        print("Actor: \(cast.name)")
////                        print("\n")
////                    }
////                    for crew in response.crew {
////                        print("Crew for movie 550")
////                        print("Position: \(crew.job)")
////                        print("id: \(crew.id)")
////                        print("Name: \(crew.name)")
////                        print("\n")
////                    }
//                    castData = CastDTOMapper.map(dto: response)
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//        }
//        return castData
//    }
//
//    func getMovieFromID(movieID: Int) -> [MovieListData] {
//        // call movieserviceapi to get single movie response
//        MovieDBCheck.MovieServiceAPI.shared.fetchMovie(movieId: movieID) { (result: Result<MovieData, MovieServiceAPI.APIServiceError>) in
//            switch result {
//                case .success(let movie):
//                    self.moviesOld = MovieDTOMapper.map(movie)
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//        }
//        return moviesOld
//    }
//
//
//    func getCompanyData(movieID: Int) -> CompanyData? {
//        var companyData: CompanyData?
//        MovieDBCheck.MovieServiceAPI.shared.fetchCompany(movieID: 550) { (result: Result<CompanyResponse, MovieServiceAPI.APIServiceError>) in
//            switch result {
//                case .success(let response):
////                    for company in response.productionCompanies {
////                        print("Company: \(company.name)")
////                        print("Company ID: \(company.id)")
////                        print("Country: \(company.originCountry)")
////                        print("\n")
////                    }
//                    companyData = CompanyDTOMapper.map(response)
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//        }
//        return companyData
//    }
//    // https://image.tmdb.org/t/p/w780/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
//    func getImage(imageSize: String, imageEndpoint: String) -> UIImage? {
//        var imageObject: UIImage?
//        MovieServiceAPI.shared.fetchImage(imageSize: imageSize, imageEndpoint: imageEndpoint) { (success, error, image)  in
//            if success {
//                print("success getting image")
//                imageObject = image
//            } else {
//                print("could not get image, error thrown \(error?.localizedDescription ?? "" )")
//            }
//        }
//        return imageObject
//    }


//    
// //    call movieserviceapi to get movies from endpoint
//    let endpoints = MovieServiceAPI.Endpoint.allCases
//    endpoints.forEach { (endPoint) in
//        MovieServiceAPI.shared.fetchMovies(from: endPoint) { (result: Result<MoviesResponse, MovieServiceAPI.APIServiceError>) in
//        switch result {
//            case .success(let movieResponse):
//                print("\(endPoint):")
//                for (num, movie) in movieResponse.results.enumerated() {
//                    print("MovieData \(num):")
//                    print("Title: \(movie.title)")
//                    print("id: \(movie.id)")
//                    print("Overview: \(movie.overview)")
//                    print("Release date: \(movie.releaseDate)")
//                    print("Vote Average: \(movie.voteAverage)")
//                    print("Vote Count: \(movie.voteCount)")
//                    print("\n")
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }

}

// MARK: - NSFetchedResultsControllerDelegate Delegate methods
extension MovieCollectionViewController: NSFetchedResultsControllerDelegate {
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
