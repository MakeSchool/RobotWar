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
#import "Configuration.h"

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
  Robot *robot1 = (Robot*) [[NSClassFromString(robotClass1) alloc] init];
  Robot *robot2 = (Robot*) [[NSClassFromString(robotClass2) alloc] init];
  _robots = [NSMutableArray arrayWithArray:@[robot1, robot2]];
  
  //spawn two robots
  robot1.robotNode = [CCBReader load:@"Robot" owner:robot1];
  [robot1 _setRobotColor:[CCColor colorWithCcColor3b:ccc3(251, 72, 154)]];
  robot1.robotNode.position = ccp(50, 220);
  [self addChild:robot1.robotNode];
  robot1.gameBoard = self;
  [robot1 _run];
  robot1.creator = robotCreator1;
  robot1.robotClass = robotClass1;
  
  robot2.robotNode = [CCBReader load:@"Robot" owner:robot2];
  CGSize screenSize = [[CCDirector sharedDirector] viewSize];
  robot2.robotNode.position = ccp(screenSize.width - 50, 100);
  [self addChild:robot2.robotNode];
  robot2.gameBoard = self;
  [robot2 _run];
  robot2.robotNode.rotation = 180;
  robot2.creator = robotCreator2;
  robot2.robotClass = robotClass2;
}

- (void)transitionToGameOverScreen:(Robot *)robot {
  CCScene *gameOverSceneWrapper = [CCBReader loadAsScene:@"GameOverScene"];
  GameOverScene *gameOverScene = gameOverSceneWrapper.children[0];
  gameOverScene.winnerClass = robot.robotClass;
  gameOverScene.winnerName = robot.creator;
  [gameOverScene displayWinMessage];
  CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.3f];
  [[CCDirector sharedDirector] replaceScene:gameOverSceneWrapper withTransition:transition];
}

#pragma mark - Update Loop

- (void)update:(CCTime)delta {
  timeSinceLastEvent += delta * GAME_SPEED;
  self.currentTimestamp += delta * GAME_SPEED;
  
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
    
    if (!CGRectContainsRect(self.boundingBox, bullet.boundingBox)) {
      if (!cleanupBullets) {
        cleanupBullets = [NSMutableArray array];
      }
      
      [cleanupBullets addObject:bullet];
      continue;
    }
    
    for (Robot *robot in _robots) {
      if (bullet.bulletOwner == robot) {
        continue;
      } else if (CGRectIntersectsRect(bullet.boundingBox, robot.robotNode.boundingBox)) {
        [robot _gotHit];
        [bullet.bulletOwner _bulletHitEnemy:bullet];
        
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
      } else if (ccpDistance(robot.robotNode.position, otherRobot.robotNode.position)  < 150) {
        if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
          [robot _scannedRobot:[otherRobot copy] atPosition:otherRobot.robotNode.positionInPoints];
          [otherRobot _scannedRobot:[robot copy] atPosition:robot.robotNode.positionInPoints];
          timeSinceLastEvent = 0.f;
        }
      }
    }
  }
}

- (void)calculateCollisionAngleWithWallNormalVector:(CGPoint)wallNormalVector notifyRobot:(Robot*)robot {
  if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
    CGFloat collisionAngle;
    RobotWallHitDirection direction;
    calc_collisionAngle_WallHitDirection(wallNormalVector, robot, &collisionAngle, &direction);
    
    [robot _hitWall:direction hitAngle:collisionAngle];
    timeSinceLastEvent = 0.f;
  }
}

#pragma mark - GameBoard Protocol

- (CGSize)dimensions {
  return self.contentSizeInPoints;
}

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner {
  Bullet *bullet = [Bullet nodeWithColor:[CCColor colorWithCcColor3b:ccc3(245, 245, 245)]];
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
    
    if (_robots.count == 1) {
      [self performSelector:@selector(transitionToGameOverScreen:) withObject:_robots[0] afterDelay:2.f];
    }
  });
}

- (RobotWallHitDirection)currentWallHitDirectionForRobot:(Robot*)robot {
  static NSInteger toleranceMargin = 5;
  
  CGPoint wallNormalVector = CGPointZero;
  
  if (CGRectGetMaxX([robot.robotNode boundingBox]) >= self.contentSizeInPoints.width - toleranceMargin) {
    wallNormalVector = ccp(-1, 0);
  } else if (CGRectGetMaxY([robot.robotNode boundingBox]) >= self.contentSizeInPoints.height -toleranceMargin) {
    wallNormalVector = ccp(0, -1);
  } else if (CGRectGetMinX([robot.robotNode boundingBox]) <= toleranceMargin) {
    wallNormalVector = ccp(+1, 0);
  } else if (CGRectGetMinY([robot.robotNode boundingBox]) <= toleranceMargin) {
    wallNormalVector = ccp(0, +1);
  }
  
  if (CGPointEqualToPoint(wallNormalVector, CGPointZero)) {
    return RobotWallHitDirectionNone;
  } else {
    CGFloat collisionAngle;
    RobotWallHitDirection wallHitDirection;
    calc_collisionAngle_WallHitDirection(wallNormalVector, robot, &collisionAngle, &wallHitDirection);
    return wallHitDirection;
  }
}

#pragma mark - Util Methods/Functions

- (void)cleanupBullet:(CCNode *)bullet {
  [bullet removeFromParent];
  [_bullets removeObject:bullet];
}

void calc_collisionAngle_WallHitDirection(CGPoint wallNormalVector, Robot *robot, CGFloat *collisionAngle_p, RobotWallHitDirection *direction_p) {
  // Calculate Collision Angle
  *collisionAngle_p = ccpAngleSigned([robot headingDirection], wallNormalVector);
  *collisionAngle_p = roundf(radToDeg(*collisionAngle_p));
  *direction_p = radAngleToRobotWallHitDirection(*collisionAngle_p);
}

@end
