//
//  GameScene.swift
//  Unscramble
//
//  Created by Alex Resnik on 1/4/23.
//

import SpriteKit
import GameplayKit
import AVFAudio
import SwiftUI
import UIKit

var movesCurrent: Int = 0
var timeCurrent: String = ""
var movesBest: Int = 0
var timeBest: String = ""

class GameScene: SKScene {
    
    private var timeLabel: SKLabelNode
    private var movesLabel: SKLabelNode
    private var winLabel: SKLabelNode
    private var okButton: SKLabelNode
    private var okBoarder: SKShapeNode
    
    private let clr: [SKColor]
    private var color: [SKColor]
    
    private var tile: [SKShapeNode]
    private var tilePosition: [CGPoint]
    private var overlay: [SKShapeNode]
    private var popOver: SKShapeNode
    
    private var backColor: SKColor
    
    private let cols: Int = 6
    private let rows: Int = 9
    private let w: Int = 55
    private let h: Int = 55
    private let pos: CGFloat = 60
    
    private var soundPlayer: AVAudioPlayer = AVAudioPlayer()
    
    private var time: String = "00:00:00"
    private var moves: Int = 0
    private var timer: Timer = Timer()
    private var elapsed: Int = 0
    private var elapsedBest: Int = 0
    
    override init(size: CGSize) {
        
        clr = [ .white, .blue, .red, .green, .orange, .yellow, .clear ]
        
        color =  [ clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[5],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[5],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[6] ]
        
        backColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        tile = [SKShapeNode]()
        tilePosition = [CGPoint]()
        overlay = [SKShapeNode]()
        popOver = SKShapeNode()
        timeLabel = SKLabelNode()
        movesLabel = SKLabelNode()
        winLabel = SKLabelNode()
        okButton = SKLabelNode()
        okBoarder = SKShapeNode()
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = backColor
        
        load()
        tiles()
        shuffleBoard()
        
        timeLabel.text = "Time: \(time)"
        timeLabel.fontName = "Bold"
        timeLabel.fontSize = 20
        timeLabel.fontColor = SKColor.white
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: tile[0].position.x + 5,
                                     y: tile[0].position.y + pos)
        timeLabel.name = "time"
        
        addChild(timeLabel)
        
        movesLabel.text = "Moves: \(moves)"
        movesLabel.fontName = "Bold"
        movesLabel.fontSize = 20
        movesLabel.fontColor = SKColor.white
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.position = CGPoint(x: size.width/2,
                                      y: tile[0].position.y + pos)
        movesLabel.name = "moves"
        
        addChild(movesLabel)
        
    }
    
    func popOverDialogue() {
        
        popOver = SKShapeNode(rect: CGRect(x: Int(self.size.width/2 - 125),
                                           y: Int(self.size.height/2 - 125), width: 250, height: 250))
        popOver.fillColor = .black
        popOver.strokeColor = .white
        popOver.lineWidth = 10
        popOver.zPosition = 3
        
        addChild(popOver)
        
        winLabel.text = "SOLVED!"
        winLabel.fontName = "Bold"
        winLabel.fontSize = 20
        winLabel.fontColor = SKColor.white
        winLabel.horizontalAlignmentMode = .center
        winLabel.position = CGPoint(x: Int(self.size.width/2), 
                                    y: Int(self.size.height/2 + 50))
        winLabel.zPosition = 4
        winLabel.name = "solved"
        
        popOver.addChild(winLabel)
        
        okButton.text = "OK"
        okButton.fontName = "Bold"
        okButton.fontSize = 20
        okButton.fontColor = SKColor.white
        okButton.horizontalAlignmentMode = .center
        okButton.position = CGPoint(x: Int(self.size.width/2),
                                    y: Int(self.size.height/2 - 60))
        okButton.zPosition = 4
        okButton.name = "ok"
        
        popOver.addChild(okButton)
        
        okBoarder = SKShapeNode(rect: CGRect(x: Int(self.size.width/2 - 30),
                                             y: Int(self.size.height/2 - 77), width: 60, height: 50),
                                cornerRadius: 25)
        okBoarder.fillColor = .clear
        okBoarder.strokeColor = .white
        okBoarder.lineWidth = 2.5
        okBoarder.zPosition = 5
        okBoarder.name = "okboarder"
        
        popOver.addChild(okBoarder)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            for i in 0..<54 {
                if touchedNode == overlay[i] && !isSolved() {
                    move(i: i)
                }
            }
            
            if isSolved() && winLabel.name != "solved" {
                playSoundTada()
                popOverDialogue()
                print("Solved")
            }
            
            if touchedNode.name == "okboarder" {
                okButton.fontColor = SKColor.gray
                okBoarder.strokeColor = SKColor.gray
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            if touchedNode.name == "okboarder" {
                okButton.fontColor = SKColor.white
                okBoarder.strokeColor = SKColor.white
                
                 changeScene()
            }
        }
    }
    
    // Grid
    func tiles() {
        
        var rect = CGRect()
        
        rect.size.width = pos*6
        rect.size.height = pos*9
        rect.origin.x = size.width/2 - rect.width/2 + 2
        rect.origin.y = size.height/2 - rect.height/2 - pos
        
        
        var x = rect.minX
        var y = rect.maxY
        
        for i in 0..<54 {
            
            tile.append(SKShapeNode(rect: CGRect(x: 0, y: 0, width: w, height: h)))
            overlay.append(SKShapeNode(rect: CGRect(x: 0, y: 0, width: w, height: h)))
            
            tilePosition.append(CGPoint(x: x, y: y))
            
            tile[i].position.x = x
            tile[i].position.y = y
            tile[i].fillColor = color[i]
            tile[i].strokeColor = .clear
            tile[i].zPosition = 1
            tile[i].name = String(i)
            
            overlay[i].position.x = x
            overlay[i].position.y = y
            overlay[i].fillColor = .clear
            overlay[i].strokeColor = .clear
            overlay[i].zPosition = 2
            overlay[i].name = String(i)
            
            x += pos
            
            addChild(tile[i])
            addChild(overlay[i])
            
            if i == 5  { x = rect.minX; y = rect.maxY - pos*1 }
            if i == 11 { x = rect.minX; y = rect.maxY - pos*2 }
            if i == 17 { x = rect.minX; y = rect.maxY - pos*3 }
            if i == 23 { x = rect.minX; y = rect.maxY - pos*4 }
            if i == 29 { x = rect.minX; y = rect.maxY - pos*5 }
            if i == 35 { x = rect.minX; y = rect.maxY - pos*6 }
            if i == 41 { x = rect.minX; y = rect.maxY - pos*7 }
            if i == 47 { x = rect.minX; y = rect.maxY - pos*8 }
        }
    }
    
    func save() {
        NSUbiquitousKeyValueStore().set(moves, forKey: "movesCurrent")
        NSUbiquitousKeyValueStore().set(time, forKey: "timeCurrent")
        movesBest = Int(NSUbiquitousKeyValueStore().double(forKey: "movesBest"))
        if movesBest == 0 {
            movesBest = moves
        }
        if moves <= movesBest {
            NSUbiquitousKeyValueStore().set(moves, forKey: "movesBest")
        }
        elapsedBest = Int(NSUbiquitousKeyValueStore().double(forKey: "elapsedBest"))
        if elapsedBest == 0 {
            elapsedBest = elapsed
        }
        if elapsed <= elapsedBest {
            NSUbiquitousKeyValueStore().set(elapsed, forKey: "elapsedBest")
        }
    }
    
    func load() {
        movesCurrent = Int(NSUbiquitousKeyValueStore().double(forKey: "movesCurrent"))
        timeCurrent = NSUbiquitousKeyValueStore().string(forKey: "timeCurrent") ?? ""
        movesBest = Int(NSUbiquitousKeyValueStore().double(forKey: "movesBest"))
        elapsedBest = Int(NSUbiquitousKeyValueStore().double(forKey: "elapsedBest"))
        timeBest = createTimeString(seconds: elapsedBest)
    }
    
    func shuffleBoard() {
        color.shuffle()
        for i in 0..<54 {
            tile[i].fillColor = color[i]
        }
        moves = 0
        elapsedTime()
    }
    
    func elapsedTime() {
        elapsed = 0
        time = "00:00:00"
        timer.invalidate()
        if !timer.isValid {
            timer.fire()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                elapsed += 1
                time = createTimeString(seconds: elapsed)
                timeLabel.text = "Time: \(time)"
            }
        } else {
            timer.invalidate()
        }
    }
    
    func createTimeString(seconds: Int) -> String {
        let h: Int = seconds/3600
        let m: Int = (seconds/60) % 60
        let s: Int = seconds % 60
        let a = String(format: "%02u:%02u:%02u", h, m, s)
        return a
    }
    
    func playSound() {
        do {
            let url =  Bundle.main.url(forResource: "move", withExtension: "mp3")
            soundPlayer = try AVAudioPlayer(contentsOf: url!)
            soundPlayer.volume = 0.2
            soundPlayer.prepareToPlay()
            soundPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSoundTada() {
        do {
            let url =  Bundle.main.url(forResource: "tada", withExtension: "mp3")
            soundPlayer = try AVAudioPlayer(contentsOf: url!)
            soundPlayer.volume = 1.0
            soundPlayer.prepareToPlay()
            soundPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func changeScene() {
        
        load()
        
        let sceneToMoveTo = EndScene(size: self.size)
        let myTransition = SKTransition.fade(withDuration: 0.5)
        
        sceneToMoveTo.scaleMode = self.scaleMode
        
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func animateSwap(fromIndex: Int, toIndex: Int) {
        // 1. Get references to the nodes being swapped
        let fromTile = tile[fromIndex]
        let toTile = tile[toIndex]
        
        // 2. Positions for animation
        let fromPosition = tilePosition[fromIndex]
        let toPosition = tilePosition[toIndex]
        
        // 3. Create SKActions for the animations
        let moveFromAction = SKAction.move(to: toPosition, duration: 0.3)
        let moveToAction = SKAction.move(to: fromPosition, duration: 0.3)
        
        // 4. Run the animation on both tiles
        fromTile.run(moveFromAction)
        toTile.run(moveToAction)
        
        // 5. Swap the tiles in the 'tile' array
        tile.swapAt(fromIndex, toIndex)
        
        // 6. Swap the colors in the 'color' array
        color.swapAt(fromIndex, toIndex)
        
        moves += 1
        movesLabel.text = "Moves: \(moves)"
        playSound()
    }
    
    // Swap two pieces
    func move(i: Int) {
        let empty: Int = findEmpty()
        let emptyCol: Int = empty % cols
        let emptyRow: Int = empty / cols
        
        // Double check valid move
        if isNeighbor(i: i, x: emptyCol, y: emptyRow) {
            animateSwap(fromIndex: i, toIndex: empty)
        }
    }
    // Check if neighbor
    func isNeighbor(i: Int, x: Int, y: Int) -> Bool {
        if (i % cols) != x && (i / cols) != y {
            return false
        }
        if abs((i % cols) - x) == 1 || abs((i / cols)  - y) == 1 {
            return true
        }
        return false
    }
    
    func findEmpty() -> Int {
        var n: Int = 0
        for i in 0..<color.count {
            if color[i] == .clear {
                n = i
            }
        }
        return n
    }
    
    func isSolved() -> Bool {
        var isSolved = false
        if match(tileNumber: [  0,  1,  2,  6,  7,  8, 12, 13, 14 ]).count == 1 &&
            match(tileNumber: [  3,  4,  5,  9, 10, 11, 15, 16, 17 ]).count == 1 &&
            match(tileNumber: [ 18, 19, 20, 24, 25, 26, 30, 31, 32 ]).count == 1 &&
            match(tileNumber: [ 21, 22, 23, 27, 28, 29, 33, 34, 35 ]).count == 1 &&
            match(tileNumber: [ 36, 37, 38, 42, 43, 44, 48, 49, 50 ]).count == 1 &&
            match(tileNumber: [ 39, 40, 41, 45, 46, 47, 51, 52, 53 ]).count == 1 {
            save()
            timer.invalidate()
            isSolved = true
        }
        return isSolved
    }
    
    func match(tileNumber: [Int]) -> [SKColor] {
        var matchColor: [SKColor]
        matchColor = compare(tileNumber: tileNumber)
        matchColor = matchColor.uniqued()
        matchColor = matchColor.filter { $0 != .clear }
        return matchColor
    }
    
    func compare(tileNumber: [Int]) -> [SKColor] {
        let colorList: [SKColor] = [ .white, .blue, .red, .green, .orange, .yellow, .clear ]
        var matchColor: [SKColor] = []
        for number in tileNumber {
            for colorLists in colorList {
                if color[number] == colorLists { matchColor.append(colorLists) }
            }
        }
        return matchColor
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

struct GameSceneView: View {

    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: gameWidth, height: gameHeight)))
            .ignoresSafeArea()
    }
}

#Preview {
    GameSceneView()
}
