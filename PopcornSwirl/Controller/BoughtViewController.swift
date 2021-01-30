//
//  BoughtViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/8/21.
//

import UIKit
import CoreData

private enum Section {
    case main
}

/// Bought View, showing movies that the user has marked as having bought (sort of a user library)
class BoughtViewController: UIViewController {
    
// MARK: - Properties
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil
    
    let coreDataController = CoreDataController()
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    let request = MovieEntity.boughtMovies
    var fetchedMovies = [MovieEntity]()
    var error: MovieError?
    
// MARK: - DispatchGroup
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
// MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if movies.isEmpty {
            loadBoughtMovies()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bought"
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                self.configureCollectionView()
                self.configureDataSource()
            }
        }
    }
    
    //MARK: - Fetch bought movies from core data then download from tmdb API
    func loadBoughtMovies() {
        fetchedMovies = try! coreDataController.managedContext.fetch(request)
        for movie in fetchedMovies {
            self.group.enter()
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
                self.group.leave()
                self.setupSnapshot()
            }
        }
    }
}

//MARK: - Extensions
//MARK: Configure Collection View
extension BoughtViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
        return UICollectionViewCompositionalLayout.list(using: config)
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
                    case .failure(_):
                        print("General error thrown")
                        Alert.showGenericError(on: self.navigationController!)  
//                    case .failure(.networkFailure(_)):
//                        print("Internet connection error")
//                        Alert.showTimeOutError(on: self)
//                    case .failure(.invalidData):
//                        print("Could not parse image data")
//                        Alert.showImproperDataError(on: self)
//                    case .failure(.invalidResponse):
//                        print("Response from API was invalid")
//                        Alert.showImproperDataError(on: self)
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
    
    //MARK: - Configure DataSource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>(collectionView: collectionView) {
            (collectionView, indexPath, movie) -> ListViewCell? in
            // Return the cell.
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.configureListCell(), for: indexPath, item: movie)
            return cell
        }
    }
    
    //MARK: Setup Snapshot data
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

///
//MARK: - CollectionView Delegate Methods
extension BoughtViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.passedMovie = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}
