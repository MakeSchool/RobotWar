//
//  AdvancedRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AdvancedRobot.h"

typedef NS_ENUM(NSInteger, RobotAction) {
  RobotActionDefault,
  RobotActionTurnaround
};

@implementation AdvancedRobot {
  RobotAction _currentRobotAction;
}

- (void)run {
  while (true) {
    _currentRobotAction = RobotActionDefault;
    [self moveAhead:100];
    [self turnRobotRight:20];
  }
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
 [self cancelActiveAction];
  CCLOG(@"Scanned Robot!");
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
  if (_currentRobotAction != RobotActionTurnaround) {
    [self cancelActiveAction];

    // always turn to head straigh away from the wall
    if (angle >= 0) {
      [self turnRobotLeft:abs(angle)];
    } else {
      // TODO: breaks on negative value?
      [self turnRobotRight:abs(angle)];
    }
  }
}

@end
