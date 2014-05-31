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

- (instancetype)init {
  self = [super init];
  
  if (self) {
    _backgroundQueue = dispatch_queue_create("backgroundQueue", DISPATCH_QUEUE_SERIAL);
    _mainQueue = dispatch_queue_create("mainQueue", DISPATCH_QUEUE_SERIAL);
  }
  
  return self;
}

- (void)turnGunLeft:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo];
}

- (void)runRobotAction:(CCActionRotateTo *)rotateTo {
  RobotAction *robotAction = [[RobotAction alloc] init];
  robotAction.target = _barell;
  robotAction.action = rotateTo;
  _currentRobotAction = robotAction;
  
  [robotAction run];
  
  _currentRobotAction = nil;
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo];
}

- (void)run {
  dispatch_async(_backgroundQueue, ^{
    while (true) {
      [self turnGunLeft:2000];
      
      if (mainQueueGroup != NULL) {
        dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
        dispatch_release(mainQueueGroup);
        mainQueueGroup = NULL;
      }
    }
  });
}

- (void)scannedRobot {
  if (mainQueueGroup == NULL) {
    mainQueueGroup = dispatch_group_create();
  }
  
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
      [_currentRobotAction cancel];
    }
    
    [self scannedRobotEvent];
  });
}

- (void)scannedRobotEvent {
  [self turnGunRight:90];
  [self turnGunLeft:10];
  [self turnGunRight:10];
}

@end
