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
#import "Helpers.h"

@interface Robot ()

@property (nonatomic, assign) NSInteger health;

@end

@implementation Robot {
  CCNode *_barrel;
  CCNode *_body;
  CCNode *_healthBar;
  CCNodeColor *_bodyColorNode;
  
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

- (void)_setRobotColor:(CCColor*)color {
  [_bodyColorNode setColor:color];
}

- (void)runRobotAction:(CCActionFiniteTime *)action target:(CCNode*)target canBeCancelled:(BOOL)canBeCancelled {
  // ensure that background queue cannot spawn any actions will main queue is operating
  [self waitForMainQueue];

  RobotAction *robotAction = [[RobotAction alloc] init];
  robotAction.target = target;
  robotAction.action = action;
  robotAction.canBeCancelled = canBeCancelled;
  _currentRobotAction = robotAction;
    
  [robotAction run];
  
  _currentRobotAction = nil;
}

- (void)turnGunLeft:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];

  CGFloat currentRotation = _barrel.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_barrel canBeCancelled:TRUE];
}

- (void)turnGunRight:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];

  CGFloat currentRotation = _barrel.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_barrel canBeCancelled:TRUE];
}

- (void)turnRobotLeft:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];

  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
  
  [self runRobotAction:rotateTo target:_body canBeCancelled:TRUE];
}


- (void)turnRobotRight:(NSInteger)degree {
  NSAssert(degree >= 0, @"No negative values allowed!");
  [self waitForMainQueue];
  
  CGFloat currentRotation = _body.rotation;
  CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
  CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation+degree];
  
  [self runRobotAction:rotateTo target:_body canBeCancelled:TRUE];
}

- (void)moveAhead:(NSInteger)distance {
  NSAssert(distance >= 0, @"No negative values allowed!");
  [self waitForMainQueue];
  
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CGPoint direction = [self directionFromRotation:_robotNode.rotation];
  CGPoint targetPoint = ccpMult(direction, distance);
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:targetPoint];

  [self runRobotAction:actionMoveBy target:_body canBeCancelled:TRUE];
}


- (void)moveBack:(NSInteger)distance {
  NSAssert(distance >= 0, @"No negative values allowed!");
  [self waitForMainQueue];
  
  CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
  CGPoint direction = [self directionFromRotation:_robotNode.rotation];
  CGPoint targetPoint = ccpMult(direction, -distance);
  CCActionMoveBy *actionMoveBy = [CCActionMoveBy actionWithDuration:duration position:targetPoint];
  
  [self runRobotAction:actionMoveBy target:_body canBeCancelled:TRUE];
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
  CGPoint direction = [self gunHeadingDirection];
  
  void (^fireAction)() = ^void() {
    [self.gameBoard fireBulletFromPosition:_body.position inDirection:direction bulletOwner:self];
  };
  
  
  if ([NSThread isMainThread])
  {
    fireAction();
  }
  else
  {
    dispatch_sync(dispatch_get_main_queue(), fireAction);
  }
  
  CCActionDelay *delay = [CCActionDelay actionWithDuration:1.f/GAME_SPEED];
  [self runRobotAction:delay target:_body canBeCancelled:FALSE];
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

- (CGFloat)angleBetweenHeadingDirectionAndWorldPosition:(CGPoint)position {
  // vector between robot position and target position
  CGPoint directionVector = ccp(position.x - _body.position.x, position.y - _body.position.y);
  CGPoint currentHeading = [self headingDirection];
  
  CGFloat angle = roundf(radToDeg(ccpAngleSigned(directionVector, currentHeading)));
  
  return angle;
}

- (CGPoint)gunHeadingDirection {
  CGFloat combinedRotation = _body.rotation + _barrel.rotation;
  CGPoint direction = [self directionFromRotation:(combinedRotation)];
  
  return direction;
}

- (CGFloat)angleBetweenGunHeadingDirectionAndWorldPosition:(CGPoint)position {
  // vector between robot position and target position
  CGPoint directionVector = ccp(position.x - _body.position.x, position.y - _body.position.y);
  CGPoint currentHeading = [self gunHeadingDirection];
  
  CGFloat angle = roundf(radToDeg(ccpAngleSigned(directionVector, currentHeading)));
  
  return angle;
}

- (CGFloat)currentTimestamp {
  return self.gameBoard.currentTimestamp;
}

- (CGSize)arenaDimensions {
  return [self.gameBoard dimensions];
}

- (CGRect)robotBoundingBox {
  return self.robotNode.boundingBox;
}

- (CGPoint)position {
  return self.robotNode.position;
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
//      CCLOG(@"Cancel Hit Wall Notification");
      return;
    } else {
      [self hitWall:hitDirection hitAngle:angle];
    }
  });
}

- (void)_gotHit {
  self.health--;
  [self updateHealthBar];

  if (self.health <= 0) {
      [self.gameBoard robotDied:self];
  } else {
    dispatch_group_async(mainQueueGroup, _mainQueue, ^{
      [self gotHit];
    });
  }
}

- (void)_bulletHitEnemy:(Bullet*)bullet {
  dispatch_group_async(mainQueueGroup, _mainQueue, ^{
    [self bulletHitEnemy:bullet];
  });
}

- (void)cancelActiveAction {
  if (_currentRobotAction != nil) {
    [_currentRobotAction cancel];
  }
}

#pragma mark - Event Handlers

- (void)gotHit{};
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {};
- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position {};
- (void)run {};
- (void)bulletHitEnemy:(Bullet *)bullet {}

#pragma mark - UI Updates

- (void)updateHealthBar {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.health > 0) {
      _healthBar.visible = TRUE;
      _healthBar.scaleX = self.health / (ROBOT_INITIAL_LIFES * 1.f);
    
        if (self.health >= ROBOT_INITIAL_LIFES * 3 / 4) {
            _healthBar.color = [CCColor colorWithCcColor3b:ccc3(170, 255, 151)];
        } else if (self.health >= ROBOT_INITIAL_LIFES * 2 / 4) {
            _healthBar.color = [CCColor colorWithCcColor3b:ccc3(255, 249, 149)];
        } else if (self.health >= ROBOT_INITIAL_LIFES * 1 / 4) {
            _healthBar.color = [CCColor colorWithCcColor3b:ccc3(255, 190, 138)];
        } else {
            _healthBar.color = [CCColor colorWithCcColor3b:ccc3(255, 121, 127)];
        }
        
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

- (Robot*)copyWithZone:(NSZone *)zone {
  Robot *newRobot = [[[self class] allocWithZone:zone] init];
  newRobot->_creator = [_creator copyWithZone:zone];
  newRobot->_robotClass = [_robotClass copyWithZone:zone];
  
  return newRobot;
}

@end
