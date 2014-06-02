//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "RobotAction.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 100;
static CGFloat const ROBOT_DISTANCE_PER_SECOND = 100;

@interface Robot ()

@end

@implementation Robot {
  CCNode *_barell;
  CCNode *_body;
  
  dispatch_queue_t _backgroundQueue;
  dispatch_queue_t _mainQueue;
  
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
    mainQueueGroup = dispatch_group_create();
  }
  
  return self;
}

- (void)runRobotAction:(CCActionFiniteTime *)action target:(CCNode*)target {
  
  // ensure that background queue cannot spawn any actions will main queue is operating
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

- (void)shoot {
  CGPoint direction = [self directionFromRotation:(_barell.rotation)];
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    [self.gameBoard fireBulletFromPosition:_body.position inDirection:direction];
  });
}

- (void)moveBack:(NSInteger)distance {
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND;
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:ccp(0, -distance)];
  
  [self runRobotAction:actionMoveBy target:_body];
}

- (void)run {
  dispatch_async(_backgroundQueue, ^{
    while (true) {
      [self turnGunLeft:25];
      [self shoot];
      [self moveAhead:70];
    }
  });
}

- (void)scannedRobot {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
        [_currentRobotAction cancel];
    }
    
    [self scannedRobotEvent];
  });
}

- (void)hitWall {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
        [_currentRobotAction cancel];
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

#pragma mark - Utils

- (CGPoint)directionFromRotation:(CGFloat)objectRotation {
  CGFloat rotation = (objectRotation) * (M_PI / 180.f);
  CGFloat x = cos(rotation);
  CGFloat y = sin(rotation);
  
  return ccp(x, (-1)*y);
}

@end
