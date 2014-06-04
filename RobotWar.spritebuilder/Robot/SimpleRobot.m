//
//  SimpleRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SimpleRobot.h"

@implementation SimpleRobot

- (void)scannedRobotEvent {
  [self shoot];
  [self turnGunRight:10];
  [self shoot];
  [self turnGunLeft:10];
}

- (void)hitWall {
  [self moveBack:100];
  [self turnRobotRight:45];
}

- (void)scannedRobot:(Robot *)robot {
  [self turnRobotLeft:20];
  [self moveBack:80];
}

- (void)run {
  while (true) {
    [self moveBack:40];
    [self moveAhead:40];
    [self turnRobotLeft:90];
  }
}

@end
