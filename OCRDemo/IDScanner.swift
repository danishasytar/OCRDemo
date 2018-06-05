//
//  WinAppIDScanner.swift
//  Winapp
//
//  Created by megasap on 09/05/2018.
//  Copyright © 2018 Wazir. All rights reserved.
//

import UIKit
import GPUImage
import TesseractOCR
import MBProgressHUD


extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}


protocol IDScannerDelegate {
    func IDScannerDidfinishScaning(result : [String : Any])
}

open class IDScanner: NSObject, G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ConfirmIDCapturedDelegate {
    func continueWithImage() {
        //
    }
    
    func startRecording() {
        //
    }
    
    func stopRecording() {
        //
    }
    
    
    
    
    var ContainerVC : UIViewController
    var imagePicker : UIImagePickerController
    
    var delegate : IDScannerDelegate!
    
    var image : UIImage!
    
    var detector : CIDetector!
    
    var originalimage : UIImage!
    
    var IDCardToDetect : UIImage!
    
    

    
    public init (ContainerVC : UIViewController) {
        imagePicker = UIImagePickerController()
        self.ContainerVC = ContainerVC
        super.init()
//        self.setupScannerView()
    }
    
    
    func showHUD() {
//        let loadingNotification = MBProgressHUD.showAdded(to: overlayView, animated: true)
//        loadingNotification?.mode = MBProgressHUDMode.indeterminate
//        loadingNotification?.labelText = "Loading"
    }
    
    func hideHUD() {
//        MBProgressHUD.hideAllHUDs(for: overlayView, animated: true)
    }
    
    
    
//    func setupScannerView () {
//
//        imagePicker                     = UIImagePickerController()
//        imagePicker.allowsEditing       = false
//        imagePicker.sourceType          = .camera
//        imagePicker.cameraCaptureMode   = .photo
//        imagePicker.showsCameraControls = false
//        imagePicker.delegate            = self
//
//        let overlayView = self.overlayView
//        let width   = self.imagePicker.view.frame.width
//        let height  = self.imagePicker.view.frame.height
//        let frame   = CGRect(x: 0, y: 0, width: width, height: height)
//
//        overlayView.delegate            = self
//        overlayView.frame               = frame
//        imagePicker.cameraOverlayView   = overlayView
//
//    }
    
    func startScanning() {
        //        ContainerVC.present(imagePicker, animated: true, completion: {})
        let vc = RealTimeDetectorViewController()
        vc.vc = ContainerVC
        ContainerVC.present(vc, animated: true)
        
    }
    
    
    
    
//    fileprivate func processImage(_ image: UIImage) -> UIImage {
//
//        let threshold = GPUImageLuminanceThresholdFilter()
//        threshold.threshold = 0.22 // for name
//
//        let luminance = threshold.image(byFilteringImage: image)
//
//        let threshold2 = GPUImageAdaptiveThresholdFilter()
//        threshold2.blurRadiusInPixels = 4.0
//
//        return threshold.image(byFilteringImage: image)
//
//    }
    
    
    
    
    
    
    
    
    func cropToCardSize(image image: UIImage) -> UIImage {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.58]
        detector =  CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
        
        var resultImage: CIImage?
        let ciImage = CIImage(image: image)
        
        var pass = UIImage()
        if let detector = detector {
            // Get the detections
            let features = detector.features(in: ciImage!)
            for feature in features as! [CIRectangleFeature] {
                print(feature.topLeft)
                print(feature.topRight)
                print(feature.bottomLeft)
                print(feature.bottomRight)
                
                var businessCard: CIImage
                
                
                businessCard = ciImage!.applyingFilter(
                    "CIPerspectiveTransformWithExtent",
                    withInputParameters: [
                        "inputExtent": CIVector(cgRect: ciImage!.extent),
                        "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                        "inputTopRight": CIVector(cgPoint: feature.topRight),
                        "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                        "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
                businessCard = ciImage!.cropping(to: businessCard.extent)
                
                pass = convert(cmage: businessCard)
                
                
                //                let rotatedImage = pass.rotated(by: Measurement(value: 90.0, unit: .degrees))
                
                return pass
                
            }
        }
        return image
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
    
    
    //    public func preprocessedImage(for tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
    //        return processImage(sourceImage)
    //    }
    func extractNameAdress (_ image: UIImage) -> String {
        
        var tesseract:G8Tesseract = G8Tesseract(language:"ICNumber")
        tesseract.charWhitelist = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        tesseract.image = image
        tesseract.recognize()
        
        let text = tesseract.recognizedText
        
        let newString = text?.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
        return newString!
        
    }
    
    func startTakingPictures() {
        print("take")
        showHUD()
        self.imagePicker.takePicture()
    }
    
    func stopTakingPictures() {
        print("cancel")
        ContainerVC.dismiss(animated: true, completion: nil)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        ContainerVC.dismiss(animated: true, completion: nil)
        hideHUD()
        print(info)
        
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        beginDetection(image: info[UIImagePickerControllerOriginalImage] as! UIImage)
        
    }
    
    fileprivate func processImageIC(_ image: UIImage) -> UIImage {
        
        
        
        //        let BnWfilter = GPUImageGrayscaleFilter()
        //        let BnW = BnWfilter.image(byFilteringImage: image)
        //
        //
        //
        //        let contrastFilter = GPUImageContrastFilter()
        //        contrastFilter.contrast = 0.5
        //        let highcontrast = contrastFilter.image(byFilteringImage: BnW)
        //
        //        originalimage = highcontrast
        //
        //        let threshold = GPUImageLuminanceThresholdFilter()
        //        threshold.threshold = 0.4 // for name
        //
        let adaptive = GPUImageAdaptiveThresholdFilter()
        adaptive.blurRadiusInPixels = 4
        
        return adaptive.image(byFilteringImage: image)
        
        
        //        let luminance = threshold.image(byFilteringImage: image)
        //
        //        let threshold2 = GPUImageAdaptiveThresholdFilter()
        //        threshold2.blurRadiusInPixels = 4.0
        
        //        return threshold.image(byFilteringImage: highcontrast)
        //        return image
        
    }
    
    //manual crop
    //    func beginDetection(image : UIImage) {
    //
    //        //        let processed = processImage(oriimage)
    //
    //        /*minY - yposition from the top of the MyKad
    //         maxT - yposotion to the bottom of the MyKad
    //         most top 0.0
    //         most bottom 1.0*/
    //        let ic = processImage(cropTextSection(image: image, minY: 0.2, maxY: 0.3))
    //        let name = processImage(cropTextSection(image: image, minY: 0.55, maxY: 0.75))
    //        let address = processImage(cropTextSection(image: image, minY: 0.75, maxY: 0.95))
    //
    //        let extracticnum    = extractICNumber(ic)
    //        let extractname     = extractNameAdress(name)
    //        let extractaddress  = extractNameAdress(address)
    //
    //        print(extracticnum)
    //        print(extractname)
    //        print(extractaddress)
    //
    //        let mediaParam : [String:Any] = [
    //            "icnumberimage" : ic,
    //            "nameimage" : name,
    //            "addressimage" : address,
    //            "extracticnumber" : extracticnum,
    //            "extractname" : extractname,
    //            "extractaddress" : extractaddress
    //        ]
    //
    //
    //        //push to next vc for debugging and development purpose
    //        let vc = ResultViewController()
    //        vc.icnumimage = ic
    //        vc.nameimage = name
    //        vc.addressimage = address
    //        vc.icpassed = extracticnum
    //        vc.namepassed = extractname
    //        vc.addresspassed = extractaddress
    //
    //        ContainerVC.navigationController?.pushViewController(vc)
    //        delegate.winAppIDScannerDidfinishScaning(result : mediaParam)
    //    }
    
    //manual crop
    //    fileprivate func cropTextSection(image image: UIImage,minY miny: CGFloat, maxY maxy : CGFloat) -> UIImage {
    //
    //        let screenToImageRatio = (image.size.width/self.overlayView.width)
    //
    //        let height = maxy - miny
    //
    //        let oriimagex       = (self.overlayView.captureArea.frame.minX)*screenToImageRatio
    //        let oriimagey       = (self.overlayView.captureArea.frame.minY)*screenToImageRatio
    //        let oriimagewidth   = ((self.overlayView.captureArea.width)*screenToImageRatio)
    //        let orifimageheight = height*(self.overlayView.captureArea.height)*screenToImageRatio
    //
    //        let offsettoicnume  = (miny*(self.overlayView.captureArea.height))*screenToImageRatio
    //
    //        let rect = CGRect(x: oriimagey+offsettoicnume, y: oriimagex, width: orifimageheight, height: oriimagewidth)
    //
    //        let imageRef: CGImage! = image.cgImage!.cropping(to: rect)
    //
    //        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    //
    //        let filter = GPUImageCropFilter()
    //
    //        let selectedFilter = GPUImageTransformFilter()
    //        selectedFilter.setInputRotation(kGPUImageNoRotation, at: 0)
    //        let image: UIImage = selectedFilter.image(byFilteringImage: croppedImage)
    //
    //        let huhu = GPUImageCropFilter()
    //        huhu.cropRegion = CGRect(0.0,0.4,1.0,0.6)
    //
    //        let returnIMage = huhu.image(byFilteringImage: image)
    //        print(returnIMage)
    //        return returnIMage!
    //    }
    
    func recaptureImage() {
        
        print("recapture")
        
    }
    
//    func continueWithImage() {
//        print("cont")
//        print(IDCardToDetect.size)
//        IDCardToDetect = resizedImageWith(image: IDCardToDetect, targetSize: CGSize(width: IDCardToDetect.size.width/2, height: IDCardToDetect.size.height/2))
//        print(IDCardToDetect.size)
//
//
//
//        do {
//            let rotated = IDCardToDetect.rotated(by: Measurement(value: 90.0, unit: .degrees))
//
//
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsURL.appendingPathComponent("IC_image_front.png")
//            if let pngImageData = UIImagePNGRepresentation(rotated!) {
//                try pngImageData.write(to: fileURL, options: .atomic)
//            }
//        } catch { }
//
//        //        print(IDCardToDetect)
//
//        let ic = processImage(cropTextSection(image: IDCardToDetect, minY: 0.2, maxY: 0.3))
//        let name = processImage(cropTextSection(image: IDCardToDetect, minY: 0.55, maxY: 0.75))
//        let address = processImage(cropTextSection(image: IDCardToDetect, minY: 0.75, maxY: 0.99))
//
//        let extracticnum    = extractICNumber(ic)
//        let extractname     = extractNameAdress(name)
//        let extractaddress  = extractNameAdress(address)
//
//        print(extracticnum)
//        print(extractname)
//        print(extractaddress)
//
//        let resultParam : [String:Any] = [
//            "icnumberimage" : ic,
//            "nameimage" : name,
//            "addressimage" : address,
//            "extracticnumber" : extracticnum,
//            "extractname" : extractname,
//            "extractaddress" : extractaddress
//        ]
//
//
//        //push to next vc for debugging and development purpose
//        let vc = ResultViewController()
//        vc.icnumimage = ic
//        vc.nameimage = name
//        vc.addressimage = address
//        vc.icpassed = extracticnum
//        vc.namepassed = extractname
//        vc.addresspassed = extractaddress
//
//        ContainerVC.navigationController?.present(vc, animated: true)
//
//        delegate.IDScannerDidfinishScaning(result : resultParam)
//
//    }
    //with auto detect rectangle
    func beginDetection(image : UIImage) {
        
        /*minY - yposition from the top of the MyKad
         maxT - yposotion to the bottom of the MyKad
         most top 0.0
         most bottom 1.0*/
        
        var IDCardToDetect = cropToCardSize(image : image)
        
        if IDCardToDetect.size.width == 0 || IDCardToDetect.size.height == 0 {
            hideHUD()
            print("re capture")
            
            let refreshAlert = UIAlertController(title: "Error", message: "Unable to capture MyKad, please re-capture the image", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            ContainerVC.present(refreshAlert, animated: true, completion: nil)
            
            return
        }
        
        let confirmVC = ConfirmIDCapturedViewController()
        let toConfirm = IDCardToDetect
        confirmVC.imageToDisplay = toConfirm.rotated(by: Measurement(value: 90.0, unit: .degrees))
        confirmVC.delegate = self
        ContainerVC.present(confirmVC, animated: true, completion: nil)
        
        self.IDCardToDetect = IDCardToDetect
        
        //        print(IDCardToDetect.size)
        //        IDCardToDetect = resizedImageWith(image: IDCardToDetect, targetSize: CGSize(width: IDCardToDetect.size.width/2, height: IDCardToDetect.size.height/2))
        //        print(IDCardToDetect.size)
        //
        //
        //
        //        do {
        //            let rotated = IDCardToDetect.rotated(by: Measurement(value: 90.0, unit: .degrees))
        //
        //
        //            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //            let fileURL = documentsURL.appendingPathComponent("IC_image_front.png")
        //            if let pngImageData = UIImagePNGRepresentation(rotated!) {
        //                try pngImageData.write(to: fileURL, options: .atomic)
        //            }
        //        } catch { }
        //
        ////        print(IDCardToDetect)
        //
        //        let ic = processImage(cropTextSection(image: IDCardToDetect, minY: 0.2, maxY: 0.3))
        //        let name = processImage(cropTextSection(image: IDCardToDetect, minY: 0.55, maxY: 0.75))
        //        let address = processImage(cropTextSection(image: IDCardToDetect, minY: 0.75, maxY: 0.99))
        //
        //        let extracticnum    = extractICNumber(ic)
        //        let extractname     = extractNameAdress(name)
        //        let extractaddress  = extractNameAdress(address)
        //
        //        print(extracticnum)
        //        print(extractname)
        //        print(extractaddress)
        //
        //        let resultParam : [String:Any] = [
        //            "icnumberimage" : ic,
        //            "nameimage" : name,
        //            "addressimage" : address,
        //            "extracticnumber" : extracticnum,
        //            "extractname" : extractname,
        //            "extractaddress" : extractaddress
        //        ]
        //
        //
        //        //push to next vc for debugging and development purpose
        //        let vc = ResultViewController()
        //        vc.icnumimage = ic
        //        vc.nameimage = name
        //        vc.addressimage = address
        //        vc.icpassed = extracticnum
        //        vc.namepassed = extractname
        //        vc.addresspassed = extractaddress
        //
        //        ContainerVC.navigationController?.present(vc, animated: true)
        //
        //        delegate.winAppIDScannerDidfinishScaning(result : resultParam)
    }
    
    
    //with auto crop
    fileprivate func cropTextSection(image image: UIImage,minY miny: CGFloat, maxY maxy : CGFloat) -> UIImage {
        
        
        
        let imageRef: CGImage! = image.cgImage!
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        let selectedFilter = GPUImageTransformFilter()
        selectedFilter.setInputRotation(kGPUImageNoRotation, at: 0)
        let image: UIImage = selectedFilter.image(byFilteringImage: croppedImage)
        
        let filter = GPUImageCropFilter()
//        filter.cropRegion = CGRect(miny,0.4,maxy-miny,0.6)
        filter.cropRegion = CGRect(x: miny, y: 0.4, width: maxy-miny, height: 0.6)
        let cropped = filter.image(byFilteringImage: image)
        
        let imageRef2 : CGImage! = cropped!.cgImage!
        let returnIMage = UIImage(cgImage: imageRef2, scale: 1, orientation: UIImageOrientation.init(rawValue: 3)!)
        print(returnIMage)
        
        return returnIMage
        
        
        //        return image
    }
    
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    
    func resizedImageWith(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let imageSize = image.size
        let newWidth  = targetSize.width  / image.size.width
        let newHeight = targetSize.height / image.size.height
        var newSize: CGSize
        
        if(newWidth > newHeight) {
            newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
        } else {
            newSize = CGSize(width: imageSize.width * newWidth, height:  imageSize.height * newWidth)
        }
        
        let rect = CGRect(x : 0,y : 0,width : newSize.width, height : newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
}
