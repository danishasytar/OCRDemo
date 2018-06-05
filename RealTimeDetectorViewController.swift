//
// Copyright 2014 Scott Logic
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import MobileCoreServices


class RealTimeDetectorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func stopTakingPictures() {
        //
        self.vc.dismiss(animated: true, completion: nil)
    }

    
    
    @IBOutlet weak var IDCardFrame: UIView!
    @IBOutlet weak var navBar: UINavigationBar!


    
    var videoFilter: CoreImageVideoFilter?
    var detector: CIDetector?
    
    var vc : UIViewController!

    var selfiImages : [UIImage] = []


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.setBackgroundImage(UIImage(), for: .default)
        self.navBar.shadowImage = UIImage()

        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create the video filter
        videoFilter = CoreImageVideoFilter(vc : self, superview: view, applyFilterCallback: nil)
        
        // Simulate a tap on the mode selector to start the process
        detector = prepareRectangleDetector()
        videoFilter?.applyFilter = {
            image in
            return self.performRectangleDetection(image)
        }
        videoFilter?.startFiltering()
        
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Utility methods
    func performRectangleDetection(_ image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        if let detector = detector {
            // Get the detections
            let features = detector.features(in: image)
            for feature in features as! [CIRectangleFeature] {
                resultImage = drawHighlightOverlayForPoints(image, topLeft: feature.topLeft, topRight: feature.topRight,
                                                            bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
            }
        }
        return resultImage
    }
    
    
    func prepareRectangleDetector() -> CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.75]
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    
    
    @IBAction func capture(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.capture = true
    }

    
    func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {

            var overlayLeft = CIImage(color: CIColor.red())
            var overlayTop = CIImage(color: CIColor.red())
            var overlayRight = CIImage(color: CIColor.red())
            var overlayBottom = CIImage(color: CIColor.red())

            
            overlayLeft = overlayLeft.cropping(to: image.extent)
            overlayTop = overlayTop.cropping(to: image.extent)
            overlayRight = overlayRight.cropping(to: image.extent)
            overlayBottom = overlayBottom.cropping(to: image.extent)
            
            
            
            overlayLeft = overlayLeft.applyingFilter("CIPerspectiveTransformWithExtent",
                                                     withInputParameters: [
                                                        "inputExtent": CIVector(cgRect: image.extent),
                                                        "inputTopLeft": CIVector(cgPoint: CGPoint(x: bottomLeft.x, y: bottomLeft.y+10)),
                                                        "inputTopRight": CIVector(cgPoint: CGPoint(x: bottomRight.x, y: bottomRight.y+10)),
                                                        "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                                        "inputBottomRight": CIVector(cgPoint: bottomRight)
                ])
            
            overlayTop = overlayTop.applyingFilter("CIPerspectiveTransformWithExtent",
                                                   withInputParameters: [
                                                    "inputExtent": CIVector(cgRect: image.extent),
                                                    "inputTopLeft": CIVector(cgPoint: topLeft),
                                                    "inputTopRight": CIVector(cgPoint: CGPoint(x: topLeft.x+10, y: topLeft.y)),
                                                    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                                    "inputBottomRight": CIVector(cgPoint: CGPoint(x: bottomLeft.x+10, y: bottomLeft.y))
                ])
            
            overlayRight = overlayRight.applyingFilter("CIPerspectiveTransformWithExtent",
                                                       withInputParameters: [
                                                        "inputExtent": CIVector(cgRect: image.extent),
                                                        "inputTopLeft": CIVector(cgPoint: topLeft),
                                                        "inputTopRight": CIVector(cgPoint: topRight),
                                                        "inputBottomLeft": CIVector(cgPoint: CGPoint(x: topLeft.x, y: topLeft.y-10)),
                                                        "inputBottomRight": CIVector(cgPoint: CGPoint(x: topRight.x, y: topRight.y-10))
                ])
            
            overlayBottom = overlayBottom.applyingFilter("CIPerspectiveTransformWithExtent",
                                                         withInputParameters: [
                                                            "inputExtent": CIVector(cgRect: image.extent),
                                                            "inputTopLeft": CIVector(cgPoint: CGPoint(x: topRight.x-10, y: topRight.y)),
                                                            "inputTopRight": CIVector(cgPoint: topRight),
                                                            "inputBottomLeft": CIVector(cgPoint: CGPoint(x: bottomRight.x-10, y: bottomRight.y)),
                                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
                ])
            
            let combine = overlayBottom.compositingOverImage(overlayRight.compositingOverImage(overlayTop.compositingOverImage(overlayLeft)))
            
            
            
            self.cropToRect(image: image, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
            
            return combine.compositingOverImage(image)


    }

    func cropToRect(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        
        var businessCard: CIImage
        businessCard = image.applyingFilter(
            "CIPerspectiveTransformWithExtent",
            withInputParameters: [
                "inputExtent": CIVector(cgRect: image.extent),
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)])
        businessCard = image.cropping(to: businessCard.extent)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let capture = appDelegate.capture
        
        
        if capture == true {
            print("haha")
            appDelegate.capture = false
            if let image : CIImage = image {
                
                let photoVC = PhotoViewController()
                print(image)
                photoVC.takenPhoto = image
                photoVC.VC = self.vc
                
                DispatchQueue.main.async {
                    self.videoFilter?.stopFiltering()
                    self.dismiss(animated: true, completion: nil)
                    self.vc.present(photoVC, animated: true, completion: nil)
                }
            }
        }
    }
}

