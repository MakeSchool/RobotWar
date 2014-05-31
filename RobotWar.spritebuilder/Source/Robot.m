//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 60;

@interface Robot ()

@end

@implementation Robot {
  CCNode *_barell;
  CCNode *_body;
  
  dispatch_queue_t _backgroundQueue;
  dispatch_queue_t _mainQueue;
  
  dispatch_group_t mainQueueGroup;
  dispatch_semaphore_t _currentActionSemaphore;

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
  
  __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);

  _currentActionSemaphore = sema;
  
  CCActionCallBlock *callback = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(sema);
  }];
  
  CCActionSequence *sequence = [CCActionSequence actionWithArray:@[rotateTo, callback]];
  dispatch_async(dispatch_get_main_queue(), ^{
    [_barell runAction:sequence];
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  dispatch_release(sema);
  _currentActionSemaphore = NULL;
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  
  
  CCActionCallBlock *callback = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(sema);
  }];
  
  CCActionSequence *sequence = [CCActionSequence actionWithArray:@[rotateTo, callback]];
  dispatch_async(dispatch_get_main_queue(), ^{
    [_barell runAction:sequence];
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  dispatch_release(sema);
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
    // pause background queue and run whatever we want to run here
    [_body stopAllActions];
    [_barell stopAllActions];

    if (_currentActionSemaphore != NULL) {
      dispatch_semaphore_signal(_currentActionSemaphore);
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
