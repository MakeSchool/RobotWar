//
//  SimpleRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SimpleRobot.h"

typedef NS_ENUM(NSInteger, RobotAction) {
  RobotActionDefault,
  RobotActionTurnaround
};

@implementation SimpleRobot {
  RobotAction _currentRobotAction;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
  [self cancelActiveAction];
  
  _currentRobotAction = RobotActionTurnaround;
  
  switch (hitDirection) {
    case RobotWallHitDirectionFront:
      [self turnRobotRight:180];
      [self moveAhead:20];
      break;
    case RobotWallHitDirectionRear:
      [self moveAhead:80];
      break;
    case RobotWallHitDirectionLeft:
      [self turnRobotRight:90];
      [self moveAhead:20];
      break;
    case RobotWallHitDirectionRight:
      [self turnRobotLeft:90];
      [self moveAhead:20];
      break;
    default:
      break;
  }
  
  _currentRobotAction = RobotActionDefault;
  
}

//- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
//  if (_currentRobotAction != RobotActionTurnaround) {
//    [self cancelActiveAction];
//    
//    [self turnRobotLeft:20];
//    [self moveBack:80];
//  }
//}

- (void)run {
  while (true) {
    [self moveAhead:80];
    [self turnRobotRight:20];
    [self moveAhead:100];
    [self shoot];
    [self turnRobotLeft:10];
  }
}

- (void)gotHit {
  [self shoot];
  [self turnRobotLeft:45];
  [self moveAhead:100];
}

@end
