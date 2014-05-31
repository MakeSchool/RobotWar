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
  __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  _currentActionSemaphore = sema;
  
  CCActionCallBlock *callback = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(sema);
  }];
  
  _sequence = [CCActionSequence actionWithArray:@[self.action, callback]];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.target runAction:_sequence];
  });
  
  dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  dispatch_release(sema);
}

- (void)cancel {
  [self.target stopAction:_sequence];
  dispatch_semaphore_signal(_currentActionSemaphore);
}

@end
