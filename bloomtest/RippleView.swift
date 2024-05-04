 //
//  RippleView.swift
//  Ripple
//
//  Created by Yoshihito Nakanishi on 2018/11/28.
//  Copyright © 2018年 Yoshihito Nakanishi. All rights reserved.
//

import UIKit

// アニメーションを表示するためのクラス
class RippleView : UIView {
    
    // 円表示用のレイヤーを準備
    var circle: CircleLayer! = nil
    
    //
    var layers = [CircleLayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawCircle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    // 円を書く
    func drawCircle(){
        
        // レイヤーに円を追加
        layers.append(CircleLayer())
        let count = layers.count - 1
        
        //色や大きさ、アニメーションの情報をアップデート
        layers[count].frame = self.frame
        layers[count].actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()] //disable implicit animations
        layers[count].setColor(color: UIColor.random().cgColor)
        self.layer.addSublayer(layers[count])
        
        // レイヤーを表示
        layers[count].setNeedsDisplay()
        
    }
    
    //　円のポジションを設定
    func setLayerPosition(_ point: CGPoint){
        
        self.layers.last?.position = point
        
        self.layers.last?.animate(point) { (result) in
            self.layers.first?.removeFromSuperlayer()
            self.layers.remove(at: 0)
        }
        
        drawCircle()
    }
    
    
}

// 波紋のアニメーションを作成するためのクラス
class CircleLayer : CAShapeLayer {
    
    var shapeColor: CGColor! = nil
    var ovalShapeLayer = CAShapeLayer()
    let currentCircleSize : CGFloat = 10.0
    let targetCircleSize : CGFloat = 300.0
    
    override init() {
        super.init()
    }
    
    override init(layer: Any?) {
        if let layer = layer as? CircleLayer {
            shapeColor = layer.shapeColor
        }
        super.init(layer: layer!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplay(forKey forkey: String) -> Bool {
        
        if forkey == "shapeColor" {
            return true
        }
        return super.needsDisplay(forKey: forkey)
    }
    
    override func draw(in context: CGContext) {
        ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(x:(self.bounds.width/2) - (currentCircleSize/2),
                                                          y:(self.bounds.height/2) - (currentCircleSize/2),
                                                          width:currentCircleSize, height:currentCircleSize)).cgPath
        ovalShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ovalShapeLayer.isHidden = true
        self.addSublayer(ovalShapeLayer)
        
    }
    
    public func setColor(color : CGColor){
        ovalShapeLayer.fillColor = color
    }
    
    public func animate(_ point: CGPoint, completion: ((Bool) -> Void)?){
        
        ovalShapeLayer.isHidden = false
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { // callback
            
            self.ovalShapeLayer.isHidden = true
            self.ovalShapeLayer.removeAllAnimations()
            
            if let completion = completion {
                completion(true)
            }
            
        }
        
        let animationDuration = 5.0
        let pathAnimation = CABasicAnimation(keyPath: "path") // パスを指定
        pathAnimation.toValue = UIBezierPath(ovalIn: CGRect(x: (self.bounds.width/2) - (targetCircleSize/2),
                                                            y: (self.bounds.height/2) - (targetCircleSize/2),
                                                            width: targetCircleSize, height: targetCircleSize)).cgPath // 終了値
        
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity") // 不透明度を指定
        fadeOutAnimation.fromValue = 0.5 // 開始値
        fadeOutAnimation.toValue   = 0 // 終了値
        
        
        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = 0 // 開始時間
        animationGroup.duration = animationDuration  // アニメーション時間
        animationGroup.animations = [pathAnimation, fadeOutAnimation]
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false // アニメーション終了後にフレームを残す
        
        ovalShapeLayer.add(animationGroup,forKey: nil)
        
        CATransaction.commit()
        
    }
    
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
    
    static func randomBlue() -> UIColor {
        return UIColor(red:   0,
                       green: 0,
                       blue:  .random(),
                       alpha: 1.0)
    }
    
    static func randomRed() -> UIColor {
        return UIColor(red:   .random(),
                       green: 0,
                       blue:  0,
                       alpha: 1.0)
    }
}
