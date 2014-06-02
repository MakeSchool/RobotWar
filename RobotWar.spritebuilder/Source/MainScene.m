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

@implementation MainScene {
  CGFloat timeSinceLastEvent;
  NSMutableArray *_bullets;
  NSArray *_robots;
}

- (void)didLoadFromCCB {
  _bullets = [NSMutableArray array];

  _robots = [NSMutableArray array];
  
  // intantiate two AIs
  Robot *robot1 = [[Robot alloc]init];
  Robot *robot2 = [[Robot alloc]init];
  _robots = @[robot1, robot2];
  

  //spawn two robots
  robot1.robotNode = [CCBReader load:@"Robot" owner:robot1];
  robot1.robotNode.position = ccp(50, 200);
  [self addChild:robot1.robotNode];
  robot1.gameBoard = self;
  [robot1 run];
  robot1.name = @"Robo 1";
  
  robot2.robotNode = [CCBReader load:@"Robot" owner:robot2];
  robot2.robotNode.position = ccp(200,200);
  [self addChild:robot2.robotNode];
  robot2.gameBoard = self;
  [robot2 run];
  robot2.name = @"Robo 2";
  
  [robot1 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot1 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot1 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot1 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  
  
  [robot2 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot2 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot2 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
  [robot2 performSelector:@selector(scannedRobot) withObject:nil afterDelay:2.f];
}

- (void)update:(CCTime)delta {
  timeSinceLastEvent += delta;
  
  if (timeSinceLastEvent < 0.1f) {
    return;
  }
  
  for (Robot *robot in _robots) {
    if (!CGRectContainsRect(self.boundingBox, robot.robotNode.boundingBox)) {
      [robot hitWall];
      timeSinceLastEvent = 0.f;
    }
  }
  
  NSMutableArray *cleanupBullets = nil;
  
  for (Bullet *bullet in _bullets) {
    
    for (Robot *robot in _robots) {
      if (bullet.bulletOwner == robot) {
        continue;
      } else if (CGRectIntersectsRect(bullet.boundingBox, robot.robotNode.boundingBox)) {
        [robot gotHit:bullet];
        
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

@end
