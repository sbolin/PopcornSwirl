//
//  SearchViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/8/21.
//

import Foundation

import UIKit
import CoreData

private enum Section {
    case main
}

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil
    
    let searchBar = UISearchBar(frame: .zero)
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    var nameFilter: String?

    
    
    // MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSearchedMovies()
        //        setupSnapshot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search"
        configureCollectionView()
        configureDataSource()
    }
    
    //MARK: - Fetch bookmarked movies from core data then download from tmdb API
    func loadSearchedMovies() {
        movieAction.fetchMovie(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    print("fetchMovie success")
                    self.movies.append(SingleMovieDTOMapper.map(response))
                case .failure(let error):
                    self.error = error
                    print("Error fetching movie: \(error.localizedDescription)")
            }
        }
        setupSnapshot() // may be called here or in viewWillAppear - check.
    }
}

///
//MARK: - Extensions
//MARK: Configure Collection View
extension SearchViewController {
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

///
//MARK: - CollectionView Delegate Methods
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.movieResult = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}
