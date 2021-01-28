//
//  MovieCollectionViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 10/21/20.
//

import CoreData
import UIKit

/// Main collection view showing movies according to genres
class MovieCollectionViewController: UIViewController {
    
    // MARK: - Properties
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Movie>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<Section, Movie>! = nil
    
    // MARK: - Value Types
    typealias Section  = MovieDataStore.MovieCollection.Genres
    typealias Movie = MovieDataStore.MovieItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    var movieCollections: [MovieDataStore.MovieCollection]?
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMovies()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    func getMovies() {
        MovieActions.shared.loadMovieData { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let collection):
                    self.movieCollections = collection
                case .failure(_):
 //                   Alert.showNoDataError(on: self)
                    Alert.alertToRefreshData(title: "Internet Error", message: "Can't download data, please check your internet connection.", vc: self, andEnable: nil) { self.getMovies() }
                    print("Movies could not be loaded")
            }
            self.setupSnapshot()
        }
    }
}

extension MovieCollectionViewController {
    //MARK: - Set up Collectionview
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    // create UICollectionViewCompositionalLayout for collectionView
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let cellHeight: CGFloat = (sectionIndex == 0) ? 300 : 220
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
            section.interGroupSpacing = 12
            
            // set up header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: MovieCollectionViewController.sectionHeaderElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

//MARK: - Datasource setup
extension MovieCollectionViewController {
    // configure datasource
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) {
            (collectionView, indexPath, movie) -> MovieCell? in
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
    // Section, Movie -> Section, MovieEntity
    func configureMovieCell() -> UICollectionView.CellRegistration<MovieCell, Movie> {
        return UICollectionView.CellRegistration<MovieCell, Movie> { cell, indexPath, movie in
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = movie.yearText
            cell.activityIndicator.startAnimating()
            // load image...
            let backdropURL = movie.backdropURL
            MovieActions.shared.fetchImage(at: backdropURL) { result in
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                            cell.activityIndicator.stopAnimating()
                        } // Dispatch
                    case .failure(.networkFailure(_)):
                        print("Internet connection error")
                        Alert.showTimeOutError(on: self)
                    case .failure(.invalidData):
                        print("Could not parse image data")
                        Alert.showImproperDataError(on: self)
                    case .failure(.invalidResponse):
                        print("Response from API was invalid")
                        Alert.showImproperDataError(on: self)
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
    
    //MARK: Configure Collectionview Header
    func configureHeader() -> UICollectionView.SupplementaryRegistration<TitleSupplementaryView> {
        // section header
        return UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.snapshot {
                let section = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = section.description
            } // snapshot
        } // SupplementaryRegistration
    } // configureHeader
    
    //MARK: Setup Snapshot data in proper order
    func setupSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { genre in
            if let collections = movieCollections {
                let collection = collections.filter {
                    $0.genreID == genre.id
                }
                for genreMovie in collection {
                    snapshot.appendItems(genreMovie.movies, toSection: genre)
                }
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    } // applyInitialSnapshots
}

//MARK: - UICollectionViewDelegate Methods
extension MovieCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.dataSource.itemIdentifier(for: indexPath) != nil else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.passedMovie = movie
        detailViewController.modalPresentationStyle = .automatic
        tabBarController?.show(detailViewController, sender: self)
    }
}
