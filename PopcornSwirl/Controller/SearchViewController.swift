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
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil // MovieSearchItem -> MovieItem
    
    let movieAction = MovieActions.shared
    var movies = [MovieDataStore.MovieItem]()
    var movieToPass: MovieDataStore.MovieItem!
    var movieResult: MovieDataStore.MovieItem!
    var error: MovieError?
    let searchBar = UISearchBar(frame: .zero)
    
    //MARK: - DispatchQueue
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    // MARK: - View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        zeroDataSource()
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
        view.backgroundColor = .systemBackground
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        view.addSubview(searchBar)
    
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        movieCollectionView = collectionView
//        collectionView.delegate = self
        movieCollectionView.delegate = self
        searchBar.delegate = self
    }
    
    //MARK: - Configure DataSource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>(collectionView: movieCollectionView) { (collectionView, indexPath, movie) -> ListViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: self.configureListCell(), for: indexPath, item: movie)
        }
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
//                    case .failure(_):
//                        print("General error thrown")
//                       Alert.showGenericError(on: self.navigationController!)
                    case .failure(.networkFailure(_)):
                        print("Internet connection error")
//                        Alert.showTimeOutError(on: self)
                    case .failure(.invalidData):
                        print("Could not parse image data")
//                        Alert.showImproperDataError(on: self)
                    case .failure(.invalidResponse):
                        print("Response from API was invalid")
//                        Alert.showImproperDataError(on: self)
                } // Switch
            } // fetchImage
        } // cell registration
    } // configureListCell
}
    
    //MARK: - Helper Methods
extension SearchViewController {
    private func search(for searchText: String) {
        guard !searchText.isEmpty else { return }
        movies = []
        movieAction.searchMovie(query: searchText) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    self.movies.append(contentsOf: MoviesDTOMapper.map(response))  // SearchDTOMapper.mapSearch(response)
                case .failure(let error):
                    print("Error fetching movie: \(error.localizedDescription)")
//                    Alert.showNoDataError(on: self)
            }
            self.movies.sort { $0.voteCount > $1.voteCount }
            self.applySnapshot()
        }
    }
    
    //MARK: Setup Snapshot data
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func zeroDataSource() {
            movies = []
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.deleteItems(movies)
            dataSource.apply(currentSnapshot, animatingDifferences: true)
            error = nil
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.search(for: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            zeroDataSource()
        }
        search(for: searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        zeroDataSource()
        movies = []
        applySnapshot()
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
        group.enter()
        movieAction.fetchMovie(id: movie.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    self.movieResult = SingleMovieDTOMapper.map(response)
                    self.movieToPass = self.movieResult
                    print("movie.id = \(movie.id), movieToPass.id = \(self.movieToPass.id)")
                case .failure(let error):
                    print("Error fetching movie: \(error.localizedDescription)")
                    Alert.showNoDataError(on: self)
            }
            self.group.leave()
        }
        group.notify(queue: queue) {
            detailViewController.passedMovie = self.movieToPass
            detailViewController.passedMovieID = self.movieToPass.id
            DispatchQueue.main.async {
                self.tabBarController?.show(detailViewController, sender: self)
            }
        }
    }
}
