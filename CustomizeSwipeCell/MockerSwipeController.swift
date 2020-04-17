//
//  MockSwipeController.swift
//  SwipeCellKit
//
//  Created by Van Tien Tu on 4/16/20.
//

import UIKit

open class MockerSwipeController: NSObject, Swipeable {
    
    var cell: UICollectionViewCell!
    
    init(cell: UICollectionViewCell) {
        super.init()
        self.cell = cell
        self.prepareForReuse()
        self.configure()
    }
    
    public weak var delegate: SwipeCollectionViewCellDelegate?
    
    var state = SwipeState.center
    var actionsView: SwipeActionsView?
    var scrollView: UIScrollView? {
        return collectionView
    }
    var indexPath: IndexPath? {
        return collectionView?.indexPath(for: self.cell)
    }
    var panGestureRecognizer: UIGestureRecognizer
    {
        return swipeController.panGestureRecognizer;
    }
    
    var swipeController: SwiperCollectionViewCellController!
    var isPreviouslySelected = false
    
    weak var collectionView: UICollectionView?
    
    /// :nodoc:
    open var frame: CGRect {
        set { self.cell.frame = state.isActive ? CGRect(origin: CGPoint(x: frame.minX, y: newValue.minY), size: newValue.size) : newValue }
        get { return self.cell.frame }
    }
    
    /// :nodoc:
    open var isHighlighted: Bool {
        set {
            guard state == .center else { return }
            self.cell.isHighlighted = newValue
        }
        get { return self.cell.isHighlighted }
    }
    
    /// :nodoc:
    open var layoutMargins: UIEdgeInsets {
        get {
            return frame.origin.x != 0 ? swipeController.originalLayoutMargins : self.cell.layoutMargins
        }
        set {
            self.cell.layoutMargins = newValue
        }
    }
    
    /// :nodoc:
    /*
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
     */
    
    deinit {
        collectionView?.panGestureRecognizer.removeTarget(self, action: nil)
    }
    
    func configure() {
        self.cell.contentView.clipsToBounds = false
        
        if self.cell.contentView.translatesAutoresizingMaskIntoConstraints == true {
            self.cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.cell.contentView.leadingAnchor.constraint(equalTo: self.cell.leadingAnchor),
                self.cell.contentView.topAnchor.constraint(equalTo: self.cell.topAnchor),
                self.cell.contentView.trailingAnchor.constraint(equalTo: self.cell.trailingAnchor),
                self.cell.contentView.bottomAnchor.constraint(equalTo: self.cell.bottomAnchor),
            ])
        }
        
        swipeController = SwiperCollectionViewCellController(swipeable: self, actionsContainerView: self.cell.contentView)
        swipeController.delegate = self
        //self.didMoveToSuperview()
    }
    
    /// :nodoc:
    open func prepareForReuse() {
        //super.prepareForReuse()
        reset()
        resetSelectedState()
    }
    
    /// :nodoc:
    open func didMoveToSuperview() {
        //self.cell.didMoveToSuperview()
        
        var view: UIView = self.cell
        while let superview = view.superview {
            view = superview
            
            if let collectionView = view as? UICollectionView {
                self.collectionView = collectionView
                
                swipeController.scrollView = scrollView
                
                collectionView.panGestureRecognizer.removeTarget(self, action: nil)
                collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleCollectionPan(gesture:)))
                return
            }
        }
    }
    
    /// :nodoc:
    open func willMove(toWindow newWindow: UIWindow?) {
        //self.cell.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            reset()
        }
    }
    
    // Override so we can accept touches anywhere within the cell's original frame.
    // This is required to detect touches on the `SwipeActionsView` sitting alongside the
    // `SwipeCollectionViewCell`.
    /// :nodoc:
    open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = self.cell.superview else { return false }
        
        let point = self.cell.convert(point, to: superview)
        
        if !UIAccessibility.isVoiceOverRunning {
            for cell in collectionView?.swipeCells ?? [] {
                if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                    collectionView?.hideSwipeCell()
                    return false
                }
            }
        }
        
        return contains(point: point)
    }
    
    func contains(point: CGPoint) -> Bool {
        return frame.contains(point)
    }
    
    // Override hitTest(_:with:) here so that we can make sure our `actionsView` gets the touch event
    //   if it's supposed to, since otherwise, our `contentView` will swallow it and pass it up to
    //   the collection view.
    /// :nodoc:
    open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //guard let actionsView = actionsView, self.cell.isHidden == false else {
          //  return self.cell.hitTest(point, with: event)
        //}
        guard let actionsView = actionsView, self.cell.isHidden == false else {
            return self.cell.hitTest(point, with: event)
        }
        let modifiedPoint = actionsView.convert(point, from: self.cell)
        return actionsView.hitTest(modifiedPoint, with: event) ?? self.cell.hitTest(point, with: event)
    }
    
    /// :nodoc:
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return swipeController.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    /// :nodoc:
    open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.cell.traitCollectionDidChange(previousTraitCollection)
        
        swipeController.traitCollectionDidChange(from: previousTraitCollection, to: self.cell.traitCollection)
    }
    
    @objc func handleCollectionPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideSwipe(animated: true)
        }
    }
    
    func reset() {
        self.cell.contentView.clipsToBounds = false
        swipeController?.reset()
        collectionView?.setGestureEnabled(true)
    }
    
    func resetSelectedState() {
        if isPreviouslySelected {
            if let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self.cell) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
        isPreviouslySelected = false
    }
}

extension MockerSwipeController: SwiperCollectionViewCellControllerDelegate {
    func swipeController(_ controller: SwiperCollectionViewCellController, canBeginEditingSwipeableFor orientation: SwipeActionsOrientation) -> Bool {
        return true
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, editActionsForSwipeableFor orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self.cell) else { return nil }
        
        return delegate?.collectionView(collectionView, editActionsForItemAt: indexPath, for: orientation)
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, editActionsOptionsForSwipeableFor orientation: SwipeActionsOrientation) -> SwipeOptions {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self.cell) else { return SwipeOptions() }
        
        return delegate?.collectionView(collectionView, editActionsOptionsForItemAt: indexPath, for: orientation) ?? SwipeOptions()
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, visibleRectFor scrollView: UIScrollView) -> CGRect? {
        guard let collectionView = collectionView else { return nil }
        
        return delegate?.visibleRect(for: collectionView)
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, willBeginEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self.cell) else { return }
        
        // Remove highlight and deselect any selected cells
        self.cell.isHighlighted = false
        isPreviouslySelected = self.cell.isSelected
        collectionView.deselectItem(at: indexPath, animated: false)
        
        delegate?.collectionView(collectionView, willBeginEditingItemAt: indexPath, for: orientation)
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, didEndEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self.cell), let actionsView = self.actionsView else { return }
        
        resetSelectedState()
        
        delegate?.collectionView(collectionView, didEndEditingItemAt: indexPath, for: actionsView.orientation)
    }
    
    func swipeController(_ controller: SwiperCollectionViewCellController, didDeleteSwipeableAt indexPath: IndexPath) {
        collectionView?.deleteItems(at: [indexPath])
    }
}

extension MockerSwipeController {
    /// The point at which the origin of the cell is offset from the non-swiped origin.
    public var swipeOffset: CGFloat {
        set { setSwipeOffset(newValue, animated: false) }
        get { return self.cell.contentView.frame.midX - self.cell.bounds.midX }
    }
    
    /**
     Hides the swipe actions and returns the cell to center.
     
     - parameter animated: Specify `true` to animate the hiding of the swipe actions or `false` to hide it immediately.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        swipeController.hideSwipe(animated: animated, completion: completion)
    }
    
    /**
     Shows the swipe actions for the specified orientation.
     
     - parameter orientation: The side of the cell on which to show the swipe actions.
     
     - parameter animated: Specify `true` to animate the showing of the swipe actions or `false` to show them immediately.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func showSwipe(orientation: SwipeActionsOrientation, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        setSwipeOffset(.greatestFiniteMagnitude * orientation.scale * -1,
                       animated: animated,
                       completion: completion)
    }
    
    /**
     The point at which the origin of the cell is offset from the non-swiped origin.
     
     - parameter offset: A point (expressed in points) that is offset from the non-swiped origin.
     
     - parameter animated: Specify `true` to animate the transition to the new offset, `false` to make the transition immediate.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func setSwipeOffset(_ offset: CGFloat, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        swipeController.setSwipeOffset(offset, animated: animated, completion: completion)
    }

}
