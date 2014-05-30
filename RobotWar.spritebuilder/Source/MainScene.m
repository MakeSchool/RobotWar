//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Robot.h"
#import "BasicRobot.h"

@implementation MainScene {
  Robot *robot1;
  Robot *robot2;
  dispatch_queue_t robot1Queue;
  dispatch_queue_t robot2Queue;
}

- (void)dealloc {
  dispatch_release(robot1Queue);
}

- (void)didLoadFromCCB {
  // intantiate two AIs
  robot1 = [[BasicRobot alloc]init];
  robot2 = [[BasicRobot alloc]init];

  // create a dispatch queue for each robot
  robot1Queue = dispatch_queue_create("robot1Queue", DISPATCH_QUEUE_SERIAL);
  robot2Queue = dispatch_queue_create("robot2Queue", DISPATCH_QUEUE_SERIAL);

  //spawn two robots
  CCNode *robotNode1 = [CCBReader load:@"Robot" owner:robot1];
  CCNode *robotNode2 = [CCBReader load:@"Robot" owner:robot2];

  robotNode1.position = ccp(50,50);
  robot1.basicMovementQueue = robot1Queue;
  robot1.eventResponseQueue = dispatch_queue_create("robot1EventResponseQueue", DISPATCH_QUEUE_SERIAL);
  [self addChild:robotNode1];

  robotNode2.position = ccp(200,200);
  robot2.basicMovementQueue = robot2Queue;
  robot2.eventResponseQueue = dispatch_queue_create("robot2EventResponseQueue", DISPATCH_QUEUE_SERIAL);
  [self addChild:robotNode2];

  // if queue is empty call performAction, otherwise not
  dispatch_async(robot1Queue, ^{
    [robot1 run];
  });
  
  dispatch_async(robot2Queue, ^{
    [robot2 run];
  });
  
  [self performSelector:@selector(enemyDetected) withObject:nil afterDelay:1.f];
}

- (void)enemyDetected {
  // on event call handler with high priority
  [robot1 scannedRobot];
}

@end
