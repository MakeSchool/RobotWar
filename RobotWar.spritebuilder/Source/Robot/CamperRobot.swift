//
//  LiveRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 MakeGamesWithUs. All rights reserved.
//

import Foundation

class CamperRobot: Robot {
  
  enum RobotState {                    // enum for keeping track of RobotState
    case FirstMove, Camping, Firing
  }
  
  var currentRobotState: RobotState = .FirstMove
  
  var lastKnownPosition = CGPoint(x: 0, y: 0)
  var lastKnownPositionTimestamp = CGFloat(0.0)
  
  override func run() {
    while true {
      switch currentRobotState {
      case .FirstMove:
        performFirstMoveAction()
      case .Firing:
        performNextFiringAction()
      case .Camping:
        shoot()
      }
    }
  }
  
  func performFirstMoveAction() {
    let arenaSize = arenaDimensions()
    let bodyLength = robotBoundingBox().size.width
    
    // find and turn towards closest corner
    var currentPosition = position()
    if currentPosition.y < arenaSize.height / 2 {
      if currentPosition.x < arenaSize.width/2 {
        // bottom left
        turnRobotLeft(90)
      } else {
        // bottom right
        turnRobotRight(90)
      }
    } else {
      if currentPosition.x < arenaSize.width/2 {
        // top left
        turnRobotRight(90)
      } else {
        // top right
        turnRobotLeft(90)
      }
    }
    
    // back into closest corner
    currentPosition = position()
    if currentPosition.y < arenaSize.height/2 {
      moveBack(Int(currentPosition.y - bodyLength))
    } else {
      moveBack(Int(arenaSize.height - (currentPosition.y + bodyLength)))
    }
    
    // turn gun towards center, shoot, camp out
    turnToCenter()
    shoot()
    currentRobotState = .Camping
  }
  
  func performNextFiringAction() {
    if currentTimestamp() - lastKnownPositionTimestamp > 1 {
      turnToCenter()
      currentRobotState = .Camping
    } else {
      var angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(lastKnownPosition))
      if angle > 0 {
        turnGunRight(angle)
      } else {
        turnGunLeft(abs(angle))
      }
    }
    shoot()
  }
  
  func turnToCenter() {
    let arenaSize = arenaDimensions()
    var angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
    if angle < 0 {
      turnGunLeft(abs(angle))
    } else {
      turnGunRight(angle)
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
  
  override func hitWall(hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
    // unimplemented
  }
  
  override func bulletHitEnemy(bullet: Bullet!) {
    shoot()
  }
  
}