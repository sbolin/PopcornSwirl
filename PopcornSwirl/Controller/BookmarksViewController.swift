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
    
    //MARK: - Properties
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
  
    
// MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if movies.isEmpty {
            loadBookmarkedMovies()
        }
//        setupSnapshot() // works here without DispatchGroup, crashes with DispatchGroup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarks"
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                self.configureCollectionView()
                self.configureDataSource()
//                self.setupSnapshot() // doesn't crash, but doesn't work
            }
//            setupSnapshot() // crashes here...
        }
//        setupSnapshot() // crashes here, too...
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
//        setupSnapshot() // crashes here, as well...
    }
}

//MARK: - Extensions
//MARK: Configure Collection View
extension BookmarksViewController {
    private func configureCollectionView() { //
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0.0),
            //            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])
    }
    
//MARK: Configure and Register ListViewCell

    private func configureDataSource() {
        
        let movieListCellRegistration = UICollectionView.CellRegistration<ListViewCell, MovieDataStore.MovieItem> { cell, indexPath, movie in
            //        return UICollectionView.CellRegistration<ListViewCell, MovieDataStore.MovieItem> { (cell, indexPath, movie) in
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
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>(collectionView: collectionView) { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            // Return the cell.
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: movieListCellRegistration,
                for: indexPath,
                item: movie)
            return cell
        } // cellRegistration
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
