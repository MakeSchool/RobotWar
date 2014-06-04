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

/** ------Event Handler------- 
 * 
 *  All of the following event handler are called with a high priority. If an event handler calls 'cancelActiveAction'
 *  the currently running action of a robot will be stopped immediately. Any commands to the robot after this cancellation
 *  will also be performed immediately.
 *
 **/

- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position;
- (void)hitWall;
- (void)gotHit:(Bullet*)bullet;
- (void)run;

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

- (void)cancelActiveAction;

@end