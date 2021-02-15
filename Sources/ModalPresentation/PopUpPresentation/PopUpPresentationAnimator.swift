//
//  PopUpPresentationAnimator.swift
//  ModalPresentation
//
//  Created by Libor Kučera on 05.02.2021.
//

import UIKit

public class PopUpPresentationAnimator: NSObject {
    private let phase: UIViewControllerAnimatedTransitioningPhase

    init(phase: UIViewControllerAnimatedTransitioningPhase) {
        self.phase = phase
    }
}

extension PopUpPresentationAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: phase.transitionContextViewControllerKey) else { return }

        if case .presentation = phase {
            transitionContext.containerView.addSubview(controller.view)
        }

        let initialFrame: CGRect
        let finalFrame: CGRect
        switch phase {
        case .presentation:
            initialFrame = transitionContext.initialFrame(for: controller)
            finalFrame = transitionContext.finalFrame(for: controller)
        case .dismissal:
            initialFrame = transitionContext.finalFrame(for: controller)
            finalFrame = transitionContext.initialFrame(for: controller)
        }

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
            }, completion: { [weak self] _ in
                let finished = !transitionContext.transitionWasCancelled
                if let mode = self?.phase, case .dismissal = mode, finished {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            }
        )
    }
}
