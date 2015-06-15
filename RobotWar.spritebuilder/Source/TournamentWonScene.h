//
//  TournamentWonScene.h
//  RobotWar
//
//  Created by Daniel Haaser on 7/6/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "CCScene.h"

@interface TournamentWonScene : CCScene

@property (nonatomic, copy) NSString* winningRobot;
@property (nonatomic, assign) int recordWins;
@property (nonatomic, assign) int recordLosses;

@end
