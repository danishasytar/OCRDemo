//
//  ResultViewController.swift
//  Winapp
//
//  Created by WinApp Administrator on 07/05/2018.
//  Copyright © 2018 Wazir. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var icnum: UIImageView!
    @IBOutlet weak var name: UIImageView!
    @IBOutlet weak var address: UIImageView!
    @IBOutlet weak var ictext: UILabel!
    @IBOutlet weak var nametext: UILabel!
    @IBOutlet weak var addresstext: UILabel!
    
    var icnumimage : UIImage! = UIImage()
    var nameimage : UIImage! = UIImage()
    var addressimage : UIImage! = UIImage()
    var icpassed : String!
    var namepassed : String!
    var addresspassed : String!
    
    override func viewDidLoad() {
       icnum.image = icnumimage
        name.image = nameimage
        address.image = addressimage
        ictext.text = icpassed
        nametext.text = namepassed
        addresstext.text = addresspassed
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
}
