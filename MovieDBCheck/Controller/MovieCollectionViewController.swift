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
    var dataSource: UICollectionViewDiffableDataSource<MovieDataController.MovieCollection, MovieDataController.Movie>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<MovieDataController.MovieCollection, MovieDataController.Movie>! = nil
    
//    var castData = [CastData]()
//    var actor = [String]()
//    var director = ""
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
        print("in configureDataSource()")
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, MovieDataController.Movie> {
            (cell, indexPath, movie) in
            // Populate the cell with our item description.
            print("configureDataSource, cellRegistration")
            self.formatter.dateFormat = "yyyy"
            DispatchQueue.main.async {
                cell.imageView.image = movie.posterImage
                cell.titleLabel.text = movie.title
                cell.descriptionLabel.text = movie.overview
                cell.yearLabel.text = self.formatter.string(from: movie.releaseDate)
            }
        }
        
/*        // badges
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <BadgeSupplementaryView>(elementKind: BadgeSupplementaryView.reuseIdentifier) {
            (badgeView, string, indexPath) in
            guard let model = self.dataSource.itemIdentifier(for: indexPath) else { return }
            let hasBadgeCount =  model.favorite  // model.fav > 0
            // Set the badge count as its label (and hide the view if the badge count is zero).
            badgeView.label.text =  "1" // "\(model.badgeCount)"
            badgeView.isHidden = !hasBadgeCount
        }
*/
        dataSource = UICollectionViewDiffableDataSource<MovieDataController.MovieCollection, MovieDataController.Movie>(collectionView: collectionView) { // data source changed
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieDataController.Movie) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
/*        // badges
        dataSource.supplementaryViewProvider = {
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: $2)
        }
*/
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
        
        currentSnapshot = NSDiffableDataSourceSnapshot<MovieDataController.MovieCollection, MovieDataController.Movie>()
        print("in currentSnapshot: \(movieCollections.collections.count)")
        movieCollections.collections.forEach {
            let collection = $0
            print("in forEach: \(collection.movies.count)")
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.movies)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

extension MovieCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item \(indexPath.section), \(indexPath.row) selected")
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
//            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        print("go to detailView")
        let detailViewController = MovieDetailViewController(with: movie)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
