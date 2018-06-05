//
//  PhotoViewController.swift
//  CustomCamera
//
//  Created by Brian Advent on 24/01/2017.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import UIKit
import TesseractOCR
import GPUImage

class PhotoViewController: UIViewController, G8TesseractDelegate {
    
    var takenPhoto:CIImage?
    
    var detector : CIDetector!
    var VC : UIViewController!
    var IDCardToDetect : UIImage!
    
    var thresholdoffset : CGFloat!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tap)

        
        let IDCardToDetect = cropToCardSize(image : takenPhoto!)
        self.IDCardToDetect = IDCardToDetect
        
        imageView.image = IDCardToDetect.rotated(by: Measurement(value: 90.0, unit: .degrees))
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.thresholdoffset = appDelegate.thresholdOffset
        print(self.thresholdoffset)

        
    }
    
    @IBAction func button(_ sender: Any) {
        self.execute()
    }
    func handleTap() {
        
    }
    
    fileprivate func processImageIC(_ image: UIImage) -> UIImage {
        
        let threshold = GPUImageLuminanceThresholdFilter()
        threshold.threshold = 0.30 + thresholdoffset // for name
        
        return GPUImageAdaptiveThresholdFilter().image(byFilteringImage: image)
        
    }
    
    
    fileprivate func processImage(_ image: UIImage) -> UIImage {
        
        let a = GPUImageLuminanceThresholdFilter()
        a.threshold = 0.34
        return a.image(byFilteringImage: image)
        
    }
    
    

    
    func execute() {
//        let ic = processImageIC(cropTextSection(image: IDCardToDetect, minY: 0.25, maxY: 0.35))
//        let name = processImage(cropTextSection(image: IDCardToDetect, minY: 0.56, maxY: 0.77))
//        let address = processImage(cropTextSection(image: IDCardToDetect, minY: 0.77, maxY: 0.99))

        IDCardToDetect = processImage(IDCardToDetect)
        
        let ic = cropTextSection(image: IDCardToDetect, minY: 0.24, maxY: 0.34)
        let name = cropTextSection(image: IDCardToDetect, minY: 0.56, maxY: 0.77)
        let address = cropTextSection(image: IDCardToDetect, minY: 0.77, maxY: 0.99)
        
        let extracticnum    = extractICNumber(ic)
        let extractname     = extractNameAdress(name)
        let extractaddress  = extractNameAdress(address)
        
        print(extracticnum)
        print(extractname)
        print(extractaddress)

        
        let vc = ResultViewController()
        vc.icnumimage = ic
        vc.nameimage = name
        vc.addressimage = address
        vc.icpassed = extracticnum
        vc.namepassed = extractname
        vc.addresspassed = extractaddress
        
        self.dismiss(animated: true, completion: nil)
        VC.present(vc, animated: true, completion: nil)
    }
    
    func extractNameAdress (_ image: UIImage) -> String {
        
        var tesseract:G8Tesseract = G8Tesseract(language:"ICNumber")
        tesseract.charWhitelist = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        tesseract.image = image
        tesseract.recognize()
        
        let text = tesseract.recognizedText
        
        let newString = text?.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
        return newString!
        
    }
    
    

    
    func extractICNumber (_ image: UIImage) -> String {
        
        var tesseract:G8Tesseract = G8Tesseract(language:"ICNumber")
        tesseract.charWhitelist = "0123456789";
        tesseract.image = image
        tesseract.recognize()
        tesseract.delegate = self
        let text = tesseract.recognizedText
        
        let newString = text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let newString3 = newString?.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        //        return tesseract.recognizedText
        if (newString3?.count)! > 12 {
            return  (newString3?.substring(to:newString3!.index(newString3!.startIndex, offsetBy: 12)))!
        }
        return newString3!
    }
    
    
    
    fileprivate func cropTextSection(image image: UIImage,minY miny: CGFloat, maxY maxy : CGFloat) -> UIImage {
        
        
        
        let imageRef: CGImage! = image.cgImage!
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        let selectedFilter = GPUImageTransformFilter()
        selectedFilter.setInputRotation(kGPUImageNoRotation, at: 0)
        let image: UIImage = selectedFilter.image(byFilteringImage: croppedImage)
        
        let filter = GPUImageCropFilter()
        //        filter.cropRegion = CGRect(miny,0.5,maxy-miny,0.5)
        filter.cropRegion = CGRect(x: miny, y: 0.4, width: maxy-miny, height: 0.6)
        let cropped = filter.image(byFilteringImage: image)
        
        let imageRef2 : CGImage! = cropped!.cgImage!
        let returnIMage = UIImage(cgImage: imageRef2, scale: 1, orientation: UIImageOrientation.init(rawValue: 3)!)
        print(returnIMage)
        
        return returnIMage
        
        
        //        return image
    }
    
    
    func cropToCardSize(image image: CIImage) -> UIImage {
        
        //        let contrast = GPUImageContrastFilter()
        
        //        let image : UIImage = contrast.image(byFilteringImage: image)
        
        
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh,CIDetectorAspectRatio : 1.5]
        detector =  CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
        
        var resultImage: CIImage?
        
        
        var pass = UIImage()
        if let detector = detector {
            // Get the detections
            let features = detector.features(in: image )
            print(features)
            
            for feature in features as! [CIRectangleFeature] {
                print(feature.topLeft)
                print(feature.topRight)
                print(feature.bottomLeft)
                print(feature.bottomRight)
                
                var businessCard: CIImage
                
                
                businessCard = image.applyingFilter(
                    "CIPerspectiveTransformWithExtent",
                    withInputParameters: [
                        "inputExtent": CIVector(cgRect: image.extent),
                        "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                        "inputTopRight": CIVector(cgPoint: feature.topRight),
                        "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                        "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
                businessCard = image.cropping(to: businessCard.extent)
                
                pass = convert(cmage: businessCard)
                
                
                
                //                let rotatedImage = pass.rotated(by: Measurement(value: 90.0, unit: .degrees))
                
                return pass
                
            }
        }
        return UIImage()
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
}
