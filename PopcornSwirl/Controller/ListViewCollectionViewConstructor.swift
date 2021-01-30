//
//  ListViewCollectionViewConstructor.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/23/21.
//

import UIKit

private enum Section {
    case main
}

class ListViewCollectionViewConstructor: UIViewController {
    
    private var collectionView = UICollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

}
