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
import GameKit
import StoreKit

var movesCurrent: Int = 0
var timeCurrent: String = ""
var movesBest: Int = 0
var timeBest: String = ""

class GameScene: SKScene, GKGameCenterControllerDelegate,
                 SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private var sound: Bool = true
    
    private var leaderboardID: String = "elapsed_unscrambled"
    private var productID: String = "coffee_unscrambled"
    private var product: SKProduct?
    
    private var defaults: UserDefaults = UserDefaults.standard
    
    private let settingsButton: SKSpriteNode = SKSpriteNode(imageNamed: "gear")
    private var timeLabel: SKLabelNode = SKLabelNode()
    private var movesLabel: SKLabelNode = SKLabelNode()
    private var winLabel: SKLabelNode = SKLabelNode()
    private var okButton: SKLabelNode = SKLabelNode()
    private var okBoarder: SKShapeNode = SKShapeNode()
    
    private let backButton: SKSpriteNode = SKSpriteNode(imageNamed: "back")
    private var settingsLabel: SKLabelNode = SKLabelNode()
    private var soundButton: SKLabelNode = SKLabelNode()
    private var soundBoarder: SKShapeNode = SKShapeNode()
    private var reviewButton: SKLabelNode = SKLabelNode()
    private var reviewBoarder: SKShapeNode = SKShapeNode()
    private var websiteButton: SKLabelNode = SKLabelNode()
    private var websiteBoarder: SKShapeNode = SKShapeNode()
    private var resetButton: SKLabelNode = SKLabelNode()
    private var resetBoarder: SKShapeNode = SKShapeNode()
    private var tipTheDevButton: SKLabelNode  = SKLabelNode()
    private var tipTheDevBoarder: SKShapeNode = SKShapeNode()

    private let clr: [SKColor] = [ .white, .blue, .red, .green, .orange, .yellow, .clear ]
    private var color: [SKColor] = [SKColor]()
    
    private var tile: [SKShapeNode] = [SKShapeNode]()
    private var tilePosition: [CGPoint] = [CGPoint]()
    private var overlay: [SKShapeNode] = [SKShapeNode]()
    private var popOver: SKShapeNode = SKShapeNode()
    
    private var backColor: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    
    private let cols: Int = 6
    private let rows: Int = 9
    private let numberOfTiles: Int = 54
    private let w: Int = 55
    private let h: Int = 55
    private let pos: CGFloat = 60
    
    private var soundPlayer: AVAudioPlayer? = AVAudioPlayer()
    
    private var pauseTimer: Bool = false
    private var time: String = "00:00:00"
    private var moves: Int = 0
    private var timer: Timer = Timer()
    private var elapsed: Int = 0
    private var elapsedBest: Int = 0
    private var onceStartTimer: Bool = false
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = backColor
        
        color =  [ clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[0], clr[0], clr[0], clr[1], clr[1], clr[1],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[2], clr[2], clr[2], clr[3], clr[3], clr[3],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[5],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[5],
                   clr[4], clr[4], clr[4], clr[5], clr[5], clr[6] ]
        
        load()
        tiles()
        fetchProducts()
        
        if GKLocalPlayer.local.isAuthenticated {
            GKAccessPoint.shared.isActive = false
        } else {
            print("Game Center not authenticated")
        }
        
        settingsButton.size.width = 30
        settingsButton.size.height = 30
        settingsButton.position.x = size.width - longButton
        settingsButton.position.y = size.height - longButton
        settingsButton.name = "settingsbutton"
        
        addChild(settingsButton)
        
        timeLabel.text = "Time: \(time)"
        timeLabel.fontName = "Bold"
        timeLabel.fontSize = 20
        timeLabel.fontColor = .white
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: tile[0].position.x + 5,
                                     y: tile[0].position.y + pos)
        timeLabel.name = "time"
        
        addChild(timeLabel)
        
        movesLabel.text = "Moves: \(moves)"
        movesLabel.fontName = "Bold"
        movesLabel.fontSize = 20
        movesLabel.fontColor = .white
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.position = CGPoint(x: size.width/2,
                                      y: tile[0].position.y + pos)
        movesLabel.name = "moves"
        
        addChild(movesLabel)
        
        shuffleBoard()
    }
    
    func popOverSettings() {
        
        popOver = SKShapeNode(rect: CGRect(x: 0,
                                           y: 0,
                                           width: size.width,
                                           height: size.height))
        popOver.fillColor = .black
        popOver.lineWidth = 0
        popOver.zPosition = 3
        
        addChild(popOver)
        
        backButton.size.width = 30
        backButton.size.height = 30
        backButton.position.x = longButton
        backButton.position.y = size.height - longButton
        backButton.name = "backbutton"

        popOver.addChild(backButton)
        
        settingsLabel.text = "Settings"
        settingsLabel.fontName = "Bold"
        settingsLabel.fontSize = 50
        settingsLabel.fontColor = .white
        settingsLabel.horizontalAlignmentMode = .center
        settingsLabel.position = CGPoint(x: size.width/2,
                                            y: size.height - long)
        settingsLabel.name = "settingslabel"
        
        popOver.addChild(settingsLabel)
        
        if sound == true {
            soundButton.text = "Sound: On"
        } else {
            soundButton.text = "Sound: Off"
        }
        soundButton.fontName = "Bold"
        soundButton.fontSize = 25
        soundButton.fontColor = .white
        soundButton.horizontalAlignmentMode = .center
        soundButton.position = CGPoint(x: size.width/2 ,
                                     y: size.height*0.75 )
        soundButton.name = "soundbutton"
        
        popOver.addChild(soundButton)
        
        soundBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 80),
                                              y: Int(size.height*0.75 - 20),
                                                    width: 160,
                                                    height: 60),
                                                    cornerRadius: 30)
        soundBoarder.fillColor = .clear
        soundBoarder.strokeColor = .white
        soundBoarder.lineWidth = 2.5
        soundBoarder.name = "soundboarder"
        
        popOver.addChild(soundBoarder)
        
        reviewButton.text = "Review App"
        reviewButton.fontName = "Bold"
        reviewButton.fontSize = 25
        reviewButton.fontColor = .white
        reviewButton.horizontalAlignmentMode = .center
        reviewButton.position = CGPoint(x: size.width/2,
                                     y: size.height*0.60 )
        reviewButton.name = "reviewbutton"

        popOver.addChild(reviewButton)
        
        reviewBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 85),
                                              y: Int(size.height*0.60 - 20),
                                                    width: 170,
                                                    height: 60),
                                                    cornerRadius: 30)
        reviewBoarder.fillColor = .clear
        reviewBoarder.strokeColor = .white
        reviewBoarder.lineWidth = 2.5
        reviewBoarder.name = "reviewboarder"

        popOver.addChild(reviewBoarder)
        
        websiteButton.text = "Website"
        websiteButton.fontName = "Bold"
        websiteButton.fontSize = 25
        websiteButton.fontColor = .white
        websiteButton.horizontalAlignmentMode = .center
        websiteButton.position = CGPoint(x: size.width/2 ,
                                     y: size.height*0.45 )
        websiteButton.name = "websitebutton"

        popOver.addChild(websiteButton)

        websiteBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 60),
                                              y: Int(size.height*0.45 - 20),
                                                    width: 125,
                                                    height: 60),
                                                    cornerRadius: 30)
        websiteBoarder.fillColor = .clear
        websiteBoarder.strokeColor = .white
        websiteBoarder.lineWidth = 2.5
        websiteBoarder.name = "websiteboarder"

        popOver.addChild(websiteBoarder)
        
        resetButton.text = "Reset Progress"
        resetButton.fontName = "Bold"
        resetButton.fontSize = 25
        resetButton.fontColor = .white
        resetButton.horizontalAlignmentMode = .center
        resetButton.position = CGPoint(x: size.width/2,
                                     y: size.height*0.30 )
        resetButton .name = "resetbutton"

        popOver.addChild(resetButton )

        resetBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 105),
                                              y: Int(size.height*0.30 - 20),
                                                    width: 208,
                                                    height: 60),
                                                    cornerRadius: 30)
        resetBoarder.fillColor = .clear
        resetBoarder.strokeColor = .white
        resetBoarder.lineWidth = 2.5
        resetBoarder.name = "resetboarder"

        popOver.addChild(resetBoarder)

        tipTheDevButton.text = "Buy Me A Coffee"
        tipTheDevButton.fontName = "Bold"
        tipTheDevButton.fontSize = 25
        tipTheDevButton.fontColor = .white
        tipTheDevButton.horizontalAlignmentMode = .center
        tipTheDevButton.position = CGPoint(x: size.width/2,
                                       y: size.height*0.15 )
        tipTheDevButton.name = "tipthedevbutton"

        popOver.addChild(tipTheDevButton)

        tipTheDevBoarder = SKShapeNode(rect: CGRect(x: Int(size.width/2 - 110),
                                              y: Int(size.height*0.15 - 20),
                                                    width: 220,
                                                    height: 60),
                                                    cornerRadius: 30)
        tipTheDevBoarder.fillColor = .clear
        tipTheDevBoarder.strokeColor = .white
        tipTheDevBoarder.lineWidth = 2.5
        tipTheDevBoarder.name = "tipthedevboarder"

        popOver.addChild(tipTheDevBoarder)
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
        winLabel.fontColor = .white
        winLabel.horizontalAlignmentMode = .center
        winLabel.position = CGPoint(x: Int(self.size.width/2), 
                                    y: Int(self.size.height/2 + 40))
        winLabel.zPosition = 4
        winLabel.name = "solved"
        
        popOver.addChild(winLabel)
        
        okButton.text = "OK"
        okButton.fontName = "Bold"
        okButton.fontSize = 20
        okButton.fontColor = .white
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
    
    func showResetAlert(withTitle title: String, message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            let allKeys = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.keys
            for key in allKeys {
                NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
            }
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in }
        alertController.addAction(noAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            for i in 0..<numberOfTiles {
                if touchedNode == overlay[i] && !isSolved() {
                    move(i: i)
                    if !onceStartTimer {
                        elapsedTime()
                        onceStartTimer = true
                    }
                    pauseTimer = false
                }
            }
            
            if isSolved() && winLabel.name != "solved" {
                playSoundTada()
                popOverDialogue()
                print("Solved")
            }
            
            if touchedNode.name == "okboarder" {
                okButton.fontColor = .gray
                okBoarder.strokeColor = .gray
            }
            if touchedNode.name == "settingsbutton" && !isSolved() {
                settingsButton.texture = SKTexture(imageNamed: "gear.fill")
            }
            if touchedNode.name == "backbutton" {
                backButton.texture = SKTexture(imageNamed: "back.fill")
            }
            if touchedNode.name == "soundboarder" {
                if sound == true {
                    sound = false
                    soundButton.text = "Sound: Off"
                } else {
                    sound = true
                    soundButton.text = "Sound: On"
                }
                defaults.set(sound, forKey: "sound")
            }
            if touchedNode.name == "reviewboarder" {
                reviewButton.fontColor = .gray
                reviewBoarder.strokeColor = .gray
            }
            if touchedNode.name == "websiteboarder" {
                websiteButton.fontColor = .gray
                websiteBoarder.strokeColor = .gray
            }
            if touchedNode.name == "resetboarder" {
                resetButton.fontColor = .gray
                resetBoarder.strokeColor = .gray
            }
            if touchedNode.name == "tipthedevboarder" {
                tipTheDevButton.fontColor = .gray
                tipTheDevBoarder.strokeColor = .gray
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let pointOfTouch = touch.location(in: self)
            let touchedNode = self.atPoint(pointOfTouch)
            
            if touchedNode.name == "okboarder" {
                okButton.fontColor = .white
                okBoarder.strokeColor = .white
                
                 changeSceneEnd()
            }
            if touchedNode.name == "settingsbutton" && !isSolved() {
                settingsButton.texture = SKTexture(imageNamed: "gear")
                pauseTimer = true
                popOverSettings()
            }
            if touchedNode.name == "backbutton" {
                backButton.texture = SKTexture(imageNamed: "back")
                popOver.removeFromParent()
            }
            if touchedNode.name == "reviewboarder" {
                reviewButton.fontColor = .white
                reviewBoarder.strokeColor = .white
                
                if let url = URL(string: "https://apps.apple.com/us/app/unscramble-colors/id1672406998") {
                    UIApplication.shared.open(url)
                }
            }
            if touchedNode.name == "websiteboarder" {
                websiteButton.fontColor = .white
                websiteBoarder.strokeColor = .white
                
                if let url = URL(string: "https://glassoniongames.com") {
                    UIApplication.shared.open(url)
                }
            }
            if touchedNode.name == "resetboarder" {
                resetButton.fontColor = .white
                resetBoarder.strokeColor = .white
                
                showResetAlert(withTitle: "Reset Progress", message: "All data will be erased!")
            }
            if touchedNode.name == "tipthedevboarder" {
                tipTheDevButton.fontColor = .white
                tipTheDevBoarder.strokeColor = .white
                
                guard let theProduct = product else {
                    return
                }
                
                if SKPaymentQueue.canMakePayments() {
                    let payment = SKPayment(product: theProduct)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            }
        }
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let theProduct = response.products.first {
            product = theProduct
            print(product!.productIdentifier)
            print(product!.price)
            print(product!.localizedTitle)
            print(product!.localizedDescription)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
                
            case .purchasing: // no op
                break
            case .purchased, .restored:
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                
                break
            case .failed, .deferred:
                
                print("Transaction has failed")
                
                break
            default: break
                
                
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
        
        for i in 0..<numberOfTiles {
            
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
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(elapsed, context: 0, player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID], completionHandler: {
                error in
                
                if error != nil {
                    print(error!)
                } else {
                    print("Time: \(self.elapsed) submitted")
                }
            })
        }
    }
    
    func load() {
        sound = defaults.bool(forKey: "sound")
        movesCurrent = Int(NSUbiquitousKeyValueStore().double(forKey: "movesCurrent"))
        timeCurrent = NSUbiquitousKeyValueStore().string(forKey: "timeCurrent") ?? ""
        movesBest = Int(NSUbiquitousKeyValueStore().double(forKey: "movesBest"))
        elapsedBest = Int(NSUbiquitousKeyValueStore().double(forKey: "elapsedBest"))
        timeBest = createTimeString(seconds: elapsedBest)
    }
    
    func shuffleBoard() {
        color.shuffle()
        moves = 0
        for i in 0..<numberOfTiles {
            tile[i].fillColor = color[i]
        }
    }
    
    func elapsedTime() {
        elapsed = 0
        time = "00:00:00"
        timer.invalidate()
        if !timer.isValid {
            timer.fire()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                if pauseTimer == false { elapsed += 1 }
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
            soundPlayer?.volume = 0.2
            soundPlayer?.prepareToPlay()
            if sound == true { soundPlayer?.play() }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSoundTada() {
        do {
            let url =  Bundle.main.url(forResource: "tada", withExtension: "mp3")
            soundPlayer = try AVAudioPlayer(contentsOf: url!)
            soundPlayer?.volume = 1.0
            soundPlayer?.prepareToPlay()
            if sound == true { soundPlayer?.play() }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func changeSceneEnd() {
        
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
    }
    
    // Swap two pieces
    func move(i: Int) {
        let empty: Int = findEmpty()
        let emptyCol: Int = empty % cols
        let emptyRow: Int = empty / cols
        
        // Double check valid move
        if isNeighbor(i: i, x: emptyCol, y: emptyRow) {
            animateSwap(fromIndex: i, toIndex: empty)
            moves += 1
            movesLabel.text = "Moves: \(moves)"
            playSound()
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
