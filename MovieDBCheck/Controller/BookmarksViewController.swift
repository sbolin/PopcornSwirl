//
//  BookmarksViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

class BookmarksViewController: UIViewController {
    
    // MARK: - Properties
    private var movieCollections = MovieDataController()
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataController.MovieItem>! = nil
//    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, MovieDataController.Movie>! = nil
    private var movies = [MovieDataController.MovieItem]()

    private let formatter = DateFormatter()
    
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bookmarked Movies"
        configureView()
        configureDataSource()
    }
}

extension BookmarksViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension BookmarksViewController {
    private func configureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        print("in configureDataSource()")
        let cellRegistration = UICollectionView.CellRegistration<ListViewCell, MovieDataController.MovieItem> {
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

        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataController.MovieItem>(collectionView: collectionView) { // data source changed
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.MovieItem) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, MovieDataController.MovieItem>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(movies)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}




