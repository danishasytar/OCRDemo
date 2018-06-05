//
//  ViewController.swift
//  OCRDemo
//
//  Created by megasap on 30/05/2018.
//  Copyright © 2018 danish. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IDScannerDelegate {
    func IDScannerDidfinishScaning(result: [String : Any]) {
        //
    }
    
    @IBOutlet weak var label: UILabel!
    var threshold : CGFloat = 0.00
    @IBAction func plus(_ sender: Any) {

        
        
        self.threshold = self.threshold + 0.01
        let x = Double(threshold)
        self.label.text = String(x)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        let capture = appDelegate.capture
        appDelegate.thresholdOffset = self.threshold as! CGFloat
    }
    
    
    @IBAction func minus(_ sender: Any) {
        let x = Double(threshold)
        self.threshold = self.threshold - 0.01
        self.label.text = String(x)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        let capture = appDelegate.capture
        appDelegate.thresholdOffset = self.threshold as! CGFloat
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let x = Double(threshold)

        self.label.text = String(x)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var Scanner : IDScanner!


    @IBAction func startScan(_ sender: Any) {
        self.Scanner = IDScanner(ContainerVC : self)
        self.Scanner.delegate = self
        self.Scanner.startScanning()
    }
    
}

