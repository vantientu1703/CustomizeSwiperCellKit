//
//  UICollectionView+Ext.swift
//  SwipeCellKit
//
//  Created by Van Tien Tu on 4/16/20.
//

import UIKit

extension UICollectionViewCell {
    
    private struct AssociatedKeys {
        static var reorderController: UInt8 = 0
    }
    
    /// An object that manages drag-and-drop reordering of table view cells.
    public var swipeable: MockerSwipeController {
        //return MockSwipeController(cell: self)
        if let controller = objc_getAssociatedObject(self, &AssociatedKeys.reorderController) as? MockerSwipeController {
            return controller
        } else {
            let controller = MockerSwipeController(cell: self)
            objc_setAssociatedObject(self, &AssociatedKeys.reorderController, controller, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return controller
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let actionsView = self.swipeable.actionsView, self.swipeable.cell.isHidden == false else {
            return super.hitTest(point, with: event)
        }
        let modifiedPoint = actionsView.convert(point, from: self.swipeable.cell)
        return actionsView.hitTest(modifiedPoint, with: event) ?? super.hitTest(point, with: event)
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.swipeable.didMoveToSuperview()
    }

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: window)
        self.swipeable.willMove(toWindow: window)
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = self.superview else { return false }
        let point = super.convert(point, to: superview)
        
        if !UIAccessibility.isVoiceOverRunning {
            for cell in self.swipeable.collectionView?.swipeCells ?? [] {
                if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                    self.swipeable.collectionView?.hideSwipeCell()
                    return false
                }
            }
        }
        
        return self.swipeable.contains(point: point)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.swipeable.traitCollectionDidChange(previousTraitCollection)
    }

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        super.gestureRecognizerShouldBegin(gestureRecognizer)
        return self.swipeable.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    //open override func prepareForReuse() {
      //  super.prepareForReuse()
        //self.swipeable.prepareForReuse()
        //objc_setAssociatedObject(self, &AssociatedKeys.reorderController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    //}
}
