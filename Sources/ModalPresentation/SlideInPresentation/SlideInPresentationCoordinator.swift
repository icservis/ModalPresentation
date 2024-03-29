//
//  SlideInPresentationCoordinator.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

public class SlideInPresentationCoordinator: NSObject {
    public var direction: SlideInPresentationDirection = .bottom
    public var relativeSize: SlideInPresentationRelativeSize = .init(proportion: .custom(1.0), length: .custom(0.7))
    public var visualEffect: SlideInPresentationVisualEffect = .dimming(alpha: 0.5)
    public var disableCompactVerticalSize = false

    weak var interactionController: UIPercentDrivenInteractiveTransition?
}

extension SlideInPresentationCoordinator: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            direction: direction,
            relativeSize: relativeSize,
            visualEffect: visualEffect
        )
        presentationController.delegate = self
        return presentationController
    }

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, phase: .presentation)
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, phase: .dismissal)
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension SlideInPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactVerticalSize {
            return .overFullScreen
        } else {
            return .none
        }
    }

    /*
    func presentationController(
        _ controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
    ) -> UIViewController? {

    }
     */
}
