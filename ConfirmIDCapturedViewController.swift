//
//  ConfirmIDCapturedViewController.swift
//  Winapp
//
//  Created by WinApp Administrator on 21/05/2018.
//  Copyright © 2018 Wazir. All rights reserved.
//

import UIKit

protocol ConfirmIDCapturedDelegate {
    func recaptureImage()
    func continueWithImage()
}

class ConfirmIDCapturedViewController: UIViewController {
    @IBOutlet weak var IDImage: UIImageView!
    
    var imageToDisplay : UIImage!
    
    var delegate : ConfirmIDCapturedDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IDImage.image = imageToDisplay
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func recapture(_ sender: Any) {
        delegate.recaptureImage()
        self.dismiss(animated: true, completion: nil)

    }
    

    @IBAction func contnue(_ sender: Any) {
        delegate.continueWithImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
