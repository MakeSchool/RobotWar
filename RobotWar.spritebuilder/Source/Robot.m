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
  if (dispatch_get_current_queue() == _backgroundQueue) {
    if (mainQueueGroup != NULL) {
      dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
    }
  }
  
  RobotAction *robotAction = [[RobotAction alloc] init];
  robotAction.target = target;
  robotAction.action = action;
  _currentRobotAction = robotAction;
  
  [robotAction run];
  
  _currentRobotAction = nil;
}

- (void)turnGunLeft:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)turnGunRight:(NSInteger)degree {
  CGFloat currentRotation = _barell.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_barell];
}

- (void)turnRobotLeft:(NSInteger)degree {
  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_body];
}


- (void)turnRobotRight:(NSInteger)degree {
  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_body];
}

- (void)moveAhead:(NSInteger)distance {
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:ccp(0, distance)];
  
  [self runRobotAction:actionMoveBy target:_body];
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

- (void)moveBack:(NSInteger)distance {
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:ccp(0, -distance)];
  
  [self runRobotAction:actionMoveBy target:_body];
}

- (void)_run {
  dispatch_async(_backgroundQueue, ^{
    [self run];
  });
}

#pragma mark - Events

- (void)_scannedRobot {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
        [_currentRobotAction cancel];
    }
    
    [self scannedRobot];
  });
}

- (void)_hitWall {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    if (_currentRobotAction != nil) {
        [_currentRobotAction cancel];
    }
    
    [self hitWall];
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

#pragma mark - Event Handlers

- (void)gotHit:(Bullet *)bullet {};
- (void)hitWall {};
- (void)scannedRobot {};
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
