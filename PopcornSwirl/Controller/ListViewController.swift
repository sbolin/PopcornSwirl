//
//  ListViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/23/21.
//

import UIKit
import CoreData


private enum Section {
    case main
}

/// Bookmarks View, showing movies that the user has bookmarked for later viewing
class ListViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil
    
    let coreDataController = CoreDataController()
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    var request: NSFetchRequest<MovieEntity>
    var fetchedMovies = [MovieEntity]()
    var error: MovieError?
    
    // MARK: - DispatchGroup
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    init(request: NSFetchRequest<MovieEntity>) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        //        super.init(coder: aDecoder)
    }
    
    
    // MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if movies.isEmpty {
            loadSelectedMovies()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                self.configureCollectionView()
                self.configureDataSource()
            }
        }
    }
    
    //MARK: - Fetch bookmarked movies from core data then download from tmdb API
    func loadSelectedMovies() {
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
                        self.error = error
                        print("Error fetching movie: \(error.localizedDescription)")
                }
                self.group.leave()
                self.setupSnapshot()
            }
        }
    }
}

//MARK: - Extensions
//MARK: Configure Collection View
extension ListViewController {
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
                    case .failure(.networkFailure(_)):
                        print("Internet connection error")
                        
                    case .failure(.invalidData):
                        print("Could not parse image data")
                    case .failure(.invalidResponse):
                        print("Response from API was invalid")
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
    
    //MARK: - Configure DataSource
    private func configureDataSource() {
        // FIXME: Section, MovieDataController.MovieItem -> Section, Movie
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

//MARK: - CollectionView Delegate Methods
extension ListViewController: UICollectionViewDelegate {
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
