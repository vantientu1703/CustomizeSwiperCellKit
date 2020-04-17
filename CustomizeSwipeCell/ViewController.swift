//
//  ViewController.swift
//  CustomizeSwipeCell
//
//  Created by Van Tien Tu on 4/16/20.
//  Copyright © 2020 Van Tien Tu. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 100)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
}

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .blue
        
        //cell.swipe(view: collectionView).delegate = self
        //cell.swipe(view: collectionView).showSwipe(orientation: .left)
        cell.swipeable.delegate = self
        cell.swipeable.showSwipe(orientation: .left)
        return cell
    }
}

extension ViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let action = SwipeAction(style: .default, title: "dsaddsad") { (_, indexPath) in
            print("did selected \(indexPath)")
        }
        if orientation == .left {
            return [action]
        }
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
}
