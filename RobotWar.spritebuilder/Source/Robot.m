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
  CCNode *_body;
}

- (void)performRobotAction:(CCActionFiniteTime *)action target:(CCNode *)target  {
  // each robot can only perform operations on his own queue!
  NSAssert(dispatch_get_current_queue() == self.basicMovementQueue || dispatch_get_current_queue() == self.eventResponseQueue, @"You're trying to cheat? Your robot is only allowed to use his own queue!");

  dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  
  CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(sema);
  }];

  CCActionSequence *sequence = [CCActionSequence actionOne:action two:actionCallBlock];

  dispatch_async(dispatch_get_main_queue(), ^{
    [target runAction:sequence];
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  dispatch_release(sema);

  return;
}

- (void)turnGunLeft:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;

  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  [self performRobotAction:rotateTo target:_barell];
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;

  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  [self performRobotAction:rotateTo target:_barell];
}

- (void)moveAhead:(NSInteger)distance {
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:1.f position:ccp(10.f, 10.f)];
  [self performRobotAction:moveBy target:_body];
}

#pragma mark - Override setters

- (void)setBasicMovementQueue:(dispatch_queue_t)basicMovementQueue {
  NSAssert(_basicMovementQueue == NULL, @"Operation queue can only be set once and never alternated!");
  
  _basicMovementQueue = basicMovementQueue;
}

- (void)setEventResponseQueue:(dispatch_queue_t)eventResponseQueue {
  NSAssert(_eventResponseQueue == NULL, @"Operation queue can only be set once and never alternated!");
  
  _eventResponseQueue = eventResponseQueue;
}

@end
