//
//  LiveRobot.h
//  RobotWar
//
//  Created by Dion Larson on 7/7/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "Robot.h"

typedef NS_ENUM(NSInteger, RobotState) {
  RobotStateFirstMove,
  RobotStateTurnaround,
  RobotStateFiring,
  RobotStateSearching,
  RobotStateScatter,
  RobotStateWaiting
};

@interface LiveRobot : Robot

@property (nonatomic, assign) RobotState currentRobotState;

@end
