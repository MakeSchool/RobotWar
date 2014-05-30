//
//  RobotOperation.m
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RobotOperation.h"

@implementation RobotOperation {
  CCActionSequence *_sequence;
}

- (void)main {
  CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
    dispatch_semaphore_signal(self.semaphore);
  }];
  
  _sequence = [CCActionSequence actionOne:self.action two:actionCallBlock];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.target runAction:_sequence];
  });

  return;
}

- (void)cancel {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.target stopAction:_sequence];
    dispatch_semaphore_signal(self.semaphore);
  });
}

@end
