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
    
    typealias Action = () -> ()
    
    // Base function used to create simple alerts
    private static func showBasic(title: String, message: String, vc: UIViewController, andEnable button: UIButton?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                if let button = button { button.isEnabled = true }
            }
            alert.addAction(action)
            vc.present(alert, animated: true)
        }
    }
    
    // Base function used to create alert with closure upon completion
    static func alertToRefreshData(title: String, message: String, vc: UIViewController, andEnable button: UIButton?, onConfirm: @escaping Action) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Reload Data", style: .default) { _ in
                if let button = button { button.isEnabled = true }
                onConfirm()
            }
            alert.addAction(action)
            vc.present(alert, animated: true)
        }
    }
    
    
    // alert to present when time out error occurs
    //    static func showTimeOutError(on vc: UIViewController, andEnable button: UIButton) {
    //    Alert.showBasic(title: "Data Timed Out", message: "Please try again later", vc: vc, andEnable: button)
    //    }
    
    // alert to present when time out error occurs
    static func showTimeOutError(on vc: UIViewController) {
        Alert.showBasic(title: "Data Timed Out", message: "Please try again later", vc: vc, andEnable: nil)
    }
    
    // alert to present when there is no data
    static func showNoDataError(on vc: UIViewController) {
        Alert.showBasic(title: "No Data Received", message: "Please check your internet connection", vc: vc, andEnable: nil)
    }
    
    // alert to present when cannot decode data from API
    static func showImproperDataError(on vc: UIViewController) {
        Alert.showBasic(title: "Invalid Response", message: "Improper Data Received, try again", vc: vc, andEnable: nil)
    }
    
    static func showGenericError(on vc: UIViewController) {
        Alert.showBasic(title: "Error", message: "There was an error, please try again later", vc: vc, andEnable: nil)
    }
}
