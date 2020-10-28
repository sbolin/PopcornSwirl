//
//  MovieCollectionViewController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 10/21/20.
//

import CoreData
import UIKit

class MovieCollectionViewController: UIViewController {
    
    // MARK: - Properties
    var movieCollections = [MovieCollection]()
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<MovieCollection, MovieListData>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<MovieCollection, MovieListData>! = nil
    
    var movies = [MovieListData]()
    var castData = [CastData]()
    var actor = [String]()
    var director = ""
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
        getInitialMovieData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Popcorn Swirl"
        configureHierarchy()
        configureDataSource()

        
//        let cast = getCastData(movieID: 550)
//        let movie = getMovieFromID(movieID: 550)
//        let company = getCompanyData(movieID: 550)
//        let image = getImage(imageSize: "w780", imageEndpoint: "/plzV6fap5bGqMaIpOrihmhtd7lW.jpg")
        
    }
}

extension MovieCollectionViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let cellHeight:CGFloat = 250
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let sectionProvider = {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
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
            //           section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
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
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration
        <MovieCell, MovieListData> { (cell, indexPath, movie) in
            // Populate the cell with our item description.
            print("configureDataSource, cellRegistration")
            self.formatter.dateFormat = "yyyy"
            cell.titleLabel.text = movie.title
            cell.descriptionLabel.text = movie.overview
            cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
        }
        
        dataSource = UICollectionViewDiffableDataSource<MovieCollection, MovieListData>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieListData) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") { (supplementaryView, string, indexPath) in
            if let snapshot = self.currentSnapshot {
                let movieCollection = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = movieCollection.genreName
            }
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot<MovieCollection, MovieListData>()
        movieCollections.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.movieData)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

