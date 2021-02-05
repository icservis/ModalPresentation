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
        presenter.visualEffect = .blur(style: .regular)
        return presenter
    }()

    enum SegueIdentifier: String {
        case openPopup = "openPopup"
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
        case .openPopup:
            presentedViewController.modalPresentationStyle = .custom
            presentedViewController.transitioningDelegate = presenter
        }
    }
}
