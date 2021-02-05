//
//  UIViewControllerAnimatedTransitioningPhase.swift
//  ModalPresentation
//
//  Created by Libor Kučera on 05.02.2021.
//

import UIKit

enum UIViewControllerAnimatedTransitioningPhase {
    case presentation
    // case management
    case dismissal
}

extension UIViewControllerAnimatedTransitioningPhase {
    var transitionContextViewControllerKey: UITransitionContextViewControllerKey {
        switch self {
        case .presentation:
            return .to
        case .dismissal:
            return .from
        }
    }
}
