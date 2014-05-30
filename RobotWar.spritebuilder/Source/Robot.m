//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 60;

@implementation Robot {
    CCNode *_barell;
}

- (void)performRobotAction:(CCActionFiniteTime*)action {
  // each robot can only perform operations on his own queue!
  NSAssert(dispatch_get_current_queue() == self.operationQueue, @"You're trying to cheat? Your robot is only allowed to use his own queue!");
  
  __block BOOL complete = FALSE;

  
  CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
    complete = TRUE;
  }];
  
  CCActionSequence *sequence = [CCActionSequence actionOne:action two:actionCallBlock];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_barell runAction:sequence];
  });
  
  while (!complete);
  
  return;
}

- (void)turnGunLeft:(NSInteger)degree {
  
    CGFloat currentRotation = _barell.rotation;
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
    
    CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
    [self performRobotAction:rotateTo];
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  [self performRobotAction:rotateTo];
}

- (void)performAction {
  [self turnGunLeft:180];
  [self turnGunRight:20];
  NSLog(@"Turn completed");
}

@end
