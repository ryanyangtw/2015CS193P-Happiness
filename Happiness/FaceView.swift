//
//  FaceView.swift
//  Happiness
//
//  Created by Ryan on 2015/4/1.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

// Shouldn't implement the method in protocol
protocol FaceViewDataSource: class {
  func smilinessForFaceView(sender: FaceView) -> Double? // nil means no smile
}

@IBDesignable
class FaceView: UIView {

  @IBInspectable
  var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
  
  @IBInspectable
  var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
  
  @IBInspectable
  var scale: CGFloat = 0.90 { didSet {setNeedsDisplay()} }
  
  var faceCenter: CGPoint {
    // convert the center oint coordination from superview to self
    return convertPoint(center, fromView: superview)
  }
  
  var faceRadius: CGFloat {
    return (min(bounds.size.width, bounds.size.height) / 2) * scale
  }
  
  // weak: avoid memory scycle
  weak var dataSource: FaceViewDataSource?
  
  
  // init from code
  override init (frame: CGRect) {
    super.init(frame: frame)
  }
  
  // init from storyboard
  required init (coder: NSCoder) {
    super.init(coder: coder)
    println("init")
    //opaque = false
    //alpha = 1
    backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.1)
    //backgroundColor = UIColor.redColor()
  }
  
  private struct Scaling {
    static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
    static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
    static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
    static let FaceRadiusToMouthWidthRatio: CGFloat = 1
    static let FaceRadiusToMouthHeightRatio: CGFloat = 3
    static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
  }
  
  private enum Eye { case Left, Right}
  
  private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
    
    let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
    let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
    let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
    
    var eyeCenter = faceCenter
    eyeCenter.y -= eyeVerticalOffset
    
    switch whichEye {
    case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
    case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
    }
    
    let path = UIBezierPath(
      arcCenter: eyeCenter,
      radius: eyeRadius,
      startAngle: 0,
      endAngle: CGFloat(2*M_PI),
      clockwise: true
    )
    
    path.lineWidth = lineWidth
    
    
    //var context = UIGraphicsGetCurrentContext()
    //println("bezierPathForEye context: \(context)")
    
    return path
  }
  
  private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
  
    let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
    let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
    let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
  
    let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
    
    let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
    let end = CGPoint(x: start.x + mouthWidth, y: start.y)
    let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
    let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
    
    //let cp2 = CGPoint.zeroPoint
    
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
    path.lineWidth = lineWidth
    
    //var context = UIGraphicsGetCurrentContext()
    //println("bezierPathForSmile context: \(context)")
    
    return path
  }
  
  
  func scale(gesture: UIPinchGestureRecognizer) {
    println("gesture.state: \(gesture.state)")
    if gesture.state == .Changed {
      scale *= gesture.scale
      gesture.scale = 1
    }
  }
  
  
  override func drawRect(rect: CGRect) {
    
    // be careful of the wierd error message
    // Always using CGFloat when drawing
    let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
    facePath.lineWidth = lineWidth
    
    // set the color.setStroke() & color.setFill at the same time
    color.set()
    facePath.stroke()
    
    bezierPathForEye(.Left).stroke()
    bezierPathForEye(.Right).stroke()
    
    let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
    let smilePath = bezierPathForSmile(smiliness)
    smilePath.stroke()
    
    
    
    /*
    let path = UIBezierPath()
    path.moveToPoint(CGPoint.zeroPoint)
    path.addLineToPoint(CGPoint(x: 140, y: 150))
    path.addLineToPoint(CGPoint(x: 10, y: 150))
    
    path.closePath()
    
    UIColor.greenColor().setFill()
    UIColor.redColor().setStroke()
    path.lineWidth = 6.0
    path.stroke()
    */
    
    //var context = UIGraphicsGetCurrentContext()
    //println("fuck yoou context: \(context)")
    
  }
  


}
