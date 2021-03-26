//
//  GameOverScene.swift
//  SoloMission
//
//  Created by Fatimah Hussain on 3/23/21.
//

//reminder that the name of the file is not the name of the scene--we have to name it
import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    //now we need a label that will act as a button, THE same as a normal label
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")

    //this will run as soon as we move into the gameoverscene
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background") //starry sky background
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2) //or can multiply it by 1/2, this centers it on the screen
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x:self.size.width * 0.5, y:self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        //label that will show our final score
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        //want to get access to gamescore from gamescene
        scoreLabel.text = "Score: \(gameScore)" //i think you can check the tpye of variable as you are typing it
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        //have to figure out what the player's high score is by accessing users info that even saves after user has exited the app
        let defaults = UserDefaults()
        //above will let us gain access to info we saved and we can save additional info
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved") //highscore number will be set to highScoreSaved, if the game hasn't been played the game will just load zero
        
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved") //can get the high score by looking at user details at the VALUE (an integer) at key of highscoresaved
        }
        //if not, then continue on with the following code, if yes for above statement, go through that if statement, and go to the following code:
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.45)
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width / 2 , y: self.size.height * 0.3)
        self.addChild(restartLabel)
    }
    //going to run whenever the screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches { // we will use this to make our restart label a button , we can get
            //we can use touch to get all the info on what we touched and WHERE we touched the screen
            let pointOfTouch = touch.location(in: self) // take the coordinates of wherre we touched and store in as a coordinate in pointoftouch
            //gain straight access to restartLabel here
            if restartLabel.contains(pointOfTouch){ //if we touched anywhere on the label, and now it works as a button
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
            
            
        }
    }
    
}
