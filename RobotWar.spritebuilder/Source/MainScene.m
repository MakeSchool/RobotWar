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
#import "GameConstants.h"
#import "AdvancedRobot.h"
#import "Helpers.h"

@implementation MainScene {
  CGFloat timeSinceLastEvent;
  NSMutableArray *_bullets;
  NSMutableArray *_robots;
}

#pragma mark - Lifecycle / Scene Transitions

- (void)dealloc {
  NSLog(@"Game Over!");
}

- (void)didLoadFromCCB {
  _bullets = [NSMutableArray array];

  _robots = [NSMutableArray array];
  
  // intantiate two AIs
  Robot *robot1 = [[AdvancedRobot alloc] init];
  Robot *robot2 = [[SimpleRobot alloc] init];
  _robots = [NSMutableArray arrayWithArray:@[robot1, robot2]];
  
  //spawn two robots
//  robot1.robotNode = [CCBReader load:@"Robot" owner:robot1];
//  robot1.robotNode.position = ccp(50, 200);
//  [self addChild:robot1.robotNode];
//  robot1.gameBoard = self;
//  [robot1 _run];
//  robot1.name = @"Benji's Robot";
  
  robot2.robotNode = [CCBReader load:@"Robot" owner:robot2];
  robot2.robotNode.position = ccp(240,200);
  [self addChild:robot2.robotNode];
  robot2.gameBoard = self;
  [robot2 _run];
  robot2.robotNode.rotation = 180;
  robot2.name = @"Jeremy's Robot";
}

- (void)transitionToGameOverScreen:(Robot *)robot {
  CCScene *gameOverSceneWrapper = [CCBReader loadAsScene:@"GameOverScene"];
  GameOverScene *gameOverScene = gameOverSceneWrapper.children[0];
  gameOverScene.winnerName = robot.name;
  CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
  [[CCDirector sharedDirector] replaceScene:gameOverSceneWrapper withTransition:transition];
}

#pragma mark - Update Loop

- (void)update:(CCTime)delta {
  timeSinceLastEvent += delta;
  
  for (Robot *robot in _robots) {
    if (!CGRectContainsRect(self.boundingBox, robot.robotNode.boundingBox)) {
      
      /**
       Don't permit robots to leave the arena
       */
      while (CGRectGetMaxX([robot.robotNode boundingBox]) > self.contentSizeInPoints.width) {
        robot.robotNode.position = ccp(robot.robotNode.position.x-1, robot.robotNode.position.y);
        [self calculateCollisionAngleWithWallNormalVector:ccp(-1, 0) notifyRobot:robot];
      }
      
      while (CGRectGetMaxY([robot.robotNode boundingBox]) > self.contentSizeInPoints.height) {
        robot.robotNode.position = ccp(robot.robotNode.position.x, robot.robotNode.position.y-1);
        [self calculateCollisionAngleWithWallNormalVector:ccp(0, -1) notifyRobot:robot];
      }
      
      while (CGRectGetMinX([robot.robotNode boundingBox]) < 0) {
        robot.robotNode.position = ccp(robot.robotNode.position.x+1, robot.robotNode.position.y);
        [self calculateCollisionAngleWithWallNormalVector:ccp(+1, 0) notifyRobot:robot];
      }
      
      while (CGRectGetMinY([robot.robotNode boundingBox]) < 0) {
        robot.robotNode.position = ccp(robot.robotNode.position.x, robot.robotNode.position.y+1);
        [self calculateCollisionAngleWithWallNormalVector:ccp(0, +1) notifyRobot:robot];
      }
      
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
  
  // Robot Detection
  for (Robot *robot in _robots) {
    for (Robot *otherRobot in _robots) {
      if (otherRobot == robot) {
        continue;
      } else if (ccpDistance(robot.robotNode.position, otherRobot.robotNode.position)  < 100) {
        if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
          [robot _scannedRobot:otherRobot atPosition:otherRobot.robotNode.positionInPoints];
          [otherRobot _scannedRobot:robot atPosition:robot.robotNode.positionInPoints];
          timeSinceLastEvent = 0.f;
        }
      }
    }
    
  }
  
}

- (void)calculateCollisionAngleWithWallNormalVector:(CGPoint)wallNormalVector notifyRobot:(Robot*)robot {

  if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
    // Calculate Collision Angle
    CGFloat collisionAngle = ccpAngleSigned([robot headingDirection], wallNormalVector);
    collisionAngle = roundf(radToDeg(collisionAngle));
    
    [robot _hitWall:radAngleToRobotWallHitDirection(collisionAngle) hitAngle:collisionAngle];
    timeSinceLastEvent = 0.f;
  }
  
}


- (RobotWallHitDirection)currentWallHitDirectionForRobot:(Robot*)robot {
  static NSInteger toleranceMargin = 5;
  
  if (CGRectGetMaxX([robot.robotNode boundingBox]) >= self.contentSizeInPoints.width - toleranceMargin) {
    // Calculate Collision Angle
    CGFloat collisionAngle = ccpAngleSigned([robot headingDirection], ccp(-1, 0));
    collisionAngle = roundf(radToDeg(collisionAngle));
    
    return radAngleToRobotWallHitDirection(collisionAngle);
  } else if (CGRectGetMaxY([robot.robotNode boundingBox]) >= self.contentSizeInPoints.height -toleranceMargin) {
    // Calculate Collision Angle
    CGFloat collisionAngle = ccpAngleSigned([robot headingDirection], ccp(0, -1));
    collisionAngle = roundf(radToDeg(collisionAngle));
    
    return radAngleToRobotWallHitDirection(collisionAngle);
  } else if (CGRectGetMinX([robot.robotNode boundingBox]) <= toleranceMargin) {
    // Calculate Collision Angle
    CGFloat collisionAngle = ccpAngleSigned([robot headingDirection], ccp(+1, 0));
    collisionAngle = roundf(radToDeg(collisionAngle));
    
    return radAngleToRobotWallHitDirection(collisionAngle);
  } else if (CGRectGetMinY([robot.robotNode boundingBox]) <= toleranceMargin) {
    // Calculate Collision Angle
    CGFloat collisionAngle = ccpAngleSigned([robot headingDirection], ccp(0, +1));
    collisionAngle = roundf(radToDeg(collisionAngle));

    return radAngleToRobotWallHitDirection(collisionAngle);
  } else {
    return RobotWallHitDirectionNone;
  }
}

#pragma mark - GameBoard Protocol

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner {
  Bullet *bullet = [Bullet nodeWithColor:[CCColor redColor]];
  bullet.contentSize = CGSizeMake(5.f, 5.f);
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.1f/GAME_SPEED position:ccpMult(direction, 20)];
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
    
    [self performSelector:@selector(transitionToGameOverScreen:) withObject:robot afterDelay:1.f];
  });
}

#pragma mark - Util Methods

- (void)cleanupBullet:(CCNode *)bullet {
  [bullet removeFromParent];
  [_bullets removeObject:bullet];
}

@end
