//
//  MovieCollectionViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import CoreData
import UIKit

class MovieCollectionViewController: UIViewController {
    
    // MARK: - Properties
    var movieCollections = MovieDataController()
    var collectionView: UICollectionView! = nil
//    private lazy var dataSource = makeDataSource()
    var dataSource: UICollectionViewDiffableDataSource<MovieDataController.MovieCollection, MovieDataController.MovieItem>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<MovieDataController.MovieCollection, MovieDataController.MovieItem>! = nil
    
    var bookmarkedMovie = Set<Movie>()
    var favoritedMovie = Set<Movie>()
    var boughtMovie = Set<Movie>()
    var watchedMovie = Set<Movie>()
    
    
    // MARK: - Value Types
    typealias Section  = MovieDataController.MovieCollection
    typealias Movie = MovieDataController.MovieItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    let formatter = DateFormatter()
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"
    
    // get genre id (int) from Section
    let genres: [MovieCollection.Sections : Int] = [
        .Adventure       : 12,
        .Animation       : 16,
        .Drama           : 18,
        .Action          : 28,
        .Comedy          : 35,
        .Thriller        : 53,
        .Documentary     : 99,
        .Mystery         : 9648,
        .Family          : 10751
    ]
    
    override func loadView() {
        super.loadView()
        movieCollections.populateMovieData()
//        movieCollections.populateSupplementaryMovieData()
//        movieCollections.compileMovieData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabItem()
        configureCollectionView() 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDataSource()
    }
}

extension MovieCollectionViewController {
    
    func configureTabItem() {
        navigationItem.title = "Movie List"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let cellHeight:CGFloat = 220
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
                                                0.425 : 0.85)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth), heightDimension: .absolute(cellHeight))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered // originally .continuous
            section.interGroupSpacing = 8
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: MovieCollectionViewController.sectionHeaderElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

extension MovieCollectionViewController {
    // currently working on cleaning up the dataSource methods, in particular snapshots...
    
    /*
    
    func makeDataSource() -> DataSource {
        
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, movie) -> MovieCell? in
            let cellRegistration = UICollectionView.CellRegistration<MovieCell, MovieDataController.MovieItem> { (cell, indexPath, movie) in
                var setMovie = movie
                // Populate the cell with our item description.
                cell.titleLabel.text = movie.title
                cell.descriptionLabel.text = movie.overview
                cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
                cell.activityIndicator.startAnimating()
                // load image...
                let backdropURL = self.movieCollections.getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
                self.movieCollections.getMovieImage(imageURL: backdropURL) { (success, image) in
                    if success, let image = image {
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                            setMovie.backdropImage = image
                            cell.activityIndicator.stopAnimating()
                        } // Dispatch
                    } // success
                } // getMovieImage
            } // cellRegistration
        }
    }
    */
    
    func configureDataSource() {
        
        print("in configureDataSource()")
        formatter.dateFormat = "yyyy"
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, MovieDataController.MovieItem> { (cell, indexPath, movie) in
            var setMovie = movie
            // Populate the cell with our item description.
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            cell.activityIndicator.startAnimating()
            // load image...
            let backdropURL = self.movieCollections.getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
            self.movieCollections.getMovieImage(imageURL: backdropURL) { (success, image) in
                if success, let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        setMovie.backdropImage = image
                        cell.activityIndicator.stopAnimating()
                    } // Dispatch
                } // success
            } // getMovieImage
        } // cellRegistration
        
        
        dataSource = UICollectionViewDiffableDataSource<MovieDataController.MovieCollection, MovieDataController.MovieItem>(collectionView: collectionView) { // data source changed
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.MovieItem) -> MovieCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }

        // section header
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.currentSnapshot {
                let movieCollection = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = movieCollection.genreName
            }
        }
        
        // section header
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: index)
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot<MovieDataController.MovieCollection, MovieDataController.MovieItem>()
        print("in currentSnapshot: \(movieCollections.collections.count)")
        movieCollections.collections.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.movies)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)

    }
}

extension MovieCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item \(indexPath.section), \(indexPath.row) selected")
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            print("collectionView deselect")
            return
        }
        print("go to detailView")
//        let detailViewController = MovieDetailViewController(with: movie)
        let detailViewController = MovieDetailViewController()
        // setup view data state prior to present view
        detailViewController.setup(movie: movie)
        let navController = UINavigationController(rootViewController: detailViewController)
        self.present(navController, animated: true, completion: nil)
    }
}
