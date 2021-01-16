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

class BookmarksViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil

    let coreDataController = CoreDataController()
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    let request = MovieEntity.bookmarkedMovies
    var fetchedMovies = [MovieEntity]()
    var error: MovieError?
    
// MARK: - DispatchGroup
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
  
// MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if movies.isEmpty {
            loadBookmarkedMovies()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarked"
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                self.configureCollectionView()
                self.configureDataSource()
            }
        }
    }
    
    //MARK: - Fetch bookmarked movies from core data then download from tmdb API
    func loadBookmarkedMovies() {
        fetchedMovies = try! coreDataController.managedContext.fetch(request)
        for movie in fetchedMovies {
            self.group.enter()
            let id = movie.movieId
            movieAction.fetchMovie(id: Int(id)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        print("BookmarksViewController fetchMovie success")
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
extension BookmarksViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
            MovieActions.shared.fetchImage(imageURL: backdropURL) { (success, image) in
                if success, let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    } // Dispatch
                } // success
            } // fetchImage
        } // cellRegistration
    }
    
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
extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        print("BookmarksViewController to MovieDetailViewController view with: \(movie.title)")
        detailViewController.movieResult = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}
