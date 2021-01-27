//
//  Alert.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/25/21.
/*
Thanks to Sean Allen for the great idea (part of Statics explaination)
https://www.youtube.com/watch?v=s2E5hVxQAZQ
*/
//

import UIKit

enum Alert {
    
    static func showBasic(title: String, message: String, vc: UIViewController, andEnable button: UIButton?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if let button = button { button.isEnabled = true }
        }
        alert.addAction(action)
        DispatchQueue.main.async { vc.present(alert, animated: true) }
    }
    
    static func showTimeOutError(on vc: UIViewController, andEnable button: UIButton) {
        Alert.showBasic(title: "Data Timed Out", message: "Please try again later", vc: vc, andEnable: button)
    }
    
    static func showNoDataError(on vc: UIViewController, andEnable button: UIButton) {
        Alert.showBasic(title: "No Data Received", message: "Please check your internet connection", vc: vc, andEnable: button)
    }
    
    static func showImproperDataError(on vc: UIViewController, andEnable button: UIButton) {
        Alert.showBasic(title: "Invalid Response", message: "Improper Data Received, try again", vc: vc, andEnable: button)
    }
    
    
}



/*
 case apiError
 case invalidEndpoint
 case invalidResponse
 case noData
 case decodeError

 case .apiError: return "Failed to fetch data"
 case .invalidEndpoint: return "Invalid Endpoint Entered"
 case .invalidResponse: return "Invalid HTTP Response Received"
 case .noData: return "No Data Received"
 case .decodeError: return "Failed to Decode Data"
 */
