//
//  GameOverScene.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverScene.h"
#import "TournamentScene.h"
#import "TournamentConfiguration.h"

@implementation GameOverScene {
  CCLabelTTF *_winnerLabel;
  CCLabelTTF *_countdownLabel;
  int countdown;
}

- (void)didLoadFromCCB
{
    countdown = COUNTDOWN;
}

- (void)onEnter
{
    [super onEnter];
  
    if (TOURNAMENT) {
      _countdownLabel.string = [NSString stringWithFormat:@"%d", countdown];
      [self schedule:@selector(updateCountdown) interval:1.0f];
    } else {
      _countdownLabel.visible = NO;
    }
}

- (void)cleanup
{
    [self unschedule:@selector(updateCountdown)];
}

- (void)loadTournamentScene
{
    TournamentScene* tournamentScene = (TournamentScene*) [CCBReader load:@"TournamentScene"];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
    
    [tournamentScene updateWithResults:@{@"Winner": self.winnerClass, @"Loser": self.loserClass}];
    
    CCScene* newScene = [CCScene node];
    [newScene addChild:tournamentScene];
    
    [[CCDirector sharedDirector] replaceScene:newScene withTransition:transition];
}

- (void)displayWinMessage
{
    if (!self.winnerName || [self.winnerName isEqualToString:@""])
        _winnerLabel.string = [NSString stringWithFormat:@"%@ wins this battle!", self.winnerClass];
    else
        _winnerLabel.string = [NSString stringWithFormat:@"%@'s %@ wins this battle!", self.winnerName, self.winnerClass];
}

- (void)updateCountdown
{
  countdown--;
  
  _countdownLabel.string = [NSString stringWithFormat:@"%d", countdown];
  
  if (countdown <= 0)
  {
    [self loadTournamentScene];
  }
}

@end
