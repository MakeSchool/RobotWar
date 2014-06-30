//
//  RobotAction.m
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RobotAction.h"

@implementation RobotAction {
  dispatch_semaphore_t _currentActionSemaphore;
  CCActionSequence *_sequence;
}

- (void)run {
  _currentActionSemaphore = dispatch_semaphore_create(0);
  
  CCActionCallBlock *callback = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(_currentActionSemaphore);
  }];
  
  _sequence = [CCActionSequence actionWithArray:@[self.action, callback]];
  
  void (^runAction)() = ^void() {
    [self.target runAction:_sequence];
  };

  
  if ([NSThread isMainThread])
  {
    runAction();
  }
  else
  {
    dispatch_sync(dispatch_get_main_queue(), runAction);
  }
  
  dispatch_semaphore_wait(_currentActionSemaphore, DISPATCH_TIME_FOREVER);
  dispatch_release(_currentActionSemaphore);
}

- (void)cancel {
  if (self.canBeCancelled) {
    
    void (^stopAction)() = ^void() {
      [self.target stopAction:_sequence];
    };
    
    if ([NSThread isMainThread])
    {
      stopAction();
    }
    else
    {
      dispatch_sync(dispatch_get_main_queue(), stopAction);
    }
    
    dispatch_semaphore_signal(_currentActionSemaphore);
  }
}

@end
