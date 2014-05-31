//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "RobotAction.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 60;
static CGFloat const ROBOT_DISTANCE_PER_SECOND = 50;

@interface Robot ()

@end

@implementation Robot {
  CCNode *_barell;
  CCNode *_body;
  
  dispatch_queue_t _backgroundQueue;
  dispatch_queue_t _mainQueue;
  dispatch_queue_t _actionInvocationQueue;

  
  dispatch_group_t mainQueueGroup;

  RobotAction *_currentRobotAction;
}

- (void)dealloc {
  dispatch_release(mainQueueGroup);
}

- (instancetype)init {
  self = [super init];
  
  if (self) {
    _backgroundQueue = dispatch_queue_create("backgroundQueue", DISPATCH_QUEUE_SERIAL);
    _mainQueue = dispatch_queue_create("mainQueue", DISPATCH_QUEUE_SERIAL);
    _actionInvocationQueue = dispatch_queue_create("actionInvocationQueue", DISPATCH_QUEUE_SERIAL);
    mainQueueGroup = dispatch_group_create();
  }
  
  return self;
}

- (void)runRobotAction:(CCActionFiniteTime *)action target:(CCNode*)target {
  
  if (dispatch_get_current_queue() == _backgroundQueue) {
    if (mainQueueGroup != NULL) {
      dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
    }
  }
  
  RobotAction *robotAction = [[RobotAction alloc] init];
  robotAction.target = target;
  robotAction.action = action;
  _currentRobotAction = robotAction;
  
  [robotAction run];
  
  _currentRobotAction = nil;
}

- (void)turnGunLeft:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)moveAhead:(NSInteger)distance {
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND;
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:ccp(0, distance)];
  
  [self runRobotAction:actionMoveBy target:_body];
}

- (void)moveBack:(NSInteger)distance {
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND;
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:ccp(0, -distance)];
  
  [self runRobotAction:actionMoveBy target:_body];
}

- (void)run {
  dispatch_async(_backgroundQueue, ^{
    while (true) {
      [self turnGunLeft:10];
      [self moveAhead:100];
      
      if (mainQueueGroup != NULL) {
        dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
      }
    }
  });
}

- (void)scannedRobot {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
      dispatch_sync(_actionInvocationQueue, ^{
        [_currentRobotAction cancel];
      });
    }
    
    [self scannedRobotEvent];
  });
}

- (void)hitWall {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
      dispatch_sync(_actionInvocationQueue, ^{
        [_currentRobotAction cancel];
      });
    }
    
    [self hitWallEvent];
  });
}

- (void)scannedRobotEvent {
  [self turnGunRight:90];
  [self turnGunLeft:10];
  [self turnGunRight:10];
}

- (void)hitWallEvent {
  [self moveBack:100];
}

@end
