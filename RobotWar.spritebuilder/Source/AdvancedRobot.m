//
//  AdvancedRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AdvancedRobot.h"

typedef NS_ENUM(NSInteger, RobotAction) {
  RobotActionTurnaround,
  RobotActionDefault
};

@implementation AdvancedRobot {
  RobotAction _currentRobotAction;
}

- (void)run {
  while (true) {
    _currentRobotAction = RobotActionDefault;
    [self moveAhead:100];
  }
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
  CCLOG(@"Scanned Robot!");
}

- (void)hitWall {
  if (_currentRobotAction != RobotActionTurnaround) {
    [self cancelActiveAction];

    _currentRobotAction = RobotActionTurnaround;
    [self moveBack:100];
    [self turnRobotRight:180];
  }
}

@end
