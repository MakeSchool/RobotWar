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
  CCScene *gameOverScene = [CCBReader loadAsScene:@"MainScene"];
  CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
  [[CCDirector sharedDirector] replaceScene:gameOverScene withTransition:transition];
}

- (void)setWinnerName:(NSString *)winnerName {
  _winnerName = [winnerName copy];
  _winnerLabel.string = [NSString stringWithFormat:@"%@ wins this battle!", winnerName];
}

@end
