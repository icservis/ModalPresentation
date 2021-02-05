//
//  PopUpPresentationCoordinator.swift
//  SampleApp
//
//  Created by Libor Kučera on 04.02.2021.
//

import UIKit

public  class PopUpPresentationCoordinator: NSObject {
    public var position: PopUpPresentationPosition = .value(.init(origin: CGPoint(x: 50, y: 20), size: CGSize(width: 50, height: 50)))
    public var visualEffect: PopUpPresentationVisualEffect = .blur(style: .light)

    weak var interactionController: UIPercentDrivenInteractiveTransition?
}

extension PopUpPresentationCoordinator: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {

        let presentationController = PopUpPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            position: position,
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
        return PopUpPresentationAnimator(phase: .presentation)
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return PopUpPresentationAnimator(phase: .dismissal)
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension PopUpPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }

    /*
     func presentationController(
     _ controller: UIPresentationController,
     viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
     ) -> UIViewController? {

     }
     */
}
