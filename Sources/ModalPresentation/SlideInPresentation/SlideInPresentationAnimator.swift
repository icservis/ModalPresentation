//
//  SlideInPresentationAnimator.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

public struct SlideInPresentationAnimationConfig {
    public let animationDuration: TimeInterval
    public let animationDelay: TimeInterval
    public let dampingRatio: CGFloat
    public let velocity: CGFloat
    public let options: UIView.AnimationOptions

    public static let `default` = SlideInPresentationAnimationConfig(
        animationDuration: 0.25,
        animationDelay: 0.0,
        dampingRatio: 0.7,
        velocity: 0.0,
        options: [UIView.AnimationOptions.curveEaseOut]
    )

    public static let noDamping = SlideInPresentationAnimationConfig(
        animationDuration: 0.25,
        animationDelay: 0.0,
        dampingRatio: 1,
        velocity: 0.0,
        options: []
    )
}

public class SlideInPresentationAnimator: NSObject {
    private let direction: SlideInPresentationDirection
    private let phase: UIViewControllerAnimatedTransitioningPhase
    private let config: SlideInPresentationAnimationConfig

    public init(
        direction: SlideInPresentationDirection,
        phase: UIViewControllerAnimatedTransitioningPhase,
        config: SlideInPresentationAnimationConfig
    ) {
        self.direction = direction
        self.phase = phase
        self.config = config
    }

    public convenience init(direction: SlideInPresentationDirection, phase: UIViewControllerAnimatedTransitioningPhase) {
        self.init(
            direction: direction,
            phase: phase,
            config: SlideInPresentationAnimationConfig.default
        )
    }
}

extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.animationDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: phase.transitionContextViewControllerKey) else { return }

        if case .presentation = phase {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
        case .right:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        }

        let initialFrame: CGRect
        let finalFrame: CGRect
        switch phase {
        case .presentation:
            initialFrame = dismissedFrame
            finalFrame = presentedFrame
        case .dismissal:
            initialFrame = presentedFrame
            finalFrame = dismissedFrame
        }

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            delay: config.animationDelay,
            usingSpringWithDamping: config.dampingRatio,
            initialSpringVelocity: config.velocity,
            options: config.options,
            animations: { controller.view.frame = finalFrame },
            completion: { [weak self] _ in
                let finished = !transitionContext.transitionWasCancelled
                if let mode = self?.phase, case .dismissal = mode, finished {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            }
        )
    }
}

