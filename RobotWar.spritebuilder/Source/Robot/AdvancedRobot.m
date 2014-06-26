//
//  AdvancedRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AdvancedRobot.h"

typedef NS_ENUM(NSInteger, RobotState) {
  RobotStateDefault,
  RobotStateTurnaround,
  RobotStateFiring,
  RobotStateSearching
};

@implementation AdvancedRobot {
  RobotState _currentRobotState;
  
  CGPoint _lastKnownPosition;
  CGFloat _lastKnownPositionTimestamp;
}

- (void)run {
  while (true) {
    if (_currentRobotState == RobotStateFiring) {
      
      if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
        _currentRobotState = RobotStateSearching;
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
    
    if (_currentRobotState == RobotStateSearching) {
      [self moveAhead:50];
      [self turnRobotLeft:20];
      [self moveAhead:50];
      [self turnRobotRight:20];
    }
    
    if (_currentRobotState == RobotStateDefault) {
      [self moveAhead:100];
    }
  }
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
  _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
  if (_currentRobotState != RobotStateTurnaround) {
    [self cancelActiveAction];
    
    RobotState previousState = _currentRobotState;
    _currentRobotState = RobotStateTurnaround;
    
    // always turn to head straight away from the wall
    if (angle >= 0) {
      [self turnRobotLeft:abs(angle)];
    } else {
      [self turnRobotRight:abs(angle)];

    }
    
    [self moveAhead:20];
    
    _currentRobotState = previousState;
  }
}

@end
