//
//  Robot.h
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol RobotProtocol <NSObject>

- (void)scannedRobot;

@end

@interface Robot : NSObject <RobotProtocol>

- (void)turnGunLeft:(NSInteger)degree;
- (void)turnGunRight:(NSInteger)degree;
- (void)moveAhead:(NSInteger)distance;

- (void)run;

@end