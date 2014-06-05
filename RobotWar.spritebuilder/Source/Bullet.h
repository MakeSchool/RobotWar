//
//  Bullet.h
//  RobotWar
//
//  Created by Benjamin Encz on 02/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNodeColor.h"

@class Robot;

@interface Bullet : CCNodeColor

@property (nonatomic, weak) Robot *bulletOwner;

@end
