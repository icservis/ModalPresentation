//
//  PopUpModalViewController.swift
//  SampleApp
//
//  Created by Libor Kučera on 04.02.2021.
//

import UIKit

class PopUpModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
