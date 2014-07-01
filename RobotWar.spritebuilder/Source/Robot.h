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

@interface Robot : NSObject <NSCopying>

@property (copy, nonatomic) NSString *creator;
@property (copy, nonatomic) NSString *robotClass;

/*!
 @methodgroup Event Handlers
 */

/*
 All of the following event handlers are called with a high priority. If an event handler calls 'cancelActiveAction'
 the currently running action of a robot will be stopped immediately. Any commands to the robot after this cancellation
 will also be performed immediately. Code running within the event handlers, such as movements, etc. will block further events from being called, until that action has been completed. Therefore you should avoid performing long actions directly in event handlers and instead set a state variable for your robot and run the behaviour from within the run method.
 */


/*!
 @method
 
 This method is called ONCE when the match begins. Most robots will implement an endless loop in the run method
 and add different movement patterns to this loop.
 */
- (void)run;

/*! 
 @method 
 
 This method is called when another robot has been detected. Another robot is detected if it
 is within 150 points of your robot.
 
 @param robot
  Shallow copy of the robot that has been scanned. You can only access the class name
  and the owner of the robot.
 @param position
  World position of the robot that has been scanned
 */
- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position;

/*!
 @method
 
 This method is called when this robot got hit by a bullet.
 */
- (void)gotHit;

/*!
 @method
 
 This method is called when this robot hits one of the area walls.
 Robots should attempt moving away from a wall when receiving this event.
 
 @param hitDirection
  Describes which face of the robot has hit the wall (front, left, rear, right)
  
 @param hitAngle
  Provides the exact angle of the collision between robot and the wall.
  Angle is between -179 and +179
  An angle > 0 means that the robot hit the wall with the left side,
  An angle < 0 means that the robot hit the wall with the right side.
 */
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle;

/*!
 @method
 
 Informs this robot that a bullet is has fired has hit an enemy.
 
 @param bullet
  Reference to the bullet that hit the enemy.
 
 */
- (void)bulletHitEnemy:(Bullet*)bullet;


/*!
 @methodgroup Actions
 */

/*!
 @method
 
 Turns the gun of the robot to the left.
 
 @param degrees degrees of rotation
 */
- (void)turnGunLeft:(NSInteger)degrees;

/*!
 @method
 
 Turns the gun of the robot to the right.
 
 @param degrees degrees of rotation
 */
- (void)turnGunRight:(NSInteger)degrees;

/*!
 @method
 
 Turns the robot to the left.
 
 @param degrees degrees of rotation
 */
- (void)turnRobotLeft:(NSInteger)degrees;

/*!
 @method
 
 Turns the robot to the right.
 
 @param degrees degrees of rotation
 */
- (void)turnRobotRight:(NSInteger)degrees;

/*!
 @method
 
 Moves the robot ahead in the direction it is currently heading.
 
 @param distance distance in points
 */
- (void)moveAhead:(NSInteger)distance;

/*!
 @method
 
Moves the robot backwards in the direction opposite to the one it is currently heading.
 
 @param distance distance in points
 */
- (void)moveBack:(NSInteger)distance;

/*!
 @method
 
 Shoots a bullet in the direction the gun is currently heading.
 Note: unlike all other actions this action cannot be cancelled.
 After shooting the robot will freeze for 0.5 game seconds.
 */
- (void)shoot;

/*!
 @method
 
 Calling this method will cancel the currently perforemed action (movement, rotation, etc.). 
 This is useful within event handlers. You can cancel the currently active action to take immediate control of your Robot in       
 order to respond to an event.
 
 Note that the 'shoot' action will not be cancelled by calling this method.
 */
 - (void)cancelActiveAction;

/*!
 @methodgroup Information Retrieval
 */

/*!
 @method
 
 @return Returns the bounding box of this robot in world coordinates. 
 */
- (CGRect)robotBoundingBox;

/*!
 @method
 
 @return Returns the position of this robot in world coordinates.
 */
- (CGPoint)position;

/*!
 @method
 
 @return Returns the heading direction of the robot in form of a vector.
 */
- (CGPoint)headingDirection;

/*!
 @method
 
 @return Returns the angle between the heading direction of the robot and an arbitrary point.
  Use this information to turn the robot in the direction / opposite direction of a detected object.
 */
- (CGFloat)angleBetweenHeadingDirectionAndWorldPosition:(CGPoint)position;

/*!
 @method
 
 @return Returns the gun heading direction in form of a vector.
 */
- (CGPoint)gunHeadingDirection;

/*!
 @method
 
 @return Returns the angle between the heading direction of the gun of the robot and an arbitrary point.
 Use this information to turn the gun of the robot in the direction / opposite direction of a detected object.
 */
- (CGFloat)angleBetweenGunHeadingDirectionAndWorldPosition:(CGPoint)position;

/*!
 @method
 
 @return Returns the current timestamp. You can use the timestamp to mark information as stale after a certain
 timespan has passed.
 */
- (CGFloat)currentTimestamp;

/*!
 @method
 
 @return Returns the dimensions of the Arena. The bottom left corner of the area has a world position of (0,0). 
 Use this information to determine your position within the arena.
 */
- (CGSize)arenaDimensions;

@end