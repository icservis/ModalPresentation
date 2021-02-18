//
//  SlideInViewController.swift
//  SampleApp
//
//  Created by Libor Kučera on 04.02.2021.
//

import UIKit
import ModalPresentation

class SlideInViewController: UIViewController {
    lazy var presenter: SlideInPresentationCoordinator = {
        let presenter = SlideInPresentationCoordinator()
        return presenter
    }()

    enum SegueIdentifier: String {
        case openModal = "openModal"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Base View Controller"
        guard let background = UIImage(named: "light") else { return }
        self.view.backgroundColor = UIColor(patternImage: background)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visualEffectControl.selectedSegmentIndex = presenter.visualEffect.visualEffectControlSegmentIndex
        changeVisualEffetSettings()
    }

    @IBOutlet weak var lengthControl: UISlider! {
        didSet {
            lengthControl.minimumValue = 0
            lengthControl.maximumValue = 1
            lengthControl.value = Float(presenter.relativeSize.length.rawValue)
        }
    }
    @IBAction func lengthValueChanged(_ sender: UISlider) {
        guard let length = SlideInPresentationRelativeSize.Length(rawValue: CGFloat(sender.value)) else { return }
        presenter.relativeSize = SlideInPresentationRelativeSize(
            proportion: presenter.relativeSize.proportion,
            length: length
        )
    }

    @IBOutlet weak var proportionControl: UISlider! {
        didSet {
            proportionControl.minimumValue = 0
            proportionControl.maximumValue = 1
            proportionControl.value = Float(presenter.relativeSize.proportion.rawValue)
        }
    }
    @IBAction func proportionValueChanged(_ sender: UISlider) {
        guard let proportion = SlideInPresentationRelativeSize.Proportion(rawValue: CGFloat(sender.value)) else { return }
        presenter.relativeSize = SlideInPresentationRelativeSize(
            proportion: proportion,
            length: presenter.relativeSize.length
        )
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

    @IBOutlet weak var visualEffectControl: UISegmentedControl! {
        didSet {

        }
    }

    @IBAction func visualEffectChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            let alpha = CGFloat(dimmingAlphaControl.value)
            presenter.visualEffect = .dimming(alpha: alpha)
        case 1:
            guard let style = UIBlurEffect.Style(rawValue: blurStyleControl.selectedSegmentIndex) else { return }
            presenter.visualEffect = .blur(style: style)
        default:
            break
        }
        changeVisualEffetSettings()
    }

    @IBOutlet weak var dimmingAlphaControl: UISlider! {
        didSet {
            dimmingAlphaControl.minimumValue = 0
            dimmingAlphaControl.maximumValue = 1
        }
    }

    @IBAction func dimmingAlphaChanged(_ sender: UISlider) {
        let alpha = CGFloat(sender.value)
        presenter.visualEffect = .dimming(alpha: alpha)
    }

    @IBOutlet weak var blurStyleControl: UISegmentedControl! {
        didSet {

        }
    }

    @IBAction func blurStyleChanged(_ sender: UISegmentedControl) {
        let style = UIBlurEffect.Style.style(for: sender.selectedSegmentIndex)
        presenter.visualEffect = .blur(style: style)
    }

    private func changeVisualEffetSettings() {
        switch presenter.visualEffect {
        case let .dimming(alpha: alpha):
            dimmingAlphaControl.value = Float(alpha)

            dimmingAlphaControl.isHidden = false
            blurStyleControl.isHidden = true
        case let .blur(style: style):
            blurStyleControl.selectedSegmentIndex = min(style.selectedIndex, blurStyleControl.numberOfSegments)

            blurStyleControl.isHidden = false
            dimmingAlphaControl.isHidden = true
        }
    }

    @IBOutlet weak var openButton: UIButton! {
        didSet {
            openButton.setTitleColor(.black, for: .normal)
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
        }
    }
}

extension SlideInPresentationVisualEffect {
    var visualEffectControlSegmentIndex: Int {
        switch self {
        case .dimming:
            return 0
        case .blur:
            return 1
        }
    }
}

extension UIBlurEffect.Style {
    var selectedIndex: Int {
        switch self {
        case .extraLight:
            return 0
        case .light:
            return 1
        case .dark:
            return 2
        case .regular:
            return 3
        default:
            return 4
        }
    }

    static func style(for selectedIndex: Int) -> UIBlurEffect.Style {
        switch selectedIndex {
        case 0:
            return UIBlurEffect.Style.extraLight
        case 1:
            return UIBlurEffect.Style.light
        case 2:
            return UIBlurEffect.Style.dark
        case 3:
            return UIBlurEffect.Style.regular
        default:
            return UIBlurEffect.Style.prominent
        }
    }
}

