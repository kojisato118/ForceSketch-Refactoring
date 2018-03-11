//
//  SketchView.swift
//  ForceSketch-Refactoring
//
//  Created by 佐藤 康次 on 2018/02/22.
//  Copyright © 2018年 toosaa. All rights reserved.
//

import UIKit

class SketchView: UIView {
    // InterfaceBuilder
    @IBOutlet weak var imageView: UIImageView!
    let hsb = CIFilter(name: "CIColorControls",
                       withInputParameters: [kCIInputBrightnessKey: 0.05])!
    let gaussianBlur = CIFilter(name: "CIGaussianBlur",
                                withInputParameters: [kCIInputRadiusKey: 1])!
    let compositeFilter = CIFilter(name: "CISourceOverCompositing")!
    // iOS 11だとimageAccumulator.setImage()で落ちる
    var imageAccumulator: CIImageAccumulator!
    
    var previousTouchLocation: CGPoint?
    
    func startMonitoring(){
        // formatとかをいくつか変えてみたけどダメ
        imageAccumulator = CIImageAccumulator(extent: self.frame, format: kCIFormatARGB8)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    //@objc付ける
    @objc func step()
    {
        if previousTouchLocation == nil
        {
            hsb.setValue(imageAccumulator.image(), forKey: kCIInputImageKey)
            gaussianBlur.setValue(hsb.value(forKey: kCIOutputImageKey) as! CIImage, forKey: kCIInputImageKey)
            
            //こいつが元凶
            imageAccumulator.setImage(gaussianBlur.value(forKey: kCIOutputImageKey) as! CIImage)
            
            imageView.image = UIImage(ciImage: imageAccumulator.image())
        }
    }
    
    // swift2->3の第一引数変わるやーつ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        previousTouchLocation = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let event = event,
            let coalescedTouches = event.coalescedTouches(for: touch) else
        {
            return
        }
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        guard let cgContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        guard let previousPoint = previousTouchLocation else {
            return
        }
        
        //オブジェクト指向っぽくなった
        cgContext.setLineCap(CGLineCap.round)
        
        for coalescedTouch in coalescedTouches
        {
            let lineWidth = coalescedTouch.force != 0 ?
                (coalescedTouch.force / coalescedTouch.maximumPossibleForce) * 20 :
            10
            
            let lineColor = coalescedTouch.force != 0  ?
                UIColor(hue: coalescedTouch.force / coalescedTouch.maximumPossibleForce, saturation: 1, brightness: 1, alpha: 1).cgColor :
                UIColor.gray.cgColor
            
            cgContext.setLineWidth(lineWidth)
            cgContext.setStrokeColor(lineColor)
            
            cgContext.move(to: previousPoint)
            cgContext.addLine(to: coalescedTouch.location(in: self))
            cgContext.strokePath()
            
            previousTouchLocation = coalescedTouch.location(in: self)
        }
        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let image = drawnImage else {
            return
        }

        compositeFilter.setValue(CIImage(image: image),
                                 forKey: kCIInputImageKey)
        compositeFilter.setValue(imageAccumulator.image(),
                                 forKey: kCIInputBackgroundImageKey)
        
        imageAccumulator.setImage(compositeFilter.value(forKey: kCIOutputImageKey) as! CIImage)
        
        self.imageView.image = UIImage(ciImage: imageAccumulator.image())
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        previousTouchLocation = nil
    }
}
