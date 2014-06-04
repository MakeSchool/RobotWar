//
//  Helpers.h
//  RobotWar
//
//  Created by Benjamin Encz on 04/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef RobotWar_Helpers_h
#define RobotWar_Helpers_h

#import "Robot.h"

static CGFloat radToDeg(CGFloat rad) {
  return rad * (180/M_PI);
}

static CGFloat degToRad(CGFloat deg) {
  return deg * (M_PI/180);
}

static RobotWallHitDirection radAngleToRobotWallHitDirection(CGFloat rad) {
  if (rad >= -135 && rad <= -46) {
    return RobotWallHitDirectionLeft;
  } else if ((rad >= 136 && rad <= 180) || (rad >= -180 && rad <= -136)) {
    return RobotWallHitDirectionFront;
  } else if  (rad >= 46 && rad <= 135){
    return RobotWallHitDirectionRight;
  } else  {
    return RobotWallHitDirectionRear;
  }
}

#endif
