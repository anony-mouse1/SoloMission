//
//  GameViewController.swift
//  SoloMission
//
//  Created by Fatimah Hussain on 3/12/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
            
    super.viewDidLoad()
            if let view = self.view as! SKView? {

                // Load the SKScene from 'GameScene.sks'

                let scene = GameScene(size: CGSize(width: 1536, height: 2048))

                    // Set the scale mode to scale to fit the window

                    scene.scaleMode = .aspectFill
                    
                    // Present the scene

                    view.presentScene(scene)
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true

                view.showsNodeCount = true
            }

        }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
