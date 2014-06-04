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
    CCLOG(@"Move Ahead - START");
    [self moveAhead:100];
    CCLOG(@"Move Ahead - END");
  }
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
 [self cancelActiveAction];
  CCLOG(@"Scanned Robot!");
}

- (void)hitWall:(RobotWallHitDirection)hitDirection {
  if (_currentRobotAction != RobotActionTurnaround) {
    [self cancelActiveAction];
    CCLOG(@"Turn around - START");

    _currentRobotAction = RobotActionTurnaround;
    [self turnRobotRight:180];
    CCLOG(@"Turn around - END");
  }
}

@end
