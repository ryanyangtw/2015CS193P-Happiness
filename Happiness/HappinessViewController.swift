//
//  HappinessViewController.swift
//  Happiness
//
//  Created by Ryan on 2015/4/1.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, FaceViewDataSource {
  
  @IBOutlet weak var faceView: FaceView! {
    // This property observer will called when the storyboard being loaded
    didSet {
      faceView.dataSource = self
      
      // Using code to add the Recongnizer
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
    }
  }
  
  private struct Constants {
    static let HappinessGestureScale: CGFloat = 4
  }
  
  // add the Recongnizer by interface builder
  @IBAction func changeHappiness(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .Ended: fallthrough
    case .Changed:
      let translation = gesture.translationInView(faceView)
      //println("translation.y: \(translation.y)")
      let happinessChange = Int( -translation.y/Constants.HappinessGestureScale )
      if happinessChange != 0 {
        happiness += happinessChange
        gesture.setTranslation(CGPointZero, inView: faceView)
      }
    default: break
    }
  }
  
  var happiness: Int = 10 { // 0 = very sad, 100 = ecstatic
    didSet {
      // keep it between 0 - 100
      happiness = min(max(happiness, 0), 100)
      updateUI()
    }
  }
  
  
  func updateUI() {
    faceView.setNeedsDisplay()
  }
  
// MARK: FaceView DataSource
  func smilinessForFaceView(sender: FaceView) -> Double? {
    return Double(happiness-50)/50
  }
  

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }



}
