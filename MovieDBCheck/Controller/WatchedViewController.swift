//
//  WatchedViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

private enum Section: Hashable {
    case main
}

class WatchedViewController: UIViewController {

    // MARK: - Properties
    private var movieCollections = MovieDataController()
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataController.Movie>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, MovieDataController.Movie>! = nil
    
    private let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bookmarked Movies"
        configureHierarchy()
        configureDataSource()
    }
}

extension WatchedViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension WatchedViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        print("in configureDataSource()")
        let cellRegistration = UICollectionView.CellRegistration<ListViewCell, MovieDataController.Movie> {
            (cell, indexPath, movie) in
            // Populate the cell with our item description.
            print("configureDataSource, cellRegistration")
            self.formatter.dateFormat = "yyyy"
            //            DispatchQueue.main.async {
            cell.imageView.image = movie.backdropImage
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            //            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataController.Movie>(collectionView: collectionView) { // data source changed
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.Movie) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        
        movieCollections.collections.forEach {
            let collection = $0
            currentSnapshot.appendSections([.main])
            currentSnapshot.appendItems(collection.movies)
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
    }
}

extension WatchedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
