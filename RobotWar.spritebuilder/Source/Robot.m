//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "RobotOperation.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 60;

@interface Robot ()

@end

@implementation Robot {
  CCNode *_barell;
  CCNode *_body;
  RobotOperation *_moveOperation;
  RobotOperation *_gunRotationOperation;
}

- (void)performRobotAction:(CCActionFiniteTime *)action target:(CCNode *)target actionSlot:(__strong RobotOperation **)actionSlot {
  
    // each robot can only perform operations on his own queue!
    NSAssert(dispatch_get_current_queue() == self.basicMovementQueue || dispatch_get_current_queue() == self.eventResponseQueue, @"You're trying to cheat? Your robot is only allowed to use his own queue!");
    
    if (*actionSlot != nil) {
      [(*actionSlot) cancel];
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    *actionSlot = [[RobotOperation alloc] init];
    (*actionSlot).action = action;
    (*actionSlot).target = target;
    (*actionSlot).semaphore = sema;
    [(*actionSlot) start];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
}

- (void)turnGunLeft:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;

  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  [self performRobotAction:rotateTo target:_barell actionSlot:&_gunRotationOperation];
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;

  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  [self performRobotAction:rotateTo target:_barell actionSlot:&_gunRotationOperation];
}

- (void)moveAhead:(NSInteger)distance {
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:1.f position:ccp(10.f, 10.f)];
  [self performRobotAction:moveBy target:_body actionSlot:&_moveOperation];
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
