//
//  EndScene.swift
//  Unscramble
//
//  Created by Alex Resnik on 10/26/23.
//

import SpriteKit
import GameplayKit
import SwiftUI
import GameKit

class EndScene: SKScene {
    
    var gameOverLabel: SKLabelNode = SKLabelNode()
    var timeLabel: SKLabelNode = SKLabelNode()
    var movesLabel: SKLabelNode = SKLabelNode()
    var bestLabel: SKLabelNode = SKLabelNode()
    var movesBestLabel: SKLabelNode = SKLabelNode()
    var timeBestLabel: SKLabelNode = SKLabelNode()
    var playAgainButton: SKLabelNode = SKLabelNode()
    var playAgainBoarder: SKShapeNode  = SKShapeNode()
    
    var backColor: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    
    override func didMove(to view: SKView) {
        
        backgroundColor = backColor
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontName = "Bold"
        gameOverLabel.fontSize = 45
        gameOverLabel.fontColor = .white
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: size.width/2,
                                         y: size.height - long)
        gameOverLabel.name = "gameoverlabel"
        
        addChild(gameOverLabel)
        
        timeLabel.text = "Time: \(timeCurrent)"
        timeLabel.fontName = "Bold"
        timeLabel.fontSize = 25
        timeLabel.fontColor = .white
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: size.width*0.1 ,
                                     y: size.height*0.65 )
        timeLabel.name = "timelabel"
        
        addChild(timeLabel)
        
        movesLabel.text = "Moves: \(movesCurrent)"
        movesLabel.fontName = "Bold"
        movesLabel.fontSize = 25
        movesLabel.fontColor = .white
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.position = CGPoint(x: size.width*0.6,
                                     y: size.height*0.65 )
        timeLabel.name = "moveslabel"
        
        addChild(movesLabel)
        
        bestLabel.text = "Best:"
        bestLabel.fontName = "Bold"
        bestLabel.fontSize = 25
        bestLabel.fontColor = .white
        bestLabel.horizontalAlignmentMode = .center
        bestLabel.position = CGPoint(x: self.size.width/2,
                                     y: self.size.height*0.55 )
        bestLabel.name = "bestlabel"
        
        addChild(bestLabel)
        
        movesBestLabel.text = "Time: \(timeBest)"
        movesBestLabel.fontName = "Bold"
        movesBestLabel.fontSize = 25
        movesBestLabel.fontColor = .white
        movesBestLabel.horizontalAlignmentMode = .left
        movesBestLabel.position = CGPoint(x: size.width*0.1,
                                          y: size.height*0.45 )
        movesBestLabel .name = "movesbestlabel "
        
        addChild(movesBestLabel )
        
        timeBestLabel.text = "Moves: \(movesBest)"
        timeBestLabel.fontName = "Bold"
        timeBestLabel.fontSize = 25
        timeBestLabel.fontColor = .white
        timeBestLabel.horizontalAlignmentMode = .left
        timeBestLabel.position = CGPoint(x: size.width*0.6,
                                     y: size.height*0.45 )
        timeBestLabel.name = "timebestlabel"
        
        addChild(timeBestLabel)
        
        playAgainButton.text = "Play Again"
        playAgainButton.fontName = "Bold"
        playAgainButton.fontSize = 25
        playAgainButton.fontColor = .white
        playAgainButton.horizontalAlignmentMode = .center
        playAgainButton.position = CGPoint(x: Int(size.width/2), y: Int(size.height*0.3 - 80))
        playAgainButton.name = "playagainbutton"
        
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
        
        if GKLocalPlayer.local.isAuthenticated {
            GKAccessPoint.shared.location = .topTrailing
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
        } else {
            print("Game Center not authenticated")
        }
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
