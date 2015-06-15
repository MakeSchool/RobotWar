//
//  TournamentWonScene.m
//  RobotWar
//
//  Created by Daniel Haaser on 7/6/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "TournamentWonScene.h"

@implementation TournamentWonScene
{
    CCLabelTTF* robotLabel;
}

- (void)setWinningRobot:(NSString *)winningRobot
{
    robotLabel.string = winningRobot;
    _winningRobot = [winningRobot copy];
}

//- (void)onEnterTransitionDidFinish
//{
//    [super onEnterTransitionDidFinish];
//
//    robotLabel.string = self.winningRobot;
//}

@end
