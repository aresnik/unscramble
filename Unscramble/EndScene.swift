//
//  EndScene.swift
//  Unscramble
//
//  Created by Alex Resnik on 10/26/23.
//

import SpriteKit
import GameplayKit
import SwiftUI

class EndScene: SKScene {
    
    var gameOverLabel: SKLabelNode
    var timeLabel: SKLabelNode
    var movesLabel: SKLabelNode
    var bestLabel: SKLabelNode
    var movesBestLabel: SKLabelNode
    var timeBestLabel: SKLabelNode
    var playAgainButton: SKLabelNode
    var playAgainBoarder: SKShapeNode
    
    var backColor: UIColor
    
    override init(size: CGSize) {
        
        gameOverLabel = SKLabelNode()
        timeLabel = SKLabelNode()
        movesLabel = SKLabelNode()
        bestLabel = SKLabelNode()
        movesBestLabel = SKLabelNode()
        timeBestLabel = SKLabelNode()
        playAgainButton = SKLabelNode()
        playAgainBoarder = SKShapeNode()
        
        backColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        super.init(size: size)
    
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = backColor
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontName = "Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: size.width/2,
                                         y: size.height - long)
        gameOverLabel.name = "gameover"
        
        addChild(gameOverLabel)
        
        timeLabel.text = "Time: \(timeCurrent)"
        timeLabel.fontName = "Bold"
        timeLabel.fontSize = 25
        timeLabel.fontColor = SKColor.white
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: size.width*0.1 ,
                                     y: size.height*0.65 )
        timeLabel.name = "timeLabel"
        
        addChild(timeLabel)
        
        movesLabel.text = "Moves: \(movesCurrent)"
        movesLabel.fontName = "Bold"
        movesLabel.fontSize = 25
        movesLabel.fontColor = SKColor.white
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.position = CGPoint(x: size.width*0.6,
                                     y: size.height*0.65 )
        timeLabel.name = "movesLabel"
        
        addChild(movesLabel)
        
        bestLabel.text = "Best:"
        bestLabel.fontName = "Bold"
        bestLabel.fontSize = 25
        bestLabel.fontColor = SKColor.white
        bestLabel.horizontalAlignmentMode = .center
        bestLabel.position = CGPoint(x: self.size.width/2,
                                     y: self.size.height*0.55 )
        bestLabel.name = "bestLabel"
        
        addChild(bestLabel)
        
        movesBestLabel.text = "Time: \(timeBest)"
        movesBestLabel.fontName = "Bold"
        movesBestLabel.fontSize = 25
        movesBestLabel.fontColor = SKColor.white
        movesBestLabel.horizontalAlignmentMode = .left
        movesBestLabel.position = CGPoint(x: size.width*0.1,
                                          y: size.height*0.45 )
        movesBestLabel .name = "movesbestlabel "
        
        addChild(movesBestLabel )
        
        timeBestLabel.text = "Moves: \(movesBest)"
        timeBestLabel.fontName = "Bold"
        timeBestLabel.fontSize = 25
        timeBestLabel.fontColor = SKColor.white
        timeBestLabel.horizontalAlignmentMode = .left
        timeBestLabel.position = CGPoint(x: size.width*0.6,
                                     y: size.height*0.45 )
        timeBestLabel.name = "timebestlabel"
        
        addChild(timeBestLabel)
        
        playAgainButton.text = "Play Again"
        playAgainButton.fontName = "Bold"
        playAgainButton.fontSize = 25
        playAgainButton.fontColor = SKColor.white
        playAgainButton.horizontalAlignmentMode = .center
        playAgainButton.position = CGPoint(x: Int(size.width/2), y: Int(size.height*0.3 - 80))
        playAgainButton.name = "playagian"
        
        addChild(playAgainButton)
        
        playAgainBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 75),
                                                    y: Int(size.height*0.3 - 102),
                                                    width: 150,
                                                    height: 60),
                                                    cornerRadius: 30)
        playAgainBoarder.fillColor = .clear
        playAgainBoarder.strokeColor = .white
        playAgainBoarder.lineWidth = 2.5
        playAgainBoarder.name = "playagainboarder"
        
        addChild(playAgainBoarder)
    }
    
    @objc func buttonAction() {
      print("Button tapped")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            if touchedNode.name == "playagainboarder" {
                playAgainButton.fontColor = SKColor.gray
                playAgainBoarder.strokeColor = SKColor.gray
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            if touchedNode.name == "playagainboarder" {
                playAgainButton.fontColor = SKColor.white
                playAgainBoarder.strokeColor = SKColor.white
                
                 changeScene()
            }
        }
    }
    
    func changeScene() {
        
        let sceneToMoveTo = GameScene(size: self.size)
        let myTransition = SKTransition.fade(withDuration: 0.5)
        
        sceneToMoveTo.scaleMode = self.scaleMode
        
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
    }
}

struct EndSceneView: View {

    var body: some View {
        VStack {
            SpriteView(scene: EndScene(size:CGSize(width: gameWidth, height: gameHeight)))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    EndSceneView()
}
