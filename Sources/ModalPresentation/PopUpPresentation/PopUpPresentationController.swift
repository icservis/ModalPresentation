//
//  PopUpPresentationController.swift
//  ModalPresentation
//
//  Created by Libor Kučera on 05.02.2021.
//

import UIKit

public enum PopUpPresentationPosition {
    case middle(
            aspectRatio: CGFloat,
            relativeSize: CGFloat
         )
    case position(
            centerX: CGPoint,
            centerY: CGPoint,
            aspectRatio: CGFloat,
            relativeSize: CGFloat
         )
    case value(_ frame: CGRect)
}

public enum PopUpPresentationVisualEffect {
    case dimming(alpha: CGFloat)
    case blur(style: UIBlurEffect.Style)
}

public class PopUpPresentationController: UIPresentationController {
    private let position: PopUpPresentationPosition
    private let visualEffect: PopUpPresentationVisualEffect

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        position: PopUpPresentationPosition,
        visualEffect: PopUpPresentationVisualEffect
    ) {
        self.position = position
        self.visualEffect = visualEffect
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.setupTapGesture()
    }

    private var interactionController: UIPercentDrivenInteractiveTransition? {
        didSet {
            guard let coordinator = presentedViewController.transitioningDelegate as? PopUpPresentationCoordinator else { return }
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
        return CGSize(
            width: parentSize.width * 0.8,
            height: parentSize.height * 0.8
        )
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero

        guard let containerView = self.containerView else { return frame }

        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )

        frame.origin.x = (containerView.frame.width - frame.size.width) * 0.5
        frame.origin.y = UIScreen.main.bounds.maxY - frame.size.height
        return frame
    }
}
