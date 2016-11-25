//
//  GameScene.swift
//  GameOff
//
//  Created by Eli Bradley on 11/1/16.
//  Copyright © 2016 Eli Bradley. All rights reserved.
//

import SpriteKit
#if os(watchOS)
    import WatchKit
    // <rdar://problem/26756207> SKColor typealias does not seem to be exposed on watchOS SpriteKit
    typealias SKColor = UIColor
#endif

// MARK: SKSpriteNode extension to support deterioration.
class SKEnemyNode: SKSpriteNode {
    
    // MARK: Deterioration stages
    enum Deterioration {
        case perfectShape
        case goodShape
        case badShape
        case finishHim
    }
    
    // MARK: Internal enemy state
    var deteriorationStage: Deterioration = .perfectShape
    let deteriorationRate: CGFloat = 0.95
    var health: CGFloat = 4.0
    var textureArray: [SKTexture?]?
    
    // MARK: Sibling information
    var gameScene: GameScene?
    
    // MARK: Make enemy deteriorate.
    func deteriorate() {
        // If health will pass 3.0, 2.0, or 1.0
        if (Int(health) > Int(health*deteriorationRate)) {
            switch (deteriorationStage) {
                case .perfectShape:
                    deteriorationStage = .goodShape
                    self.texture = textureArray?[1]
                case .goodShape:
                    deteriorationStage = .badShape
                    self.texture = textureArray?[2]
                case .badShape:
                    deteriorationStage = .finishHim
                    self.texture = textureArray?[3]
                case .finishHim:
                    self.isHidden = true
                    _ = gameScene?.enemyArray.remove(at: (gameScene?.enemyArray.index(where: { $0 == self }))!)
                    gameScene?.spawnEnemies()
                    self.removeFromParent()
            }
        }
        
        health *= deteriorationRate
    }
}

// MARK: Platform generic methods
class GameScene: SKScene {
    
    // MARK: Internal SKNode and texture references
    fileprivate var spinnyNode : SKShapeNode?
    fileprivate var badGuys : SKEmitterNode?
    fileprivate var mobSizeLabel: SKLabelNode?
    fileprivate var overScreen: SKShapeNode?
    fileprivate var deathLabel = SKLabelNode()
    fileprivate var pLabel = SKLabelNode()
    let textureAtlas = SKTextureAtlas(named: "Enemy Sprite Atlas")
    var textureMatrix = [[SKTexture?]](repeating: [SKTexture?](repeating: nil, count: 4), count: 3)
    var enemyArray = [SKEnemyNode?](repeating: nil, count: 0)
    var playerDidDie = false
    
    // MARK: Configuration variables.
    let spinnyStuff = UserDefaults.standard.value(forKey: "spinnyStuff") ?? false
    
    // MARK: Initialize with SKS contents
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    // MARK: Scene setup
    func setUpScene() {
        self.badGuys = SKEmitterNode(fileNamed: "BadGuysMob")
        if let badGuys = self.badGuys {
            badGuys.position = CGPoint(x: 0,
                                       y: 0)
            
            badGuys.setScale(5)
            badGuys.zPosition = 3
            badGuys.isHidden = false
            badGuys.particleBirthRate = 0.5
            badGuys.setScale(3)
            self.addChild(badGuys)
        }
        
        self.mobSizeLabel = self.childNode(withName: "mobSizeLabel") as? SKLabelNode
        mobSizeLabel?.fontName = "Menlo"
        mobSizeLabel?.fontColor = UIColor.green
        mobSizeLabel?.position = CGPoint(x: self.size.width * 1/5, y: self.size.height * 2/5)
        
        self.overScreen = self.childNode(withName: "overScreen") as? SKShapeNode
        self.overScreen?.strokeColor = UIColor.gray
        self.overScreen?.fillColor = UIColor.black
        
        // Restart label, displayed on death
        deathLabel.fontSize = 30
        deathLabel.setScale(0.33)
        deathLabel.fontName = "Menlo"
        deathLabel.fontColor = UIColor.green
        deathLabel.position = CGPoint(x: 0,y: -15)
        deathLabel.zPosition = 15
        self.overScreen?.addChild(deathLabel)
        
        // Score label, displayed on death
        pLabel.fontSize = 45
        pLabel.setScale(0.18)
        pLabel.fontName = "Menlo"
        pLabel.fontColor = UIColor.green
        pLabel.position = CGPoint(x: 0,y: 15)
        self.overScreen?.addChild(pLabel)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        // Setup spinny nodes
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
        
        for enemy in 1...3 {
            for stage in 0...3 {
                textureMatrix[enemy-1][stage] = textureAtlas.textureNamed("spacesprite\(enemy)-\(stage)")
            }
        }
        
        spawnEnemies()
    }

    // MARK: Makes spinny stuff
    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    // MARK: Move "hackers" to player taps at constant speed
    func moveBadGuys(_ pos: CGPoint){
        badGuys?.removeAllActions()
        badGuys?.run(SKAction.move(to: pos, duration: TimeInterval.init(
            sqrt(pow(pos.x-badGuys!.frame.origin.x,2)+pow(pos.y-badGuys!.frame.origin.y,2))/100.0)))
    }
    
    // MARK: Player deterioration
    func playerDeter() {
        badGuys?.particleBirthRate *= 0.999
        
        for enemy in enemyArray {
            if enemy!.intersects(badGuys!) {
                if badGuys!.particleBirthRate * 5 < enemy!.health {
                    badGuys?.particleBirthRate *= 0.999
                    enemy?.deteriorate()
                } else {
                    enemy?.deteriorate()
                    badGuys?.particleBirthRate += enemy!.health * (1 - enemy!.deteriorationRate)
                }
            }
        }
    }
    
    // MARK: Spawn other enemies
    func spawnEnemies() {
        if !playerDidDie {
            let enemyNumber = Int(arc4random_uniform(3))
            let waitRandom = SKAction.wait(forDuration: TimeInterval(arc4random_uniform(UInt32(2))))
            let enemy = SKEnemyNode(texture: textureMatrix[enemyNumber][0])
            var moveEnemy = SKAction()
        
            enemy.textureArray = textureMatrix[enemyNumber]
            enemy.gameScene = self
        
            // Add enemy to scene
            switch arc4random_uniform(4) {
                // Move from top to bottom
                case 0:
                    enemy.position = CGPoint(x: self.size.width/2 - CGFloat(arc4random_uniform(UInt32(self.size.width))),
                                             y: self.size.height * 0.55 + CGFloat(arc4random_uniform(UInt32(self.size.height/9))))
                    moveEnemy = SKAction.moveBy(x: CGFloat((self.size.width/2) - CGFloat(arc4random_uniform(UInt32(self.size.width)))) - enemy.position.x,
                                                y: (self.size.height * -3/5) - enemy.position.y,
                                                duration: 15.0 + Double(arc4random_uniform(10)))
                
                // Move from bottom to top
                case 1:
                    enemy.position = CGPoint(x: self.size.width/2 - CGFloat(arc4random_uniform(UInt32(self.size.width))),
                                             y: self.size.height * -0.55 - CGFloat(arc4random_uniform(UInt32(self.size.height/9))))
                    moveEnemy = SKAction.moveBy(x: CGFloat((self.size.width/2) - CGFloat(arc4random_uniform(UInt32(self.size.width)))) - enemy.position.x,
                                                y: (self.size.height * 3/5) - enemy.position.y,
                                                duration: 15.0 + Double(arc4random_uniform(10)))
                
                // Move from left to right
                case 2:
                    enemy.position = CGPoint(x: self.size.width * -0.55 - CGFloat(arc4random_uniform(UInt32(self.size.width/9))),
                                             y:self.size.height/2 - CGFloat(arc4random_uniform(UInt32(self.size.height))))
                    moveEnemy = SKAction.moveBy(x: CGFloat((self.size.width/2) + CGFloat(arc4random_uniform(UInt32(self.size.width)))) - enemy.position.x,
                                                y: CGFloat((self.size.height/2) - CGFloat(arc4random_uniform(UInt32(self.size.height)))) - enemy.position.y,
                                                duration: 15.0 + Double(arc4random_uniform(10)))
                
                // Move from right to left
                case 3:
                    enemy.position = CGPoint(x: self.size.width * 0.55 + CGFloat(arc4random_uniform(UInt32(self.size.width/9))),
                                             y:self.size.height/2 - CGFloat(arc4random_uniform(UInt32(self.size.height))))
                    moveEnemy = SKAction.moveBy(x: CGFloat(-(self.size.width/2) - CGFloat(arc4random_uniform(UInt32(self.size.width)))) - enemy.position.x,
                                                y: CGFloat((self.size.height/2) - CGFloat(arc4random_uniform(UInt32(self.size.height)))) - enemy.position.y,
                                                duration: 15.0 + Double(arc4random_uniform(10)))
                
                default:
                    print("arc4random_uniform(u_int32_t upper_bound); failure")
            }
            
            
            enemy.zPosition = 2
            enemy.setScale(CGFloat(UInt32(5) + (arc4random_uniform(UInt32(3))))/10)
            self.addChild(enemy)
            enemyArray.append(enemy)
            
            // Spawn more enemies
            enemy.run(SKAction.sequence([moveEnemy, waitRandom,SKAction.removeFromParent()]))
        }
    }
    
    // MARK: Check player death
    func checkDeath() {
        if (Int(badGuys!.particleBirthRate*100) == 0) {
            badGuys!.particleBirthRate = 0
            
            self.overScreen?.setScale(0)
            self.overScreen?.isHidden = false
            self.overScreen?.alpha = 1
            self.badGuys?.isHidden = false
            
            deathLabel.text = "Tap to Restart"
            pLabel.text = "Militia Terminated"
            
            self.scene?.isUserInteractionEnabled = false
            self.overScreen?.run(SKAction.scale(to: 4.0, duration: 1.5))
            self.playerDidDie = true
        }
    }
    
    // MARK: Score update
    func scoreUpdate() {
        self.mobSizeLabel?.text = "Mob Count: \(Int(badGuys!.particleBirthRate*100))"
        
        if (Int(badGuys!.particleBirthRate * 100) <= 5) {
            self.mobSizeLabel?.fontColor = UIColor.red
        } else if (Int(badGuys!.particleBirthRate * 100) <= 50) {
            self.mobSizeLabel?.fontColor = UIColor.white
        } else {
            self.mobSizeLabel?.fontColor = UIColor.green
        }
    }
    
    // MARK: In game calculations
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        playerDeter()
        scoreUpdate()
        checkDeath()
    }
    
    // MARK: Platform conditional SKView initialization
    #if os(watchOS)
        override func sceneDidLoad() {
            self.setUpScene()
        }
    #else
        override func didMove(to view: SKView) {
    
            //Matching Dimensions
            self.size.width = UIScreen.main.bounds.width * 2
            self.size.height = UIScreen.main.bounds.height * 2
            print("Screen Width: \(String(describing: self.size.width))")
            print("Screen Height: \(String(describing: self.size.height))")
    
            self.setUpScene()
        }
    #endif
}


// MARK: tvOS and iOS setup
#if os(iOS) || os(tvOS)
    // Touch-based event handling
    extension GameScene {

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                if self.spinnyStuff as! Bool {
                    self.makeSpinny(at: t.location(in: self), color: SKColor.green)
                }
                moveBadGuys(t.location(in: self))
            }
        }
    
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                if self.spinnyStuff as! Bool {
                    self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
                }
                moveBadGuys(t.location(in: self))
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                if self.spinnyStuff as! Bool {
                    self.makeSpinny(at: t.location(in: self), color: SKColor.red)
                }
                moveBadGuys(t.location(in: self))
            }
        }
    
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                if self.spinnyStuff as! Bool {
                    self.makeSpinny(at: t.location(in: self), color: SKColor.red)
                }
                moveBadGuys(t.location(in: self))
            }
        }
    }
#endif


// MARK: macOS setup
#if os(macOS)
    // Mouse-based event handling
    extension GameScene {

        override func mouseDown(with event: NSEvent) {
            if self.spinnyStuff as! Bool {
                self.makeSpinny(at: event.location(in: self), color: SKColor.green)
            }
            moveBadGuys(event.location(in: self))
        }
    
        override func mouseDragged(with event: NSEvent) {
            if self.spinnyStuff as! Bool {
                self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
            }
            moveBadGuys(event.location(in: self))
        }
    
        override func mouseUp(with event: NSEvent) {
            if self.spinnyStuff as! Bool {
                self.makeSpinny(at: event.location(in: self), color: SKColor.red)
            }
            moveBadGuys(event.location(in: self))
        }
    }
#endif
