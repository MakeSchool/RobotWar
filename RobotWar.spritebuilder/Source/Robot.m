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

- (void)turnGunLeft:(NSInteger)degree {
  
  // each robot can only perform operations on his own queue!
  NSAssert(dispatch_get_current_queue() == self.operationQueue, @"You're trying to cheat? Your robot is only allowed to use his own queue!");
  
    __block BOOL complete = FALSE;
    
    CGFloat currentRotation = _barell.rotation;
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
    
    CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
    CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
        complete = TRUE;
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionOne:rotateTo two:actionCallBlock];
    
    [_barell runAction:sequence];
    
    while (!complete) {
        
    }
    
    return;
}

- (void)turnGunRight:(NSInteger)degree {
  
  
  // each robot can only perform operations on his own queue!
  NSAssert(dispatch_get_current_queue() == self.operationQueue, @"You're trying to cheat? Your robot is only allowed to use his own queue!");
  
  __block BOOL complete = FALSE;
  
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
    complete = TRUE;
  }];
  
  CCActionSequence *sequence = [CCActionSequence actionOne:rotateTo two:actionCallBlock];
  
  [_barell runAction:sequence];
  
  while (!complete) {
    
  }
  
  return;
}

- (void)performAction {
  [self turnGunLeft:180];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSLog(@"Trying to break this!");
    [self turnGunRight:180];
  });
  
  
  NSLog(@"Turn completed");
}

@end
