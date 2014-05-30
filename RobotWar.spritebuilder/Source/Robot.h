//
//  Robot.h
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Robot : NSObject

- (void)turnGunLeft:(NSInteger)degree;
- (void)turnGunRight:(NSInteger)degree;
- (void)performAction;

@property (nonatomic, assign) dispatch_queue_t operationQueue;

@end
