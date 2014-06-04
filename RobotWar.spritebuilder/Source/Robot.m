//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "RobotAction.h"
#import "Robot_Framework.h"
#import "GameConstants.h"
#import "MainScene.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 100;
static CGFloat const ROBOT_DISTANCE_PER_SECOND = 100;

static NSInteger const ROBOT_INITIAL_LIFES = 3;

@interface Robot ()

@property (nonatomic, assign) NSInteger health;

@end

@implementation Robot {
  CCNode *_barell;
  CCNode *_body;
  CCNode *_healthBar;
  
  dispatch_queue_t _backgroundQueue;
  dispatch_queue_t _mainQueue;
  
  dispatch_group_t mainQueueGroup;

  RobotAction *_currentRobotAction;
}

- (void)dealloc {
  dispatch_release(mainQueueGroup);
}

- (instancetype)init {
  self = [super init];
  
  if (self) {
    self.health = ROBOT_INITIAL_LIFES;
    
    _backgroundQueue = dispatch_queue_create("backgroundQueue", DISPATCH_QUEUE_SERIAL);
    _mainQueue = dispatch_queue_create("mainQueue", DISPATCH_QUEUE_SERIAL);
    mainQueueGroup = dispatch_group_create();
  }
  
  return self;
}

- (void)runRobotAction:(CCActionFiniteTime *)action target:(CCNode*)target {
  // ensure that background queue cannot spawn any actions will main queue is operating
  [self waitForMainQueue];

  RobotAction *robotAction = [[RobotAction alloc] init];
  robotAction.target = target;
  robotAction.action = action;
  _currentRobotAction = robotAction;
    
  [robotAction run];
  
  _currentRobotAction = nil;
}

- (void)turnGunLeft:(NSInteger)degree {
  [self waitForMainQueue];

  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)turnGunRight:(NSInteger)degree {
  [self waitForMainQueue];

  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)turnRobotLeft:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];

  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_body];
}


- (void)turnRobotRight:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];
  
  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_body];
}

- (void)moveAhead:(NSInteger)distance {
  [self waitForMainQueue];
  
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CGPoint direction = [self directionFromRotation:_robotNode.rotation];
  CGPoint targetPoint = ccpMult(direction, distance);
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:targetPoint];

  [self runRobotAction:actionMoveBy target:_body];
}


- (void)moveBack:(NSInteger)distance {
  [self waitForMainQueue];
  
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CGPoint direction = [self directionFromRotation:_robotNode.rotation];
  CGPoint targetPoint = ccpMult(direction, -distance);
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:targetPoint];
  
  [self runRobotAction:actionMoveBy target:_body];
}

- (void)waitForMainQueue {
  // ensure that background queue cannot spawn any actions will main queue is operating
  if (dispatch_get_current_queue() == _backgroundQueue) {
    if (mainQueueGroup != NULL) {
      dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
    }
  }
}

- (void)shoot {
  CGFloat combinedRotation = _body.rotation + _barell.rotation;
  CGPoint direction = [self directionFromRotation:(combinedRotation)];
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    [self.gameBoard fireBulletFromPosition:_body.position inDirection:direction bulletOwner:self];
  });
  
  CCActionDelay *delay = [CCActionDelay actionWithDuration:0.5f/GAME_SPEED];
  [self runRobotAction:delay target:_body];
}


- (void)_run {
  dispatch_async(_backgroundQueue, ^{
    [self run];
  });
}

#pragma mark - Info

- (CGPoint)headingDirection {
  return [self directionFromRotation:_body.rotation];
}

#pragma mark - Events

- (void)_scannedRobot:(Robot*)robot atPosition:(CGPoint)position {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    [self scannedRobot:robot atPosition:position];
  });
}

- (void)_hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    // now that action is being executed, check if information about collision is still valid
    RobotWallHitDirection currentWallHitDirection = [self.gameBoard currentWallHitDirectionForRobot:self];
    if (currentWallHitDirection == RobotWallHitDirectionNone || currentWallHitDirection != hitDirection) {
      NSLog(@"Cancel Hit Wall Notification");
      return;
    } else {
      [self hitWall:hitDirection hitAngle:angle];
    }
  });
}

- (void)_gotHit:(Bullet*)bullet {
  self.health--;
  [self updateHealthBar];

  if (self.health <= 0) {
      [self.gameBoard robotDied:self];
  } else {
    [self gotHit:bullet];
  }
}

- (void)cancelActiveAction {
  if (_currentRobotAction != nil) {
    [_currentRobotAction cancel];
  }
}

#pragma mark - Event Handlers

- (void)gotHit:(Bullet*)bullet {};
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {};
- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position {};
- (void)run {};

#pragma mark - UI Updates

- (void)updateHealthBar {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.health > 0) {
      _healthBar.visible = TRUE;
      _healthBar.scaleX = self.health / (ROBOT_INITIAL_LIFES * 1.f);
    } else {
      _healthBar.visible = FALSE;
    }
  });
}

#pragma mark - Utils

- (CGPoint)directionFromRotation:(CGFloat)objectRotation {
  CGFloat rotation = (objectRotation) * (M_PI / 180.f);
  CGFloat x = cos(rotation);
  CGFloat y = sin(rotation);
  
  return ccp(x, (-1)*y);
}

@end
