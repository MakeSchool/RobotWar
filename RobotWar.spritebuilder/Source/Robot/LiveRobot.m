//
//  LiveRobot.m
//  RobotWar
//
//  Created by Dion Larson on 7/7/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "LiveRobot.h"

@implementation LiveRobot {
  int actionIndex;
  
  CGPoint _lastKnownPosition;
  CGFloat _lastKnownPositionTimestamp;
}

- (void)run {
  actionIndex = 0;
  self.currentRobotState = RobotStateFirstMove;
  while (true) {

    while (self.currentRobotState == RobotStateFirstMove) {
      [self performNextFirstMove];
    }
    
    while (_currentRobotState == RobotStateFiring) {
      [self performNextFiringAction];
    }

  }
}

- (void)performNextFirstMove {
  switch (actionIndex%4) {
    case 0: {
      CGPoint currentPosition = [self position];
      CGSize arenaSize = [self arenaDimensions];
      if (currentPosition.y < arenaSize.height/2) {
        if (currentPosition.x < arenaSize.width/2) {
          //bottom left
          [self turnRobotLeft:90];
        } else {
          //bottom right
          [self turnRobotRight:90];
        }
      } else {
        if (currentPosition.x < arenaSize.width/2) {
          //top left
          [self turnRobotRight:90];
        } else {
          //top right
          [self turnRobotLeft:90];
        }
      }
      
      break;
    }
    case 1: {
      CGPoint currentPosition = [self position];
      CGSize arenaSize = [self arenaDimensions];
      float bodyLength = [self robotBoundingBox].size.width; //offset is 2 so we dont trigger hit wall
      if (currentPosition.y < arenaSize.height/2) {
        [self moveBack:(currentPosition.y - bodyLength)];
      } else {
        [self moveBack:(arenaSize.height - (currentPosition.y + bodyLength))];
      }
      break;
    }
    case 2: {
      CGSize arenaSize = [self arenaDimensions];
      float angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:ccp(arenaSize.width/2, arenaSize.height/2)];
      
      if (angle < 0) {
        [self turnGunLeft:fabsf(angle)];
      } else {
        [self turnGunRight:angle];
      }
      break;
    }
    
    case 3: {
      [self shoot];
      
      self.currentRobotState = RobotStateWaiting;
    }
  }
  actionIndex++;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
  if (_currentRobotState != RobotStateFiring) {
    [self cancelActiveAction];
  }
  
  _lastKnownPosition = position;
  _lastKnownPositionTimestamp = self.currentTimestamp;
  self.currentRobotState = RobotStateFiring;
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

- (void)bulletHitEnemy:(Bullet *)bullet {
  [self shoot];
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle {
  NSLog(@"Triggered wall hit");
}

- (void)setCurrentRobotState:(RobotState)currentRobotState {
  _currentRobotState = currentRobotState;
  actionIndex = 0;
}

@end











