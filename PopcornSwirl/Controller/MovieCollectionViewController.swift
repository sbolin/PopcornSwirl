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
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Movie>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<Section, Movie>! = nil
    
    // MARK: - Value Types
//    typealias Section  = MovieListEndpoint
    typealias Section  = MovieDataController.MovieCollection
    typealias Movie = MovieDataController.MovieItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    let formatter = DateFormatter()
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: populate data from core data store
//        movieCollections.populateMovieData()
        configureCollectionView()
        configureDataSource()
//        applyInitialSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureDataSource()
        applyInitialSnapshot()
    }
}

extension MovieCollectionViewController {
    //MARK: - Set up Collectionview
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
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

//MARK: - Datasource setup
extension MovieCollectionViewController {
    // configure datasource
    func configureDataSource() {
        print("in configureDataSource")
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: Movie) -> MovieCell? in

            // Return the cell.
           let cell = collectionView.dequeueConfiguredReusableCell(using: self.configureMovieCell(), for: indexPath, item: movie)
            return cell
        }
        

        // section header
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: self.configureHeader(), for: index)
        }
    }
    
    //MARK: Configure Collectionview Movie Cell
    func configureMovieCell() -> UICollectionView.CellRegistration<MovieCell, Movie> {
        return UICollectionView.CellRegistration<MovieCell, Movie> { [weak self] (cell, indexPath, movie) in
            guard let self = self else { return }
            print("in configureMovieCell()")
            self.formatter.dateFormat = "yyyy"
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            cell.activityIndicator.startAnimating()
            // load image...
            let backdropURL = self.movieCollections.getImageURL(imageSize: "w780", endPoint: movie.backdropPath)
//            let backdropURL = movie.backdropURL
            //FIXME: MovieServiceAPI
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
    
    //MARK: Configure Collectionview Header
    func configureHeader() -> UICollectionView.SupplementaryRegistration<TitleSupplementaryView> {
        // section header
        print("in configureHeader()")
        return UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.snapshot {
                let movieCollection = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = movieCollection.genreName
            } // snapshot
        } // SupplementaryRegistration
    } // configureHeader

    //MARK: Setup Snapshot data in proper order
    func applyInitialSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        movieCollections.collections.forEach {
            let collection = $0
            snapshot.appendSections([collection])
            snapshot.appendItems(collection.movies)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    } // applyInitialSnapshots
}

//MARK: - UICollectionViewDelegate
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
