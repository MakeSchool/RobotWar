//
//  AdvancedRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 MakeGamesWithUs. All rights reserved.
//

import Foundation

class AdvancedRobot: Robot {
  
  enum RobotState {                    // enum for keeping track of RobotState
    case Default, Turnaround, Firing, Searching
  }
  
  var currentRobotState: RobotState = .Default {
    didSet {
      actionIndex = 0
    }
  }
  var actionIndex = 0                 // index in sub-state machines, could use enums
                                      // but will make harder to quickly add new states
  
  var lastKnownPosition = CGPoint(x: 0, y: 0)
  var lastKnownPositionTimestamp = CGFloat(0.0)
  
  override func run() {
    while true {
      switch currentRobotState {
      case .Default:
        performNextDefaultAction()
      case .Searching:
        performNextSearchingAction()
      case .Firing:
        performNextFiringAction()
      case .Turnaround:               // ignore Turnaround since handled in hitWall
        break
      }
    }
  }
  
  func performNextDefaultAction() {
    // uses actionIndex with switch in case you want to expand and add in more actions
    // to your initial state -- first thing robot does before scanning another robot
    switch actionIndex % 1 {          // should be % of number of possible actions
    case 0:
      moveAhead(100)
    default:
      break
    }
    actionIndex++
  }
  
  func performNextSearchingAction() {
    switch actionIndex % 4 {          // should be % of number of possible actions
    case 0:
      moveAhead(50)
    case 1:
      turnRobotLeft(20)
    case 2:
      moveAhead(50)
    case 3:
      turnRobotRight(20)
    default:
      break
    }
    actionIndex++
  }
  
  func performNextFiringAction() {
    if currentTimestamp() - lastKnownPositionTimestamp > CGFloat(1) {
      currentRobotState = .Searching
    } else {
      let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(lastKnownPosition))
      if angle >= 0 {
        turnGunRight(abs(angle))
      } else {
        turnRobotLeft(abs(angle))
      }
      shoot()
    }
  }
  
  override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
    if currentRobotState != .Firing {
      cancelActiveAction()
    }
    
    lastKnownPosition = position
    lastKnownPositionTimestamp = currentTimestamp()
    currentRobotState = .Firing
  }
  
  override func gotHit() {
    // unimplemented
  }
  
  override func hitWall(hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
    cancelActiveAction()
    
    // save old state
    let previousState = currentRobotState
    currentRobotState = .Turnaround
    
    // always turn directly away from wall
    if angle >= 0 {
      turnRobotLeft(Int(abs(angle)))
    } else {
      turnRobotRight(Int(abs(angle)))
    }
    
    // leave wall
    moveAhead(20)
    
    // reset to old state
    currentRobotState = previousState
  }
  
  override func bulletHitEnemy(bullet: Bullet!) {
    // unimplemented but could be powerful to use this...
  }
  
}