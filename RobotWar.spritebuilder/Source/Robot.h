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

- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position;
- (void)hitWall;
- (void)gotHit:(Bullet*)bullet;
- (void)run;
- (void)cancelActiveAction;

@end

@interface Robot : NSObject <RobotProtocol>

@property (copy, nonatomic) NSString *name;

- (void)turnGunLeft:(NSInteger)degree;
- (void)turnGunRight:(NSInteger)degree;

- (void)turnRobotLeft:(NSInteger)degree;
- (void)turnRobotRight:(NSInteger)degree;

- (void)moveAhead:(NSInteger)distance;
- (void)moveBack:(NSInteger)distance;

- (void)shoot;

@end