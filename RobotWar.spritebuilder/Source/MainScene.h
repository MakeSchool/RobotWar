//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Robot.h"

@class Robot;
@protocol  RobotWallHitDirection;

@protocol GameBoard <NSObject>

@property (atomic, assign) CGFloat currentTimestamp;

// direction should be normalized
- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner;
- (void)robotDied:(Robot*)robot;
- (RobotWallHitDirection)currentWallHitDirectionForRobot:(Robot*)robot;
- (CGSize)dimensions;

@end

@interface MainScene : CCNode <GameBoard>

@property (atomic, assign) CGFloat currentTimestamp;

@end
