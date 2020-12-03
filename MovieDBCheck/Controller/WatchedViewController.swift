//
//  WatchedViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

class WatchedViewController: UIViewController {

    // MARK: - Properties
    var movieCollections = MovieDataController()
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataController.MovieItem>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, MovieDataController.MovieItem>! = nil
    var movies = [MovieDataController.MovieItem]()

    private let formatter = DateFormatter()
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieCollections.populateMovieData()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDataSource()
    }
}

extension WatchedViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureDataSource() {
        print("in configureDataSource()")
        self.formatter.dateFormat = "yyyy"
        let cellRegistration = UICollectionView.CellRegistration<ListViewCell, MovieDataController.MovieItem> { (cell, indexPath, movie) in
            // Populate the cell with our item description.
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            cell.activityIndicator.startAnimating()
            // load image
            let backdropURL = self.movieCollections.getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
            MovieServiceAPI.shared.getMovieImage(imageURL: backdropURL) { (success, image) in
                if success, let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    } // Dispatch
                } // success
            } // getMovieImage
            
            
        } // cellRegistration
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataController.MovieItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.MovieItem) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, MovieDataController.MovieItem>()
        print("in bookmark currentSnapshot: \(movieCollections.collections.count)")
        
        // should search over movies with bookmark == true, display those movies
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(movies)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

extension WatchedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("item \(indexPath.section), \(indexPath.row) selected")
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            print("collectionView deselect")
            return
        }
        print("go to detailView")
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.movie = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}

