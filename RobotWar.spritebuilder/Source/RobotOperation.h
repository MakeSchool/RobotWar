//
//  RobotOperation.h
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotOperation : NSOperation

@property (nonatomic, weak) CCNode *target;
@property (nonatomic, strong) CCActionFiniteTime *action;
@property (nonatomic, assign) dispatch_semaphore_t semaphore;

@end
