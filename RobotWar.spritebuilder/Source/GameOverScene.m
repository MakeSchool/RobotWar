//
//  GameOverScene.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene {
  CCLabelTTF *_winnerLabel;
}

- (void)restartGame {
//  CCScene *tournamentScene = [CCBReader loadAsScene:@"TournamentScene"];
  CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
//  [[CCDirector sharedDirector] replaceScene:tournamentScene withTransition:transition];
    [[CCDirector sharedDirector] popSceneWithTransition:transition];
}

- (void)displayWinMessage {
    
    if (!self.winnerName || [self.winnerName isEqualToString:@""])
        _winnerLabel.string = [NSString stringWithFormat:@"%@ wins this battle!", self.winnerClass];
    else
        _winnerLabel.string = [NSString stringWithFormat:@"%@'s %@ wins this battle!", self.winnerName, self.winnerClass];
}

@end
