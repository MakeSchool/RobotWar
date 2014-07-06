//
//  Robot_Framework.h
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "MainScene.h"

@interface Robot ()

@property (weak, nonatomic) id<GameBoard> gameBoard;
@property (weak, nonatomic) CCNode *robotNode;

//- (void)_bulletMissed
// bulletHit
- (void)_scannedRobot:(Robot*)robot atPosition:(CGPoint)position;
- (void)_hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle;
- (void)_gotHit;
- (void)_run;
- (void)_bulletHitEnemy:(Bullet*)bullet;
- (void)_setRobotColor:(CCColor*)color;
- (void)_setFieldOfViewColor:(CCColor*)color;
- (void)_updateFOVScaned:(BOOL)scanned;

@end
