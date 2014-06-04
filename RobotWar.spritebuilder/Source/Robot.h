//
//  Robot.h
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@class Bullet;
@class Robot;

typedef NS_ENUM(NSInteger, RobotWallHitDirection) {
  RobotWallHitDirectionNone,
  RobotWallHitDirectionFront,
  RobotWallHitDirectionLeft,
  RobotWallHitDirectionRear,
  RobotWallHitDirectionRight
};

@protocol RobotProtocol <NSObject>

/** ------Event Handler------- 
 * 
 *  All of the following event handler are called with a high priority. If an event handler calls 'cancelActiveAction'
 *  the currently running action of a robot will be stopped immediately. Any commands to the robot after this cancellation
 *  will also be performed immediately.
 *
 **/

- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position;
- (void)gotHit:(Bullet*)bullet;
- (void)run;

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle;

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

// info: Heading Direction

- (CGPoint)headingDirection;

@end