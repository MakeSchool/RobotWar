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
#import "GameConstants.h"
#import "Helpers.h"
#import "Configuration.h"

@implementation MainScene {
  CGFloat timeSinceLastEvent;
  NSMutableArray *_bullets;
  NSMutableArray *_robots;
  
  CCNodeColor *_gameNode;
    
  CCLabelTTF* _robot1Label;
  CCLabelTTF* _robot2Label;
}

#pragma mark - Lifecycle / Scene Transitions

- (void)dealloc {
  NSLog(@"Game Over!");
}

- (void)didLoadFromCCB {
    
  _bullets = [NSMutableArray array];
  
  _robots = [NSMutableArray array];
    
  [self initWithRobotClassOne:robotClass1 creatorOne:robotCreator1 andRobotClassTwo:robotClass2 creatorTwo:robotCreator2];
}

- (void)initWithRobotClassOne:(NSString *)botClass1 creatorOne: (NSString*)creator1 andRobotClassTwo:(NSString *)botClass2 creatorTwo:(NSString *)creator2 {
  // intantiate two AIs

  Robot *robot1 = (Robot*) [[NSClassFromString(botClass1) alloc] init];
  Robot *robot2 = (Robot*) [[NSClassFromString(botClass2) alloc] init];
  _robots = [NSMutableArray arrayWithArray:@[robot1, robot2]];

  //spawn two robots
  robot1.robotNode = [CCBReader load:@"Robot" owner:robot1];
  [robot1 _setRobotColor:[CCColor colorWithCcColor3b:ccc3(251, 72, 154)]];
  [robot1 _setFieldOfViewColor:[CCColor colorWithCcColor3b:ccc3(251, 87, 172)]];
  
  robot1.robotNode.position = ccp(50, arc4random_uniform(140) + 80);
  [_gameNode addChild:robot1.robotNode];
  robot1.gameBoard = self;
  [robot1 _run];
  robot1.creator = creator1;
  robot1.robotClass = botClass1;

  robot2.robotNode = [CCBReader load:@"Robot" owner:robot2];
  CGSize screenSize = [[CCDirector sharedDirector] viewSize];
  robot2.robotNode.position = ccp(screenSize.width - 50, arc4random_uniform(140) + 80);
  [_gameNode addChild:robot2.robotNode];
  robot2.gameBoard = self;
  [robot2 _run];
  robot2.robotNode.rotation = 180;
  robot2.creator = creator2;
  robot2.robotClass = botClass2;
    
  [self updateScoreLabels];
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
  BOOL labelsNeedUpdate = NO;
  
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
        labelsNeedUpdate = YES;
        [bullet.bulletOwner _bulletHitEnemy:bullet];
          
        CCParticleSystem *bulletExplosion = (CCParticleSystem *) [CCBReader load:@"BulletExplosion"];
        bulletExplosion.position = bullet.position;
        [_gameNode addChild:bulletExplosion];
        
        if (!cleanupBullets) {
          cleanupBullets = [NSMutableArray array];
        }
        
        [cleanupBullets addObject:bullet];
      }
    }
  }
    
  if (labelsNeedUpdate)
      [self updateScoreLabels];
  
  for (Bullet *bullet in cleanupBullets) {
    [self cleanupBullet:bullet];
  }
  
  // Robot Detection
  for (Robot *robot in _robots) {
    for (Robot *otherRobot in _robots) {
      if (otherRobot == robot) {
        continue;
      } else if (ccpDistance(robot.robotNode.position, otherRobot.robotNode.position)  < SCAN_DISTANCE) {
        if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
          if (fabsf([robot angleBetweenGunHeadingDirectionAndWorldPosition:otherRobot.position]) < SCAN_FIELD_OF_VIEW/2) {
            [robot _scannedRobot:[otherRobot copy] atPosition:otherRobot.robotNode.positionInPoints];
            [robot _updateFOVScaned:YES];
          } else {
            [robot _updateFOVScaned:NO];
          }
          if (fabsf([otherRobot angleBetweenGunHeadingDirectionAndWorldPosition:robot.position]) < SCAN_FIELD_OF_VIEW/2) {
            [otherRobot _scannedRobot:[robot copy] atPosition:robot.robotNode.positionInPoints];
            [otherRobot _updateFOVScaned:YES];
          } else {
            [otherRobot _updateFOVScaned:NO];
          }
          timeSinceLastEvent = 0.f;
        }
      } else {
        [robot _updateFOVScaned:NO];
        [otherRobot _updateFOVScaned:NO];
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
  return [[CCDirector sharedDirector] viewSize];
}

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner {
  Bullet *bullet = [Bullet nodeWithColor:[CCColor colorWithCcColor3b:ccc3(245, 245, 245)]];
  bullet.contentSize = CGSizeMake(5.f, 5.f);
  CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.1f/GAME_SPEED position:ccpMult(direction, 20)];
  CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:moveBy];
  
  bullet.bulletOwner = owner;
  [_bullets addObject:bullet];
  [_gameNode addChild:bullet];
  bullet.position = position;
  [bullet runAction:repeat];
}

- (void)robotDied:(Robot *)robot {
  dispatch_async(dispatch_get_main_queue(), ^{
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"RobotExplosion"];
    [_gameNode addChild:explosion];
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

- (void)updateScoreLabels {
  Robot* robot1 = nil;
  Robot* robot2 = nil;
    
  if (_robots.count > 0) robot1 = (Robot*) _robots[0];
  if (_robots.count > 1) robot2 = (Robot*) _robots[1];
    
  if (robot1)
      _robot1Label.string = [NSString stringWithFormat:@"%@: %d", robot1.robotClass, [robot1 hitPoints]];
  else
      _robot1Label.string = [NSString stringWithFormat:@"DEAD"];
      
  if (robot2)
      _robot2Label.string = [NSString stringWithFormat:@"%@: %d", robot2.robotClass, [robot2 hitPoints]];
  else
      _robot2Label.string = [NSString stringWithFormat:@"DEAD"];
}

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
