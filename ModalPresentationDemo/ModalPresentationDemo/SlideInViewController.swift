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
        guard let background = UIImage(named: "background") else { return }
        self.view.backgroundColor = UIColor(patternImage: background)

    }

    @IBOutlet weak var proportionControl: UISlider! {
        didSet {
            proportionControl.minimumValue = 0
            proportionControl.maximumValue = 1
            proportionControl.value = Float(presenter.proportion.value)
        }
    }
    @IBAction func proportionValueChanged(_ sender: UISlider) {
        guard let proportion = SlideInPresentationProportion(value: CGFloat(sender.value)) else { return }
        presenter.proportion = proportion
    }

    @IBOutlet weak var directionControl: UISegmentedControl! {
        didSet {
            directionControl.selectedSegmentIndex = presenter.direction.rawValue
        }
    }

    @IBAction func directionControlChanged(_ sender: UISegmentedControl) {
        guard let direction = SlideInPresentationDirection(rawValue: sender.selectedSegmentIndex) else { return }
        presenter.direction = direction
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
            presenter.visualEffect = .blur(style: .regular)
        }
    }
}

