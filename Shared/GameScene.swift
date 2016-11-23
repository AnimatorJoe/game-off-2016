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

// MARK: Platform generic methods
class GameScene: SKScene {
    
    // MARK: Variables
    var initialCall = false
    
    // MARK: Internal SKNode references
    fileprivate var spinnyNode : SKShapeNode?
    fileprivate var badGuys : SKEmitterNode?
    var enemyList = [SKSpriteNode?](repeating: nil, count: 0)
    
    //En as Enemy Number
    //St as Deterioration Stage
    let en1st0 = SKTexture(imageNamed: "spacesprite1.0.png")
    let en2st0 = SKTexture(imageNamed: "spacesprite2.0.png")
    let en3st0 = SKTexture(imageNamed: "spacesprite3.0.png")
    
    let en1st1 = SKTexture(imageNamed: "spacesprite1.1.png")
    let en2st1 = SKTexture(imageNamed: "spacesprite2.1.png")
    let en3st1 = SKTexture(imageNamed: "spacesprite3.1.png")
    
    let en1st2 = SKTexture(imageNamed: "spacesprite1.2.png")
    let en2st2 = SKTexture(imageNamed: "spacesprite2.2.png")
    let en3st2 = SKTexture(imageNamed: "spacesprite3.2.png")
    
    let en1st3 = SKTexture(imageNamed: "spacesprite1.3.png")
    let en2st3 = SKTexture(imageNamed: "spacesprite2.3.png")
    let en3st3 = SKTexture(imageNamed: "spacesprite3.3.png")
    
    // MARK: Internal Variables
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
            self.addChild(badGuys)
        }
        
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
    
    // MARK: Player Deterioration
    func playerDeter() {
        badGuys?.particleBirthRate *= 0.45
    }
    
    // MARK: Spawn Other Enemies
    func spawnEnemies() {
        
        //Declorations
        let moveUp = SKAction.moveBy(x: self.size.width/2, y: self.size.height/2, duration: 3)
        let waitRandom = SKAction.wait(forDuration: TimeInterval(arc4random_uniform(UInt32(3))))
        var enemy = SKSpriteNode()
        
        //Randomly Selecting Sprite Type
        let selectTexture = arc4random() % 3
        
        switch selectTexture {
        case 0:
            enemy = SKSpriteNode(texture: en1st0)
            break;
        case 1:
            enemy = SKSpriteNode(texture: en2st0)
            break;
        case 2:
            enemy = SKSpriteNode(texture: en3st0)
            break;
        default:
            enemy = SKSpriteNode(texture: en1st0)
            
        }
        
        
        enemy.position = CGPoint(x: 0, y: 0)
        enemy.zPosition = 2
        enemy.xScale = 0.6
        enemy.yScale = 0.6
        self.addChild(enemy)
        
        enemy.run((SKAction.sequence([moveUp, waitRandom])), completion: { self.spawnEnemies() })
        
    }
    
    // MARK: In game calculations
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !initialCall{
            spawnEnemies()
            initialCall = true
        }
        
        playerDeter()
    
    }
    
    // MARK: Platform conditional SKView initialization
    #if os(watchOS)
        override func sceneDidLoad() {
            self.setUpScene()
        }
    #else
        override func didMove(to view: SKView) {
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
                print(t.location(in: self))
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
