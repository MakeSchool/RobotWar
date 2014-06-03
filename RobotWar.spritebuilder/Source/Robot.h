//
//  Robot.h
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "MainScene.h"

@class Bullet;

@protocol RobotProtocol <NSObject>

- (void)scannedRobot;
- (void)hitWall;
- (void)gotHit:(Bullet*)bullet;
- (void)run;

@end

@interface Robot : NSObject <RobotProtocol>

@property (copy, nonatomic) NSString *name;

- (void)turnGunLeft:(NSInteger)degree;
- (void)turnGunRight:(NSInteger)degree;
- (void)moveAhead:(NSInteger)distance;
- (void)moveBack:(NSInteger)distance;
- (void)shoot;

@end