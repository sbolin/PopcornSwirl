//
//  BookmarksViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit
import CoreData

private enum Section {
    case main
}

/// Bookmarks View, showing movies that the user has bookmarked for later viewing
class BookmarksViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    let request = CoreDataController.shared.bookmarkedMovies
    var error: MovieError?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarkedMovies()
    } // viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    } // viewDidLoad
}
   
//MARK: - Extensions
//MARK: Configure Collection View
extension BookmarksViewController {
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    //MARK: - Configure DataSource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>(collectionView: collectionView) {
            (collectionView, indexPath, movie) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: self.configureListCell(), for: indexPath, item: movie)
        }
    }
    
    //MARK: Configure and Register ListViewCell
    private func configureListCell() -> UICollectionView.CellRegistration<ListViewCell, MovieDataStore.MovieItem> {
        return UICollectionView.CellRegistration<ListViewCell, MovieDataStore.MovieItem> { (cell, indexPath, movie) in
            // Populate the cell with our item description.
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = Utils.yearFormatter.string(from: movie.releaseDate)
            cell.accessories = [.disclosureIndicator()]
            cell.activityIndicator.startAnimating()
            // load image
            let backdropURL = movie.backdropURL
            MovieActions.shared.fetchImage(at: backdropURL) { result in
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                            cell.activityIndicator.stopAnimating()
                        } // Dispatch
//                    case .failure(_):
//                        print("General error thrown")
//                        Alert.showGenericError(on: self.navigationController!)
                    case .failure(.networkFailure(_)):
                        print("Internet connection error")
//                    Alert.showTimeOutError(on: self)
                    case .failure(.invalidData):
                        print("Could not parse image data")
//                    Alert.showImproperDataError(on: self)
                    case .failure(.invalidResponse):
                        print("Response from API was invalid")
//                    Alert.showImproperDataError(on: self)
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
}

//MARK: - Fetch bookmarked movies from core data then download from tmdb API
extension BookmarksViewController {
    private func loadBookmarkedMovies() {
        movies = []
        let fetchedMovies = try! CoreDataController.shared.managedContext.fetch(request)
        for movie in fetchedMovies {
            let id = movie.movieId
            movieAction.fetchMovie(id: Int(id)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        self.movies.append(SingleMovieDTOMapper.map(response))
                    case .failure(let error):
                        print("Error fetching movie: \(error.localizedDescription)")
                        Alert.showNoDataError(on: self)
                }
                self.applySnapshot()
            }
        }
    }
    
    private func applySnapshot() {
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(self.movies)
        self.dataSource.apply(newSnapshot, animatingDifferences: true)
    }
}

//MARK: - CollectionView Delegate Methods
extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.passedMovie = movie
        detailViewController.passedMovieID = movie.id
        tabBarController?.show(detailViewController, sender: self)
    }
}



/*
 //MARK: Setup Snapshot data
 private func setupSnapshot() {
 snapshot = NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>()
 snapshot.appendSections([.main])
 snapshot.appendItems(movies)
 dataSource.apply(snapshot, animatingDifferences: true)
 }
 */
