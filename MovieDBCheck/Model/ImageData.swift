//
//  ImageData.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 11/12/20.
//

import UIKit

struct ImageData: Hashable, Identifiable {
    // Domain model used in App
    
    var id = UUID()
    var movieID: Int
    
    var imagePath: URL
    var image: UIImage
    var imageType: Int
    
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
