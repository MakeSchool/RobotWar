//
//  BasicRobot.m
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BasicRobot.h"

@interface BasicRobot()

@property (atomic, assign) BOOL basicMovementDeactivated;

@end

@implementation BasicRobot

- (void)run {
  while (true) {
    if (!self.basicMovementDeactivated) {
      [self turnGunLeft:180];
      [self turnGunRight:20];
    } else {
      [self turnGunRight:10];
      [self moveAhead:10];
    }
  }
}

- (void)scannedRobot {
  NSLog(@"Event received!");

  dispatch_async(self.eventResponseQueue, ^{
    [self turnGunRight:15];
    [self turnGunLeft:15];
  });
  
  self.basicMovementDeactivated = !self.basicMovementDeactivated;
}

@end
