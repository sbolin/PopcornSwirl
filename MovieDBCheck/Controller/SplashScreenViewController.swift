//
//  SplashScreenViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 12/17/20.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var popCornImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    private var movieService: MovieService?
    private var endpoints: MovieListEndpoint?
    
    
//    init(movieService: MovieService = MovieStore.shared, endpoints: MovieListEndpoint) {
//        self.movieService = movieService
//        self.endpoints = endpoints
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load data
        
        // animate screen
        animate()
        loadMovieData()
        
        // Do any additional setup after loading the view.
    }
    
    func animate() {
        for _ in 1...3 {
            UIView.animate(withDuration: 1.0) { () -> Void in
                self.popCornImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            UIView.animate(withDuration: 1.0) { () -> Void in
                self.popCornImage.transform = CGAffineTransform(rotationAngle: 2.0 * CGFloat.pi)
            }
        }
        mainScreen()
    }
    
    // load movie data from tmdb API to Core Data
    private func loadMovieData() {
        for endpoint in MovieListEndpoint.allCases {
            movieService?.fetchMovies(from: endpoint) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                    case .success(let response):
                        CoreDataController.shared.saveMovies(movies: response.movies)
                        self.perform(#selector(self.mainScreen))
                    case .failure(let error):
                        self.showAlertWith(title: "Could Not Connect!", message: "Please check your internet connection \n or try again later.")
                        print("Error processing json data at endpoint: \(endpoint), error: \(error.localizedDescription)")
                }
                
            }
        }
    }
    
    // show alert if can't get data
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // go to main movie view after data is loaded in Core Data
    @objc func mainScreen() {
        performSegue(withIdentifier: "moviesList", sender: self)
    }
    
}

