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

