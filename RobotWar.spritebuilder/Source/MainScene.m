//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Robot.h"
#import "Bullet.h"
#import "GameOverScene.h"
#import "Robot_Framework.h"
#import "SimpleRobot.h"

@implementation MainScene {
  CGFloat timeSinceLastEvent;
  NSMutableArray *_bullets;
  NSMutableArray *_robots;
}

- (void)didLoadFromCCB {
  _bullets = [NSMutableArray array];

  _robots = [NSMutableArray array];
  
  // intantiate two AIs
  Robot *robot1 = [[Robot alloc]init];
  Robot *robot2 = [[SimpleRobot alloc]init];
  _robots = [NSMutableArray arrayWithArray:@[robot1, robot2]];
  
  //spawn two robots
  robot1.robotNode = [CCBReader load:@"Robot" owner:robot1];
  robot1.robotNode.position = ccp(50, 200);
  [self addChild:robot1.robotNode];
  robot1.gameBoard = self;
  [robot1 _run];
  robot1.name = @"Benji's Robot";
  
  robot2.robotNode = [CCBReader load:@"Robot" owner:robot2];
  robot2.robotNode.position = ccp(200,200);
  [self addChild:robot2.robotNode];
  robot2.gameBoard = self;
  [robot2 _run];
  robot2.name = @"Jeremy's Robot";
}

- (void)update:(CCTime)delta {
  timeSinceLastEvent += delta;
  
  if (timeSinceLastEvent < 0.1f) {
    return;
  }
  
  for (Robot *robot in _robots) {
    if (!CGRectContainsRect(self.boundingBox, robot.robotNode.boundingBox)) {
      [robot _hitWall];
      timeSinceLastEvent = 0.f;
    }
  }
  
  NSMutableArray *cleanupBullets = nil;
  
  for (Bullet *bullet in _bullets) {
    
    for (Robot *robot in _robots) {
      if (bullet.bulletOwner == robot) {
        continue;
      } else if (CGRectIntersectsRect(bullet.boundingBox, robot.robotNode.boundingBox)) {
        [robot _gotHit:bullet];
        
        if (!cleanupBullets) {
          cleanupBullets = [NSMutableArray array];
        }
      
        [cleanupBullets addObject:bullet];
      }
    }
  }
  
  for (Bullet *bullet in cleanupBullets) {
    [self cleanupBullet:bullet];
  }
}

- (void)cleanupBullet:(CCNode *)bullet {
  [bullet removeFromParent];
  [_bullets removeObject:bullet];
}

#pragma mark - GameBoard Protocol

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner {
  Bullet *bullet = [Bullet nodeWithColor:[CCColor redColor]];
  bullet.contentSize = CGSizeMake(5.f, 5.f);
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.1f position:ccpMult(direction, 20)];
  CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:moveBy];
  
  bullet.bulletOwner = owner;
  [_bullets addObject:bullet];
  [self addChild:bullet];
  bullet.position = position;
  [bullet runAction:repeat];
}

- (void)robotDied:(Robot *)robot {
  dispatch_async(dispatch_get_main_queue(), ^{
    
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"RobotExplosion"];
    [self addChild:explosion];
    explosion.position = robot.robotNode.positionInPoints;
    
    [robot.robotNode removeFromParent];
    [_robots removeObject:robot];
    
    [self performSelector:@selector(transitionToGameOverSceen:) withObject:robot afterDelay:1.f];
  });
}

#pragma mark - Game Over

- (void)transitionToGameOverSceen:(Robot *)robot {
  CCScene *gameOverSceneWrapper = [CCBReader loadAsScene:@"GameOverScene"];
  GameOverScene *gameOverScene = gameOverSceneWrapper.children[0];
  gameOverScene.winnerName = robot.name;
  CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
  [[CCDirector sharedDirector] replaceScene:gameOverSceneWrapper withTransition:transition];
}

@end
