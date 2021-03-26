//
//  GameScene.swift
//  SoloMission
//
//  Created by Fatimah Hussain on 3/12/21.
//

import SpriteKit
import GameplayKit

//COOL THING: if we declare it here, it becomes a public variable rather than a global variable and can be accessed by ALL scenes in the game

var gameScore = 0 //this is a var since the value of gameScore would change
//however, this means it will only be declared once, so the scores will keep on adding up and is only declared 0 ONCE , so you have to add gameScore = 0 in the didmovetoview scene

//SKPhysicsContactDelegate, can be used to find when two bodies touch
class GameScene: SKScene, SKPhysicsContactDelegate  {
    // we are declaring this globally, these are 'global' variables
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 5 //every time we loose a life, take one away, btw you can change this anytime
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    let bulletSound = SKAction.playSoundFileNamed("gunShot.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("Explosion+3.mp3", waitForCompletion: false) //false so next action in sequence starts right away
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    //we could do var currentGameState = "During" but we would have to check each time, so let's do...
    
    enum gameState{
        case preGame //when the game state is before the start of the game
        case inGame //when the game state is during the game
        case afterGame //when the game state is after the game
    }
    
    var currentGameState = gameState.preGame //current game state is storing the gameState, and is currently inGame because the game starts right away, and prevents two cases from occuring at the same time because it can only hold one case at a time. edit: for the tap to begin function, we need it to become the pregame status
    struct PhysicsCategories{
        //one for our player, enemy, bullet, and one for none
        //if two specific objects hit each other, they would bounce off each other, and we can specify this in this struct
        static let None : UInt32 = 0 //category called none which is represented by 0, phys body specified with None means don't collide with anything, etc.
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4, 3 would be the enemy and the player
    }
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    // the arrow means return--will return a CGFloat, will generate a random number between two numbers
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //contact between physical bodies, and we can be alerted by a code

    var gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0 //maxaspectratio--> the playable width
        let playableWidth = size.height/maxAspectRatio //how wide our game area is going to be
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height) // this is our game area
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        gameScore = 0 //re initialized to 0 every time we move into the game scene
        //we can use physics contact in the scene
        self.physicsWorld.contactDelegate = self
        for i in 0...1{ //every time this runs, i (the loop index) will start at a certain number. this loop will run twice, once at 0, and once at 1, in the case of 0...1.
        //this is going to happen straight away, on the scene on the screen
            let background  = SKSpriteNode(imageNamed: "background") //image object
            //it has to cover the entire scene, since it is a background
            background.size = self.size //matches the size of the scene (fills the scene)
                background.anchorPoint = CGPoint(x: 0.5, y: 0) //this anchor point is at the bottom middle of the screen
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))//needs an x and y coordination, given coordinates are the center point, add the second run, position it at the top of the screen
            //however, the ship moves off the screen on certain devices is because the background fits the biggest screen, which in this case is an ipad, so on a smaller screen like an iphone it will leave the screen instead of stopping on the sides, and we have to make sure all of the actual game happens is in the game area
            background.zPosition = 0  //this has to do with layering, the lower the number, the farther back
            background.name = "Background" //will have two backgrounds---affect both backgrounds
            self.addChild(background) //makes background
        }
    
        player.setScale(1) //sets scale of image
        player.position = CGPoint(x: self.size.width 
                                    / 2, y: 0 - player.size.height) //sets position of player, 20% up ( can also divide the height by 5) the player will be right at the bottom of the screen
        player.zPosition = 2 //as long as this is above the background, this will show. this will be set to 2 because we want the bullets to show in layering 1
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) //physics body same size as player, and can be forced by outer objects such as gravity, which we don't want
        player.physicsBody!.affectedByGravity = false //it has a physics body, but it won't be affected by force
        //when you start the game, you call this function below
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player //the physics body of the player is the category player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy //player can hit the enemy, when they hit, they will both be destroyed, which is one of the ways the game can end
        self.addChild(player) // curates it
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        //we have to lock it to the left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)//starting position is at the top of the screen
        scoreLabel.zPosition = 100 //making sure its on top of everything regarding labels
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 5"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height
        ) //adds height of the label so it starts at the top of the screen
        livesLabel.zPosition = 100 //cannot have a zposition higher than 100
        self.addChild(livesLabel) //now have a label in place to show our lives
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3) // only need to change y coordinate since x coordinate is correct
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        //mini transitions for the two labels
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tapToStartLabel.alpha = 0 //transparency, 0 is see through, and 1 is fully visible
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        //startNewLevel() no longer want to call this right away
    }
    
    //they are global because we only want them to be zero once, when the program starts
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0 //this will equal the diff between the time right now and the time of the last update funcion
    var amountToMovePerSecond: CGFloat = 600.0 //real control over the background with manual movement and playing around with the speed that the background moves
    override func update(_ currentTime: TimeInterval) {
        //store current time has last update time, and prep this in order to find delta time frame
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){ //this generates a list of all the nodes with the name "Background"
            background, stop in
            if self.currentGameState == gameState.inGame{ //if not, do not move the background, otherwise, if the game is ingame, then move the background
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height * 2
            }
        }
    }
    
    
    func startGame(){
        //all of our code to move from pregame state to during the game
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence) //this will delete the 'tap to begin' tag once the player has touched the screen. remember that this whole sequence is in touches began, since the player starts the game by touchign the screen
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence) //player will move onto the screen and then start the level
    }
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2) //params are size, duration
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }
    } //next up, when the enemy passes without getting hit player will also lose a life
    
    func addScore(){
    //simply call this function whenever we want to add a score
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)" //when bullet hits enemy, player wins
        
        ///if gameScore == 2 || gameScore == 3 || gameScore == 4 {// || means 'or'
        ///startNewLevel()
        ///}
    }
    
    func runGameOver(){
        //stop action to spawn enemies, bullets moving--basically freeze everything
        //show score, highscore, show gameover, and give player a chance to play
        currentGameState = gameState.afterGame
        self.removeAllActions() //stop the actions that are running on scene, stopped sequence that is spawning the enemies
        //find a way to get access to bullet and enemy and its current instance amd makes it stop moving on the scene, but you cannot do bullet.removeAllActions since its not declared, can't get direct access, if we declared it globally, it will only give one bullet at a time
        
        //generate list of all the objects on the scene with this reference name (of "Bullet")
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            
            bullet.removeAllActions() //remove everything as moving across the list
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence) //everything will freeze, wait for a scond, then move to gameoverscene
        
    
    }
    
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size:self.size) //make the scene the same size as the current scene
        sceneToMoveTo.scaleMode = self.scaleMode //scale it equally
        let myTransition = SKTransition.fade(withDuration: 0.5) //created transition, move to scene with transition
        self.view!.presentScene(sceneToMoveTo, transition: myTransition) //take the view that is current and replace it will the gameoverscene, fade over across half a secondd
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //runs when bodies that can contact come into contact
        //which two physics bodies have made been has been parsed in the function into body a or body b, and to the right thing according to what happens with the bullet.
        //organize the bodies to see which one they are, depending on their category number to tell which two physics bodies have made contact
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask //num associated with bitmask, whether that is 1,2,3,4
        {
            //body A has a higher category number then body B
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            //and vice versa
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            //if the player has hit the enemy
            //anything passed will be used as the position of the explosion
            if body1.node != nil {
            //only do this if there is a node there
            spawnExplosion(spawnPosition: body1.node!.position) //its ! bc its definitely going to be a node, ? means it might not be a node
            }
            //these nil statements prevent the game from crashing when two objects hit at once
            if body2.node != nil {
            spawnExplosion(spawnPosition: body2.node!.position) //if player hits enemy, we want both to explode
            //find body1 , node associated with it, and remove it
            }
            body1.node?.removeFromParent() //this is avoiding the tension for when 2 bullets hit the enemy at the same time
            body2.node?.removeFromParent()
            
            runGameOver() //run this function to end the game
        }
        
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{ //remove the final condition from here
              
       //The following bit has changed
                   if body2.node != nil{
                       if body2.node!.position.y > self.size.height{
                        addScore()
                           return //if the enemy is off the top of the screen, 'return'. This will stop running this code here, therefore doing nothing unless we hit the enemy when it's on the screen. As we are already checking that body2.node isn't nothing, we can safely unwrap (with '!)' this here.
                       }
                       else{
                        addScore()
                            spawnExplosion(spawnPosition: body2.node!.position)
                       }
                   }
        //Now, in the code that runs if the bullet hits the enemy, we check to see if the enemy is on the screen. After making sure the enemy actually exists in the if statement that says if body2.node != nil, we now check to see if the enemy is on the screen here. If the enemy isn't on the screen (if it's .position.y is greater than the height of the screen), we 'return'. This will stop running the code in this if statement there and then, and not run the rest of the code (the code to kill this enemy). This will have the same effect as not doing anything if the contact happens when the enemy is off the top of the screen - as we simply stop the code here before it can do anything to kill the enemy.
            
       //changes end here
                   
                   body1.node?.removeFromParent()
                   body2.node?.removeFromParent()
                   
                   
               }
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        //spawn this when we remove enemy or player ship
    }
    

    //goal of this function, spawn, wait, spawn, wait,
    func startNewLevel() { //this function will start a new level by spawning enemies
        ///levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies") //if we are running spawningEnemies, stop it. We do this because each time the level increases, we don't want enemies to spawn whilst the levels are changing
        }
        ///var levelDuration = TimeInterval()
        
        ///switch levelNumber {
        //case 1--level 1 and so on... only have 4 levels
        ///case 1: levelDuration = 1.2
        ///case 2: levelDuration = 1
        ///case 3: levelDuration = 0.8
        ///case 4: levelDuration = 0.5
        ///default:
           /// levelDuration = 0.5
          ///  print("Cannot find level info")
            
        ///}
        //this action will run spawnEnemy function
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1) //every second we get one enemy, the higher the level, the shorter the duration
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")//this action being run has a reference name--a key
        //feel free to play around with the duration if you'd like
        

        //it will start the game
    }
    
    
    //spawn and fire a bullet, call this bullet to fire a bullet
    func fireBullet() {
        //spawning a bullet
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet" //bullet now has a reference name
        bullet.setScale(1)
        bullet.position = player.position
        //by declaring player up above, we can use the player var here as well.
        bullet.zPosition = 1 //in front of the background, behind the ship
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None //don't want any collision
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy //can make contact with the enemy
        self.addChild(bullet)
        
        //actions; let is used to declare something new
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1) // move there in one second
        let deleteBullet = SKAction.removeFromParent() //this will delete the bullet
        //sequence (using a list) , move the bullet, then delete the bullet
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        // for the bulletSound, above code says waitforcompletion is False because right when the sound plays, the other actions in the sequence will go. If it was set to True, then it would fully play the sound then move on to the other items in the sequence
    }
    
    //we need to generate a random x coordinate for when enemy starts and when enemy ends
    func spawnEnemy() {
    
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        //times by 1.2 to get 20 percent of the top of the screen
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        //20 percent under the screen
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        //of the top of the screen in a random position going across the screen
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy //make a category called PhysicsCateogries.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None //dont want it to collide with anything
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet //we want the enemy body to come in contact with the player or the bullet, makes contact with the phys cat of the player of the phys cat of the bullet
        self.addChild(enemy)
        
        //move to the endpoint in 1.5 seconds
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        //we want to delete the enemy once it's off the screen
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife) //if the enemy passes the screen without getting shot, the player loses a life
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction]) //if the enemy leaves the bnottom of the screen, player will leave the screen
        
        //sometimes when the enemy spawns right as the game is over, it will still move across the scene, so we have to fix this by doing:
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        //what we have done here: spawned a random start point from the top screen up the screen to the end of the screen at the bottom of the screen (the endpoint), generated an enemy that moves from two two points
        
        //if you want to rotate an image, make it set to the right
        //find difference between the two points, the startPoint and the endPoint
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        //how much they rotate based on the difference between the two points
        enemy.zRotation = amountToRotate
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBullet() //call firebullet, go to function
        //spawnEnemy() just a test
        }
    }
    
    //ship will mirror finger movement, will run whenever we move finger around the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            //declaring something new
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x //find the two x coordinates and see the gap of where we were touching and where the finger is right now
            if currentGameState == gameState.inGame{ //when game over occurs, gamestate will turn into aftergame
                player.position.x += amountDragged //moves the players x position
            }
            //bump the player back into the game area, so it will look like the ship is locked in the game area, to make sure it hasn't gone too far left or too far right
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
                //dont let us go further than the point
            }
           
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
                //dont let us go further than the point
            }

            
        }
    }
}
