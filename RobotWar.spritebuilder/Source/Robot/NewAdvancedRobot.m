//
//  NewAdvancedRobot.m
//  RobotWar
//
//  Created by Dion Larson on 7/6/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "NewAdvancedRobot.h"

@implementation NewAdvancedRobot {
  CGPoint _lastKnownPosition;
  CGFloat _lastKnownPositionTimestamp;
  
  int actionIndex;
}

- (void)run {
  actionIndex = 0;
  while (true) {
    while (_currentRobotState == RobotStateFiring) {
      [self performNextFiringAction];
    }
    
    while (_currentRobotState == RobotStateSearching) {
      [self performNextSearchingAction];
    }
    
    while (_currentRobotState == RobotStateDefault) {
      [self performNextDefaultAction];
    }
  }
}

- (void)performNextDefaultAction {
  switch (actionIndex%1) {
    case 0:
      [self moveAhead:100];
      break;
  }
  actionIndex++;
}

- (void) performNextFiringAction {
  if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
    self.currentRobotState = RobotStateSearching;
  } else {
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
    if (angle >= 0) {
      [self turnGunRight:abs(angle)];
    } else {
      [self turnGunLeft:abs(angle)];
    }
    [self shoot];
  }
}

- (void)performNextSearchingAction {
  switch (actionIndex%4) {
    case 0:
      [self moveAhead:50];
      break;
      
    case 1:
      [self turnRobotLeft:20];
      break;
      
    case 2:
      [self moveAhead:50];
      break;
      
    case 3:
      [self turnRobotRight:20];
      break;
  }
  actionIndex++;
}

- (void)bulletHitEnemy:(Bullet *)bullet {
  // There are a couple of neat things you could do in this handler
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
  if (_currentRobotState != RobotStateFiring) {
    [self cancelActiveAction];
  }
  
  _lastKnownPosition = position;
  _lastKnownPositionTimestamp = self.currentTimestamp;
  self.currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
  if (_currentRobotState != RobotStateTurnaround) {
    [self cancelActiveAction];
    
    RobotState previousState = _currentRobotState;
    self.currentRobotState = RobotStateTurnaround;
    
    // always turn to head straight away from the wall
    if (angle >= 0) {
      [self turnRobotLeft:abs(angle)];
    } else {
      [self turnRobotRight:abs(angle)];
      
    }
    
    [self moveAhead:20];
    
    self.currentRobotState = previousState;
  }
}

- (void)setCurrentRobotState:(RobotState)currentRobotState {
  _currentRobotState = currentRobotState;
  actionIndex = 0;
}

@end
