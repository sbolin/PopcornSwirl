//
//  MovieDetailViewController.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

/// Movie Detail View, note dependency on GoogleMobileAds
/// AppTrackingTransparency is required for new apps
class MovieDetailViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieActor: UILabel!
    @IBOutlet weak var movieDirector: UILabel!
    @IBOutlet weak var movieCompany: UILabel!
    
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var movieAverageScore: UILabel!
    @IBOutlet weak var movieVoteCount: UILabel!
    
    @IBOutlet weak var movieNote: UITextField!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //bannerView for Google Ad
    @IBOutlet weak var bannerView: GADBannerView!
    
    //MARK: Tracking AuthorizationStatus
    var trackingAuthorizationStatus: ATTrackingManager.AuthorizationStatus!
    
    
    //MARK: - Properties
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    let movieAction = MovieActions.shared
    var passedMovie: MovieDataStore.MovieItem?
    var movieResult: MovieDataStore.MovieItem!
    var movieEntity = MovieEntity()
    var error: MovieError?
    
    var actors: [String] = []
    var director: String = ""
    var companies: [String] = []
    var mainImage = UIImage()
    
    var oldNote: String = ""
    var validation = Validation()
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        activity.hidesWhenStopped = true
        guard let passedMovie = passedMovie else { return }
        registerForKeyboardNotifications()
        movieNote.delegate = self
        title = passedMovie.title
        setup(movie: passedMovie)
        bannerView.delegate = self
        setupGoogleAds()
    }
    
    // called from MovieCollectionViewController prior to segue
    func setup(movie: MovieDataStore.MovieItem) {
        self.group.enter()
        activity.startAnimating()
        // check if movie has been created in core data, if not create entity with current movie title and it
        if CoreDataController.shared.entityExists(using: movie.id, in: CoreDataController.shared.managedContext) {
            // Movie exists in Core Data
            movieEntity = CoreDataController.shared.findMovieByID(using: movie.id, in: CoreDataController.shared.managedContext)! // note force unwrapping!
        } else {
            // Movie does not exist in Core Data
            movieEntity = CoreDataController.shared.newMovie(name: movie.title, id: movie.id)
        }
        
        movieAction.fetchMovie(id: movie.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    self.movieResult = SingleMovieDTOMapper.map(response)
                    self.movieResult.bookmarked = self.movieEntity.bookmarked
                    self.movieResult.favorite = self.movieEntity.favorite
                    self.movieResult.watched = self.movieEntity.watched
                    self.movieResult.bought = self.movieEntity.bought
                    self.movieResult.note = self.movieEntity.note
                case .failure(let error):
                    self.error = error
                    print("Error fetching movie: \(error.localizedDescription)")
            }
            self.group.leave()
        }
        // get actor and image for movie
        let posterURL = movie.posterURL
        self.group.enter()
        movieAction.fetchImage(imageURL: posterURL) { (success, image) in
            if success, let image = image {
                self.mainImage = image
            } // success
            self.group.leave()
        } // getMovieImage
        
        group.notify(queue: queue) { [self] in
            DispatchQueue.main.async { [self] in
                activity.stopAnimating()
                // button state
                movieResult.bookmarked ? (bookmarkButton.tintColor = .systemBlue) : (bookmarkButton.tintColor = .placeholderText)
                movieResult.favorite ? (favoriteButton.tintColor = .systemRed) : (favoriteButton.tintColor = .placeholderText)
                movieResult.watched ? (watchedButton.tintColor = .systemPurple) : (watchedButton.tintColor = .placeholderText)
                movieResult.bought ? (buyButton.tintColor = .systemGreen) : (buyButton.tintColor = .placeholderText)
                
                // from passed in movie
                self.heroImage.image = self.mainImage
                let genreTitle = movieResult.genreText
                let movieTitle = movieResult.title
                self.movieTitle.text = movieTitle + " (" + genreTitle + ")"
                self.movieYear.text = Utils.yearFormatter.string(from: movieResult.releaseDate)
                self.movieOverview.text = movieResult.overview
                self.movieNote.text = movieResult.note
                
                // from API result
                guard let result = movieResult else { return }
                var actorResult = [""]
                var directorResult = [""]
                var companyResult = [""]
                
                result.actor.prefix(5).forEach { actor in
                    actorResult.append(actor)
                }
                result.director.prefix(3).forEach { director in
                    directorResult.append(director)
                }
                result.company.prefix(3).forEach { company in
                    companyResult.append(company)
                }
                self.movieActor.text = actorResult.joined(separator: "\n")
                self.movieDirector.text = directorResult.joined(separator: "\n")
                self.movieCompany.text = companyResult.joined(separator: "\n")
                
                self.movieRating.text = "Rating: " + result.ratingText
                self.movieAverageScore.text = "Score: " + String(result.voteAverage)
                self.movieVoteCount.text = "Count: " + String(result.voteCount)
                
                self.view.setNeedsDisplay()
            }
        }
    }
    
    //MARK: - Google Ads
    func setupGoogleAds() {

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //ca-app-pub-3940256099942544~1458002511
        bannerView.rootViewController = self
        
        // if authorization false then ask, else go ahead and present ad
        
        ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
            guard let self = self else { return }
            switch status {
                case .notDetermined:
                    self.trackingAuthorizationStatus = .notDetermined
                case .restricted:
                    self.trackingAuthorizationStatus = .restricted
                case .denied:
                    self.trackingAuthorizationStatus = .denied
                case .authorized:
                    self.trackingAuthorizationStatus = .authorized
                    self.bannerView.load(GADRequest())
                @unknown default:
                    self.trackingAuthorizationStatus = .notDetermined
            }
        }
    }
    //MARK: - Actions
    @IBAction func buyTapped(_ sender: UIButton) {
        buyButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemGreen
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        CoreDataController.shared.buyTapped(movie, buyStatus: buyButton.isSelected)
        
    }
    
    @IBAction func watchTapped(_ sender: UIButton) {
        watchedButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemPurple
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        CoreDataController.shared.watchedTapped(movie, watchedStatus: watchedButton.isSelected)
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        bookmarkButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemBlue
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        CoreDataController.shared.bookmarkTapped(movie, bookmarkStatus: bookmarkButton.isSelected)

    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        favoriteButton.isSelected.toggle()
        if sender.isSelected {
            sender.tintColor = .systemRed
        } else {
            sender.tintColor = .placeholderText
        }
        guard let movie = movieResult else { return }
        CoreDataController.shared.favoriteTapped(movie, favoriteStatus: favoriteButton.isSelected)
    }
    
    //Handle text field (note)
    @IBAction func notesEditingEnded(_ sender: UITextField) {
        processInput()
    }
    @IBAction func tappedOut(_ sender: UITapGestureRecognizer) {
        movieNote.resignFirstResponder()
    }
    
//MARK: - Process note text
    func processInput() {
        guard let note = movieNote.text else {
            return
        }
        let isValidated = validation.validatedText(newText: note, oldText: oldNote)
        if isValidated {
            guard let movie = movieResult else { return }
            CoreDataController.shared.updateNote(movie, noteText: note)
        } else {
            movieNote.text = oldNote
        }
        movieNote.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            oldNote = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // return key tapped
        if textField.text?.count == 0 {
            return false
        }
        processInput()
        return true
    }
    
    //MARK:- Keyboard Notification for showing and hiding
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        adjustLayoutForKeyboard(targetHeight: (keyboardFrame.size.height + 20))
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        adjustLayoutForKeyboard(targetHeight: 0)
    }
        
    func adjustLayoutForKeyboard(targetHeight: CGFloat) {
        scrollView.contentInset.bottom = targetHeight
    }
}

// MARK: - GADBannerViewDelegate
extension MovieDetailViewController: GADBannerViewDelegate {
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.bannerView.alpha = 1
        })
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
    }
}
