//
//  TurretRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 MakeGamesWithUs. All rights reserved.
//

import Foundation

class TurretRobot: Robot {
  
  enum RobotState {                    // enum for keeping track of RobotState
    case Scanning, Firing
  }
  
  var currentRobotState: RobotState = .Scanning
  var lastEnemyHit = CGFloat(0.0)
  let gunToleranceAngle = CGFloat(2.0)
  
  override func run() {
    while true {
      switch currentRobotState {
      case .Scanning:
        turnGunRight(90)
      case .Firing:
        if currentTimestamp() - lastEnemyHit > 2.5 {
          cancelActiveAction()
          currentRobotState = .Scanning
        } else {
          shoot()
        }
      }
    }
  }
  
  override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
    // calculate angle between turret and enemey
    var angleBetweenTurretAndEnemy = angleBetweenGunHeadingDirectionAndWorldPosition(position)
    
    // turn if necessary
    if angleBetweenTurretAndEnemy > gunToleranceAngle {
      cancelActiveAction()
      turnGunRight(Int(abs(angleBetweenTurretAndEnemy)))
    } else if angleBetweenTurretAndEnemy < -gunToleranceAngle {
      cancelActiveAction()
      turnGunLeft(Int(abs(angleBetweenTurretAndEnemy)))
    }
    
    lastEnemyHit = currentTimestamp()
    currentRobotState = .Firing
  }
  
  override func gotHit() {
    // unimplemented
  }
  
  override func hitWall(hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
    // unimplemented
  }
  
  override func bulletHitEnemy(bullet: Bullet!) {
    lastEnemyHit = currentTimestamp()
  }
  
}