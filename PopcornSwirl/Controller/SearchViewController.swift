//
//  SearchViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/8/21.
//

import UIKit

private enum Section {
    case main
}

/// Search view, for finding movies on the tMDB based on keyword search. Results show in collection view list similar to Bookmark, Watched, etc.
//TODO: SearchViewController is large, and should be split (at least) into extension or (better) separate out data search methods to MovieAction
class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var movieCollectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil
    
    let searchBar = UISearchBar(frame: .zero)
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    var error: MovieError?
    
    // MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        self.configureCollectionView()
        self.configureDataSource()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.text = ""
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems(movies)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
        self.error = nil
    }
    
    func setupSearchBar() {
        searchBar.placeholder = "Search Movies"
        searchBar.keyboardType = .asciiCapable
        searchBar.enablesReturnKeyAutomatically = true
        //       searchBar.prompt = "Search"
    }
}

///
//MARK: - Extensions
//MARK: Configure Collection View
extension SearchViewController {
    private func configureCollectionView() {
        // keep below for reference - still not sure why it didn't work properly
        /*
         view.backgroundColor = .systemBackground
         collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
         collectionView.translatesAutoresizingMaskIntoConstraints = false
         searchBar.translatesAutoresizingMaskIntoConstraints = false
         collectionView.backgroundColor = .systemBackground
         collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         view.addSubview(collectionView)
         view.addSubview(searchBar)
         
         NSLayoutConstraint.activate([
         searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
         searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
         searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
         
         collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
         collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
         collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
         ])
         */
        
        // from Apple: Modern Collection Views
        view.backgroundColor = .systemBackground
        let layout = createLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        let views = ["cv": collectionView, "searchBar": searchBar]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "V:[searchBar]-0-[cv]|", options: [], metrics: nil, views: views))
        constraints.append(searchBar.topAnchor.constraint(
                            equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        NSLayoutConstraint.activate(constraints)
        movieCollectionView = collectionView
        // end from Apple
        
        movieCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
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
            MovieActions.shared.fetchImage(at: backdropURL) { result in
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                            cell.activityIndicator.stopAnimating()
                        } // Dispatch
                    case .failure(_):
                        print("General error thrown")
                        Alert.showGenericError(on: self.navigationController!)  
//                    case .failure(.networkFailure(_)):
//                        print("Internet connection error")
//                        Alert.showTimeOutError(on: self)
//                    case .failure(.invalidData):
//                        print("Could not parse image data")
//                        Alert.showImproperDataError(on: self)
//                    case .failure(.invalidResponse):
//                        print("Response from API was invalid")
//                        Alert.showImproperDataError(on: self)
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
    
    //MARK: - Configure DataSource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>(collectionView: movieCollectionView) { (collectionView, indexPath, movie) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: self.configureListCell(), for: indexPath, item: movie)
        }
    }
    
    //MARK: Setup Snapshot data
    private func setupSnapshot() {
 //       DispatchQueue.main.async {
            self.snapshot = NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>()
            self.snapshot.appendSections([.main])
            self.snapshot.appendItems(self.movies)
            self.dataSource.apply(self.snapshot, animatingDifferences: true)
//        }
    }
    
    
    //MARK: - Helper Methods
    private func search(for searchText: String) {
        guard !searchText.isEmpty else {
            return
        }
        zeroDataSource()
        movieAction.searchMovie(query: searchText) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    self.movies.append(contentsOf: MoviesDTOMapper.map(response))
                case .failure(let error):
                    print("Error fetching movie: \(error.localizedDescription)")
                    Alert.showNoDataError(on: self)
            }
            self.movies.sort { $0.voteCount > $1.voteCount }
            self.setupSnapshot()
        }
    }
    
    private func zeroDataSource() {
 //       DispatchQueue.main.async {
            var currentSnapshot = self.dataSource.snapshot()
            currentSnapshot.deleteItems(self.movies)
            self.dataSource.apply(currentSnapshot)
            self.error = nil
//        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            zeroDataSource()
            return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.search(for: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        zeroDataSource()
        searchBar.resignFirstResponder()
    }
}

//MARK: - CollectionView Delegate Methods
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = self.storyboard!.instantiateViewController(identifier: "movieDetail") as! MovieDetailViewController
        detailViewController.passedMovie = movie
        tabBarController?.show(detailViewController, sender: self)
    }
}
