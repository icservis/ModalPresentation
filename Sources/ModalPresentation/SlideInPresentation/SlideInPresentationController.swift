//
//  SlideInPresentationController.swift
//  ping-pong
//
//  Created by Libor Kučera on 31.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import UIKit

public enum SlideInPresentationDirection: Int {
    case left = 0
    case top
    case right
    case bottom
}

public struct SlideInPresentationRelativeSize {
    public enum Proportion: RawRepresentable {
        public typealias RawValue = CGFloat

        case custom(RawValue)

        public init?(rawValue: CGFloat) {
            let range: ClosedRange<RawValue> = (0...1)
            guard range.contains(rawValue) else { return nil }
            self = Self.custom(rawValue)
        }

        public var rawValue: RawValue {
            switch self {
            case let .custom(value):
                return value
            }
        }
    }

    public let proportion: Proportion

    public enum Length: RawRepresentable {
        public typealias RawValue = CGFloat

        case custom(RawValue)

        public init?(rawValue: CGFloat) {
            let range: ClosedRange<RawValue> = (0...1)
            guard range.contains(rawValue) else { return nil }
            self = Self.custom(rawValue)
        }

        public var rawValue: RawValue {
            switch self {
            case let .custom(value):
                return value
            }
        }
    }

    public let length: Length

    public init(
        proportion: Proportion,
        length: Length
    ) {
        self.proportion = proportion
        self.length = length
    }
}

public enum SlideInPresentationVisualEffect {
    case dimming(alpha: CGFloat)
    case blur(style: UIBlurEffect.Style)
}

public class SlideInPresentationController: UIPresentationController {
    private let direction: SlideInPresentationDirection
    private let relativeSize: SlideInPresentationRelativeSize
    private let visualEffect: SlideInPresentationVisualEffect

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        direction: SlideInPresentationDirection,
        relativeSize: SlideInPresentationRelativeSize,
        visualEffect: SlideInPresentationVisualEffect
    ) {
        self.direction = direction
        self.relativeSize = relativeSize
        self.visualEffect = visualEffect
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.setupTapGesture()
        self.setupPanGesture()
    }

    private var interactionController: UIPercentDrivenInteractiveTransition? {
        didSet {
            guard let coordinator = presentedViewController.transitioningDelegate as? SlideInPresentationCoordinator else { return }
            coordinator.interactionController = interactionController
        }
    }

    lazy private var dimmingView: UIView = {
        guard case let .dimming(alpha) = visualEffect else { fatalError() }
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: alpha)
        dimmingView.alpha = 0.0
        return dimmingView
    }()

    lazy private var blurView: UIVisualEffectView = {
        guard case let .blur(style) = visualEffect else { fatalError() }
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = .clear
        return blurView
    }()

    private func setupTapGesture() {
        let recogniser = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )

        switch visualEffect {
        case .dimming:
            dimmingView.addGestureRecognizer(recogniser)
        case .blur:
            blurView.addGestureRecognizer(recogniser)
        }
    }

    @objc private func handleTap() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    private func setupPanGesture() {
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        presentedViewController.view.addGestureRecognizer(recogniser)
    }

    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent: CGFloat
        switch direction {
        case .left:
            percent = -translate.x / gesture.view!.bounds.size.width
        case .right:
            percent = translate.x / gesture.view!.bounds.size.width
        case .top:
            percent = -translate.y / gesture.view!.bounds.size.height
        case .bottom:
            percent = translate.y / gesture.view!.bounds.size.height
        }

        if gesture.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            presentingViewController.dismiss(animated: true, completion: nil)
        } else if gesture.state == .changed {
            interactionController?.update(percent)
        } else if gesture.state == .cancelled {
            interactionController?.cancel()
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: gesture.view)
            let condition: Bool
            switch direction {
            case .left:
                condition = (percent > 0.5 && velocity.x == 0) || velocity.x < 0
            case .top:
                condition = (percent > 0.5 && velocity.y == 0) || velocity.y < 0
            case .right:
                condition = (percent > 0.5 && velocity.x == 0) || velocity.x > 0
            case .bottom:
                condition = (percent > 0.5 && velocity.y == 0) || velocity.y > 0
            }
            if condition {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
    }

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }
        switch visualEffect {
        case .dimming:
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            containerView.insertSubview(dimmingView, at: 0)

            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        case .blur:
            blurView.translatesAutoresizingMaskIntoConstraints = false
            containerView.insertSubview(blurView, at: 0)

            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
                blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }

        guard let coordinator = presentedViewController.transitionCoordinator else {
            switch visualEffect {
            case .dimming:
                dimmingView.alpha = 1.0
            case .blur:
                break
            }
            return
        }
        coordinator.animate(
            alongsideTransition: { [weak self] context in
                guard let self = self else { return }
                switch self.visualEffect {
                case .dimming:
                    self.dimmingView.alpha = 1.0
                case .blur:
                    break
                }
            },
            completion: nil
        )
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if !completed {
            switch visualEffect {
            case .dimming:
                dimmingView.removeFromSuperview()
            case .blur:
                blurView.removeFromSuperview()
            }
        }
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            switch self.visualEffect {
            case .dimming:
                self.dimmingView.alpha = 0.0
            case .blur:
                break
            }
            return
        }
        coordinator.animate(
            alongsideTransition: { [weak self] context in
                guard let self = self else { return }
                switch self.visualEffect {
                case .dimming:
                    self.dimmingView.alpha = 0.0
                case .blur:
                    break
                }
            },
            completion: nil
        )
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            switch visualEffect {
            case .dimming:
                self.dimmingView.removeFromSuperview()
            case .blur:
                self.blurView.removeFromSuperview()
            }
        }
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    public override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(
                width: CGFloat(parentSize.width * relativeSize.length.rawValue),
                height: CGFloat(parentSize.height * relativeSize.proportion.rawValue)
            )
        case .top, .bottom:
            return CGSize(
                width: CGFloat(parentSize.width * relativeSize.proportion.rawValue),
                height: CGFloat(parentSize.height * relativeSize.length.rawValue)
            )
        }
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        guard let containerView = containerView else { return frame }

        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )

        switch direction {
        case .left:
            frame.origin.x = .zero
            frame.origin.y = (containerView.frame.height - frame.height) / 2
        case .top:
            frame.origin.x = (containerView.frame.width - frame.width) / 2
            frame.origin.y = .zero
        case .right:
            frame.origin.x = containerView.frame.width - frame.width
            frame.origin.y = (containerView.frame.height - frame.height) / 2
        case .bottom:
            frame.origin.x = (containerView.frame.width - frame.width) / 2
            frame.origin.y = containerView.frame.height - frame.height
        }
        return frame
    }
}
