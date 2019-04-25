//
//  GameScene.swift
//  Project 11
//
//  Created by Koty Stannard on 4/16/19.
//  Copyright © 2019 Koty Stannard. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var ballCountLabel: SKLabelNode!
    
    let colors = ["Red", "Blue", "Green", "Cyan", "Purple", "Yellow", "Grey"]
    
    var ballCount = 5 {
        didSet {
            ballCountLabel.text = "Ball Count: \(ballCount)"
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //add slot bases
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        //add physics
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        //add bouncers to the scene
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        //Add player score to top right of screen
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //Add edit button to scene
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        //Add ball count to scene
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Ball Count: 5"
        ballCountLabel.horizontalAlignmentMode = .right
        ballCountLabel.position = CGPoint(x: 980, y: 650)
        addChild(ballCountLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //attempt to read the first touch that came in
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let objects = nodes(at: touchLocation)
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
        
            let size = CGSize(width: Int.random(in: 16...128), height: 16)
            let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
            
            if editingMode {
                
                box.name = "box"
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = touchLocation
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                
                addChild(box)
            } else {

                var ball = SKSpriteNode()

                //choose random ball color
                for color in colors.shuffled() {
                    ball = SKSpriteNode(imageNamed: "ball\(color)")
                }

                ball.name = "ball"
                
                //allow the ball to behave like a ball, not a square
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                
                //detect collisions of the ball
                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                
                //determine the bounciness of the balls
                ball.physicsBody?.restitution = 0.4
                ball.position = touchLocation
                ball.position.y = 768
                
                //if player has enough balls, drop the ball
                //else game over
                if ballCount > 0 {
                    addChild(ball)
                } else {
                    
                    //Present alert when user has ran out of balls & allow to reset game
                    let alert = UIAlertController(title: "Game Over!", message: "You have ran out of balls!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                        self.resetGame()
                    }))
                    
                    if let viewController = self.scene?.view?.window?.rootViewController {
                        viewController.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        //add bouncer
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        //when false, the object will collide with things, but won't move as a result
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    //load slotBase, slotGlow graphic
    //position them where needed
    //add them to the scene
    //create spin, run forever
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCount += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            ballCount -= 1
        } else if object.name == "box" {
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    @objc func resetGame() {
        score = 0
        ballCount = 5
        
        //delete all boxes upon reset
        for child in self.children {
            if child.name == "box" {
                child.removeFromParent()
            }
        }
    }
}
