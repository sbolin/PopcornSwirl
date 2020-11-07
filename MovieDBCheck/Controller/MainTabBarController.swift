//
//  MainTabBarController.swift
//  MovieDBCheck
//
//  Created by Scott Bolin on 11/7/20.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    //MARK: - Properties
    
    @IBOutlet weak var mainTabBar: UITabBar!
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
    }
    //MARK: - Setup Tab Bar
    func setupTabBar() {
        self.selectedIndex = 1
        let tabBarItemSize = CGSize(width: mainTabBar.frame.width / 4, height: mainTabBar.frame.height - 1)
        let tabBarBGImage = UIImage(named: "TabBarBackground")?.resized(toSize: tabBarItemSize)
        mainTabBar.selectionIndicatorImage = tabBarBGImage
        
    }
}

//MARK: - Extensions
extension UIImage {
    func resized(toSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
