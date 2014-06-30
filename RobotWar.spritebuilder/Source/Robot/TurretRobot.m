//
//  TurretRobot.m
//  RobotWar
//
//  Created by Daniel Haaser on 6/27/14.
//  Copyright (c) 2014 MakeGamesWith.Us. All rights reserved.
//

#import "TurretRobot.h"


typedef NS_ENUM(NSInteger, TurretState) {
    kTurretStateScanning,
    kTurretStateFiring
};

static const float GUN_ANGLE_TOLERANCE = 2.0f;

@implementation TurretRobot {
    TurretState _currentState;
    
    float _timeSinceLastEnemyHit;
}

- (id)init {
    if (self = [super init]) {
        _currentState = kTurretStateScanning;
    }
    
    return self;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    
    // Calculate the angle between the turret and the enemy
    float angleBetweenTurretAndEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:position];
    
//    CCLOG(@"Enemy Position: (%f, %f)", position.x, position.y);
//    CCLOG(@"Enemy Spotted at Angle: %f", angleBetweenTurretAndEnemy);
    
    if (angleBetweenTurretAndEnemy > GUN_ANGLE_TOLERANCE) {
        [self cancelActiveAction];
        [self turnGunRight:abs(angleBetweenTurretAndEnemy)];
    }
    else if (angleBetweenTurretAndEnemy < -GUN_ANGLE_TOLERANCE) {
        [self cancelActiveAction];
        [self turnGunLeft:abs(angleBetweenTurretAndEnemy)];
    }
    
    _timeSinceLastEnemyHit = self.currentTimestamp;
    _currentState = kTurretStateFiring;
}

- (void)run {
    while (true) {
        switch (_currentState) {
            case kTurretStateScanning:
                [self turnGunRight:90];
                break;
                
            case kTurretStateFiring:
                if (self.currentTimestamp - _timeSinceLastEnemyHit > 2.5f) {
                    [self cancelActiveAction];
                    _currentState = kTurretStateScanning;
                } else {
                    [self shoot];
                }
                break;
        }
    }
}

- (void)_bulletHitEnemy:(Bullet*)bullet {
    _timeSinceLastEnemyHit = self.currentTimestamp;
}

@end
