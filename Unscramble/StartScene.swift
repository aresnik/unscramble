//
//  StartScene.swift
//  Unscramble
//
//  Created by Alex Resnik on 10/26/23.
//

import SpriteKit
import GameplayKit
import SwiftUI

class StartScene: SKScene {
    
    var splashScreen: SKSpriteNode
    var unscrambleLabel: SKLabelNode
    var colorsLabel: SKLabelNode

    var backColor: UIColor
    
    override init(size: CGSize) {

        backColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        splashScreen = SKSpriteNode(imageNamed: "unscramble")
        unscrambleLabel = SKLabelNode()
        colorsLabel = SKLabelNode()
        
        super.init(size: size)
    
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = backColor
        
        splashScreen.name = "Stop"
        splashScreen.size = CGSize(width: 600, height: 600)
        splashScreen.position = CGPoint(x: size.width/2, y: size.height*0.5)
        
        self.addChild(splashScreen)
        
        unscrambleLabel.text = "Unscramble"
        unscrambleLabel.fontName = "Bold"
        unscrambleLabel.fontSize = 70
        unscrambleLabel.fontColor = SKColor.white
        unscrambleLabel.horizontalAlignmentMode = .center
        unscrambleLabel.position = CGPoint(x: size.width/2,
                                     y: size.height * 0.20 )
        
        addChild(unscrambleLabel)
        
        colorsLabel.text = "Colors"
        colorsLabel.fontName = "Bold"
        colorsLabel.fontSize = 70
        colorsLabel.fontColor = SKColor.white
        colorsLabel.horizontalAlignmentMode = .center
        colorsLabel.position = CGPoint(x: size.width/2,
                                     y: size.height * 0.12 )
        
        addChild(colorsLabel)
        
        let scaleOut = SKAction.scale(to: 0.2, duration: 0)
        let scaleIn = SKAction.scale(to: 0.5, duration: 1)
        
        splashScreen.run(scaleOut)
        splashScreen.run(scaleIn)
        unscrambleLabel.run(scaleOut)
        unscrambleLabel.run(scaleIn)
        colorsLabel.run(scaleOut)
        colorsLabel.run(scaleIn)
        
        let runAction = SKAction.run { self.changeScene() }
        let waitAction = SKAction.wait(forDuration: 2)
        let sequenceAction = SKAction.sequence([waitAction, runAction])
        
        run(sequenceAction)

    }
    
    func changeScene() {
        
        let sceneToMoveTo = GameScene(size: self.size)
        let myTransition = SKTransition.fade(withDuration: 0.5)
        
        sceneToMoveTo.scaleMode = self.scaleMode
        
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
    }
}

struct StartSceneView: View {

    var body: some View {
        SpriteView(scene: StartScene(size:CGSize(width: gameWidth, height: gameHeight)))
            .ignoresSafeArea()
    }
}

#Preview {
    StartSceneView()
}
