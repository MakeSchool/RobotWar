//
//  NewAdvancedRobot.h
//  RobotWar
//
//  Created by Dion Larson on 7/6/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "Robot.h"

typedef NS_ENUM(NSInteger, RobotState) {
  RobotStateDefault,
  RobotStateTurnaround,
  RobotStateFiring,
  RobotStateSearching
};

@interface NewAdvancedRobot : Robot

@property (nonatomic, assign) RobotState currentRobotState;

@end
