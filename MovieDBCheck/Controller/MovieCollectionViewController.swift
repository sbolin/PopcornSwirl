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
    let movieCollections = MovieDataController()
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<MovieDataController.MovieCollection.Sections, MovieDataController.MovieItem>!
    var snapshot: NSDiffableDataSourceSnapshot<MovieDataController.MovieCollection.Sections, MovieDataController.MovieItem>!
    
    var bookmarkedMovie = Set<Movie>()
    var favoritedMovie = Set<Movie>()
    var boughtMovie = Set<Movie>()
    var watchedMovie = Set<Movie>()
    
    
    // MARK: - Value Types
    typealias Section  = MovieDataController.MovieCollection.Sections
    typealias Movie = MovieDataController.MovieItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    let formatter = DateFormatter()
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieCollections.populateMovieData()
        configureCollectionView()
        // try new scheme, based on Apple Modern Collection Views app
        configureDataSource()
        applyInitialSnapshots()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        configureDataSource() // note, this works
    }
}

extension MovieCollectionViewController {
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
    //MARK: - Datasource setup
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.MovieItem) -> MovieCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: self.configureMovieCell(), for: indexPath, item: movie)
        }
        // section header
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: self.configureHeader(), for: index)
        }
    }
    
    func applyInitialSnapshots() {
        // set the order of the sections
        let sections = Section.allCases
        var recentSnapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        recentSnapshot.appendSections(sections)
        dataSource.apply(recentSnapshot, animatingDifferences: false)
        
        // list of all
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<Movie>()
        for genre in Section.allCases {
            let allSnapshotItems = movieCollections.movieList
            allSnapshot.append(allSnapshotItems)
            dataSource.apply(allSnapshot, to: genre, animatingDifferences: false)
        } // allCases
    } // applyInitialSnapshots

    func configureMovieCell() -> UICollectionView.CellRegistration<MovieCell, Movie> {
        return UICollectionView.CellRegistration<MovieCell, Movie> { [weak self] (cell, indexPath, movie) in
            guard let self = self else { return }
            self.formatter.dateFormat = "yyyy"
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            cell.activityIndicator.startAnimating()
            // load image...
            let backdropURL = self.movieCollections.getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
            MovieServiceAPI.shared.getMovieImage(imageURL: backdropURL) { (success, image) in
                if success, let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    } // Dispatch
                } // success
            } // getMovieImage
        } // CellRegistration
    } // configureMovieCell
    
    func configureHeader() -> UICollectionView.SupplementaryRegistration<TitleSupplementaryView> {
        // section header
        return UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.snapshot {
                let movieCollection = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = movieCollection.rawValue
            } // snapshot

        } // SupplementaryRegistration
    }
}

extension MovieCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.movie = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}
