//
//  GameKitHelper.swift
//  Unscramble
//
//  Created by Alex Resnik on 12/2/23.
//

import Foundation
import GameKit

let singleton = GameKitHelper()

protocol GameKitHelperDelegate: AnyObject {
    func didChangeAuthStatus(isAuthenticated: Bool)
    func presentGameCenterAuth(viewController: UIViewController?)
}

final class GameKitHelper: NSObject, GKGameCenterControllerDelegate, GKLocalPlayerListener {
    
    weak var delegate: GameKitHelperDelegate?
    
    private var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    private var authenticationViewController: UIViewController?
    private var lastError: Error?
    private var gameCenterEnabled: Bool
    
    override init() {
        gameCenterEnabled = true
        super.init()
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { (gcAuthVC, error) in
            self.delegate?.didChangeAuthStatus(isAuthenticated: self.isAuthenticated)
            
            guard GKLocalPlayer.local.isAuthenticated else {
                self.delegate?.presentGameCenterAuth(viewController: gcAuthVC)
                return
            }
            GKLocalPlayer.local.register(self)
        }
    }
    
    func showLeaderboard(view: UIViewController) {
        
        if GKLocalPlayer.local.isAuthenticated {
            
            let localPlayer = GKLocalPlayer.local
            
            if localPlayer.isAuthenticated {
                
                let vc = view
                let gc = GKGameCenterViewController()
                gc.gameCenterDelegate = self
                vc.present(gc, animated: true, completion: nil)
            }
        }
    }
    
    class var sharedInstance: GameKitHelper { return singleton }
}
