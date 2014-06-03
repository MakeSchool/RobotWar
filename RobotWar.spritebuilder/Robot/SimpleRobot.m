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
  [self turnGunRight:90];
  [self turnGunLeft:10];
  [self turnGunRight:10];
}

- (void)hitWall {
//  [self moveBack:100];
}

- (void)gotHit:(Bullet *)bullet {
  
}

- (void)run {
  while (true) {
    [self turnGunLeft:25];
    [self shoot];
    [self moveAhead:70];
  }
}

@end
