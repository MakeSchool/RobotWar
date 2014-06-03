//
//  Robot_Framework.h
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"

@interface Robot ()

@property (weak, nonatomic) id<GameBoard> gameBoard;
@property (weak, nonatomic) CCNode *robotNode;

- (void)_scannedRobot:(Robot*)robot;
- (void)_hitWall;
- (void)_gotHit:(Bullet*)bullet;
- (void)_run;

@end
