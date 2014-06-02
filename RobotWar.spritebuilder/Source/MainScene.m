//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Robot.h"

@implementation MainScene {
  Robot *robot1;
  Robot *robot2;
  
  CCNode *robotNode1;
  CCNode *robotNode2;
  
  CGFloat timeSinceLastEvent;
  NSMutableArray *_bullets;
}

- (void)didLoadFromCCB {
  _bullets = [NSMutableArray array];
  
  // intantiate two AIs
  robot1 = [[Robot alloc]init];
  robot2 = [[Robot alloc]init];

  //spawn two robots
  robotNode1 = [CCBReader load:@"Robot" owner:robot1];
  robotNode1.position = ccp(50, 200);
  [self addChild:robotNode1];
  robot1.gameBoard = self;
  [robot1 run];
  
  robotNode2 = [CCBReader load:@"Robot" owner:robot2];
  robotNode2.position = ccp(200,200);
  [self addChild:robotNode2];
  robot2.gameBoard = self;
  [robot2 run];
  
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
  
  if (!CGRectContainsRect(self.boundingBox, robotNode1.boundingBox)) {
    [robot1 hitWall];
    timeSinceLastEvent = 0.f;
  }
  
  if (!CGRectContainsRect(self.boundingBox, robotNode2.boundingBox)) {
    [robot2 hitWall];
    timeSinceLastEvent = 0.f;
  }
  
  for (CCNode *bullet in _bullets) {
    if (CGRectIntersectsRect(bullet.boundingBox, robotNode1.boundingBox)) {
      CCLOG(@"Kill Robot1");
      
    } else {
      CCLOG(@"Kill Robot2");
    }
  }

}

- (void)cleanupBullet:(CCNode *)bullet {
  [bullet removeFromParent];
  [_bullets removeObject:bullet];
}

#pragma mark - GameBoard Protocol

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction {
  CCNodeColor *bullet = [CCNodeColor nodeWithColor:[CCColor redColor]];
  bullet.contentSize = CGSizeMake(5.f, 5.f);
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.1f position:ccpMult(direction, 20)];
  CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:moveBy];
  
  [self addChild:bullet];
  bullet.position = position;
  [bullet runAction:repeat];
}

@end
