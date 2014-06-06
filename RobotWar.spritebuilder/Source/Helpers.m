//
//  Helpers.c
//  RobotWar
//
//  Created by Benjamin Encz on 05/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Helpers.h"

CGFloat radToDeg(CGFloat rad) {
  return rad * (180/M_PI);
}

CGFloat degToRad(CGFloat deg) {
  return deg * (M_PI/180);
}

RobotWallHitDirection radAngleToRobotWallHitDirection(CGFloat rad) {
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


