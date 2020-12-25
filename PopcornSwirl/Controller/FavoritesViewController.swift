//
//  FavoritesViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    // MARK: - Properties
    var collectionView: UICollectionView! = nil
    
    // FIXME: Section, MovieDataController.MovieItem -> Section, Movie
    var dataSource: UICollectionViewDiffableDataSource<Section, Movie>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Movie>! = nil
    var movies = [Movie]()
    
    private let formatter = DateFormatter()
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: need to get movie data via nsfetchedresultscontroller
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDataSource()
    }
}

extension FavoritesViewController {
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
        // FIXME: Section, MovieDataController.MovieItem -> Section, Movie
        self.formatter.dateFormat = "yyyy"
        let cellRegistration = UICollectionView.CellRegistration<ListViewCell, Movie> { (cell, indexPath, movie) in
            // Populate the cell with our item description.
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = movie.yearText
            cell.activityIndicator.startAnimating()
            // load image
            let backdropURL = movie.backdropURL
            //FIXME: MovieServiceAPI
            MovieServiceAPI.shared.getMovieImage(imageURL: backdropURL) { (success, image) in
                if success, let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    } // Dispatch
                } // success
            } // getMovieImage
        } // cellRegistration
        
        // FIXME: Section, MovieDataController.MovieItem -> Section, Movie
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: Movie) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        print("in favorites currentSnapshot: \(movies.count)")
        
        // should search over movies with bookmark == true, display those movies
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(movies)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
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

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    // FIXME: Section, MovieDataController.MovieItem -> Section, Movie
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Section, Movie>, animatingDifferences: true)
    }
}
