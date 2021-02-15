//
//  PopUpViewController.swift
//  SampleApp
//
//  Created by Libor Kučera on 04.02.2021.
//

import UIKit
import ModalPresentation

class PopUpViewController: UIViewController {
    lazy var presenter: PopUpPresentationCoordinator = {
        let presenter = PopUpPresentationCoordinator()
        presenter.position = .value(
            CGRect(x: 65, y: 257, width: 284, height: 187)
        )
        presenter.visualEffect = .dimming(alpha: 0.5)
        return presenter
    }()

    enum SegueIdentifier: String {
        case openModal = "openModal"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Base View Controller"
        guard let background = UIImage(named: "dark") else { return }
        self.view.backgroundColor = UIColor(patternImage: background)

    }

    @IBOutlet weak var openButton: UIButton! {
        didSet {
            openButton.setTitleColor(.white, for: .normal)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifierValue = segue.identifier,
            let identifier = SegueIdentifier(rawValue: identifierValue),
            // let presentingViewController = segue.source as? PopUpViewController,
            let presentedViewController = segue.destination as? PopUpModalViewController
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch identifier {
        case .openModal:
            presentedViewController.modalPresentationStyle = .custom
            presentedViewController.transitioningDelegate = presenter
        }
    }
}
