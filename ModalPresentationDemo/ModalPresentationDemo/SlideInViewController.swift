//
//  SlideInViewController.swift
//  SampleApp
//
//  Created by Libor Kučera on 04.02.2021.
//

import UIKit
import ModalPresentation

class SlideInViewController: UIViewController {
    lazy var presenter = SlideInPresentationCoordinator()

    enum SegueIdentifier: String {
        case openModal = "openModal"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Base View Controller"
    }

    @IBOutlet weak var proportionControl: UISlider! {
        didSet {
            proportionControl.minimumValue = 0
            proportionControl.maximumValue = 1
            proportionControl.value = 0.4
        }
    }
    @IBAction func proportionValueChanged(_ sender: UISlider) {
        guard let proportion = SlideInPresentationProportion(value: CGFloat(sender.value)) else { return }
        presenter.proportion = proportion
    }

    @IBOutlet weak var directionControl: UISegmentedControl! {
        didSet {
            directionControl.selectedSegmentIndex = 3
        }
    }

    @IBAction func directionControlChanged(_ sender: UISegmentedControl) {
        guard let direction = SlideInPresentationDirection(rawValue: sender.selectedSegmentIndex) else { return }
        presenter.direction = direction
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifierValue = segue.identifier,
            let identifier = SegueIdentifier(rawValue: identifierValue),
            // let presentingViewController = segue.source as? SlideInViewController,
            let presentedViewController = segue.destination as? SlideInModalViewController
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch identifier {
        case .openModal:
            presentedViewController.modalPresentationStyle = .custom
            presentedViewController.transitioningDelegate = presenter
            presenter.proportion = .full
            presenter.dimmingEffect = .blur(style: .dark)
        }
    }
}

