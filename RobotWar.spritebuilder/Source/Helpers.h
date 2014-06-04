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

CGFloat radToDeg(CGFloat rad) {
  return rad * (180/M_PI);
}

CGFloat degToRad(CGFloat deg) {
  return deg * (M_PI/180);
}

RobotWallHitDirection radAngleToRobotWallHitDirection(CGFloat rad) {
  if (rad >= 226 && rad <= 315) {
    return RobotWallHitDirectionRight;
  } else if (rad >= 136 && rad <= 225) {
    return RobotWallHitDirectionFront;
  } else if  (rad >= 46 && rad <= 135){
    return RobotWallHitDirectionLeft;
  } else  {
    return RobotWallHitDirectionRear;
  }
}

#endif
