//
//  ViewController.swift
//  Ripple
//
//  Created by Yoshihito Nakanishi on 2018/11/28.
//  Copyright © 2018年 Yoshihito Nakanishi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // タッチジェスチャ用のアウトレットを作成
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var audioPlayer: AVAudioPlayer!

    // 波紋のアニメーション用のインスタンスを作成
    var ripple = RippleView()
    
    let sounds = ["VSQSE_0668_water_drop_02",
                  "VSQSE_1142_pot_08_hitting",
                  "VSQSE_0360_tool_box_06",
                  "VSQSE_0936_lighter_02"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タッチジェスチャを初期化（呼ばれる関数を指定）
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // インタフェースが立ち上がったら波紋のアニメーション用のビュー（画面）を追加
        ripple = RippleView.init(frame: CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.width, height: view.bounds.height))
        view.addSubview(ripple)
    }
    
    @objc func didTouchDown(gesture: UITapGestureRecognizer){
        
        // タッチされたら
        if gesture.state == .began {
            
            // タッチされた座標を取得
            var point = CGPoint(x: 0, y: 0)
            
            
            point = gesture.location(in: gesture.view)
            
            // 波紋をタッチされた座標に表示
            ripple.setLayerPosition(point)
            playSound(name: "VSQSE_0668_water_drop_02")
            playSound(name: sounds.randomElement() ??  "VSQSE_0668_water_drop_02")

            
        } else if gesture.state == .ended { // optional for touch up event catching
            // do something else...
            print("tap up")
        }
        
        
    }

}


extension ViewController: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }

        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self

            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }
}
