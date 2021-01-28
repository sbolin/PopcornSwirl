//
//  ListViewDataController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/23/21.
//

import UIKit
import CoreData

private enum Section {
    case main
}

class ListViewDataController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieDataStore.MovieItem>! = nil
    private var snapshot: NSDiffableDataSourceSnapshot<Section, MovieDataStore.MovieItem>! = nil
    
    private let coreDataController = CoreDataController()
    private let movieAction = MovieActions.shared
    private var movies = [MovieDataStore.MovieItem]()
    private var request: NSFetchRequest<MovieEntity>
    private var fetchedMovies = [MovieEntity]()
    private var error: MovieError?
    
    // MARK: - DispatchGroup
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    init(request: NSFetchRequest<MovieEntity>) {
        self.request = request
    }

    func loadSelectedMovies() {
        fetchedMovies = try! coreDataController.managedContext.fetch(request)
        for movie in fetchedMovies {
            self.group.enter()
            let id = movie.movieId
            movieAction.fetchMovie(id: Int(id)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        self.movies.append(SingleMovieDTOMapper.map(response))
                    case .failure(let error):
                        print("Error fetching movie: \(error.localizedDescription)")
                }
                self.group.leave()
                self.setupSnapshot()
            }
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
