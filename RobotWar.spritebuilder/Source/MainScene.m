//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Robot.h"

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
  robot1 = [[Robot alloc]init];
  robot2 = [[Robot alloc]init];

  // create a dispatch queue for each robot
  robot1Queue = dispatch_queue_create("robot1Queue", DISPATCH_QUEUE_SERIAL);
  robot2Queue = dispatch_queue_create("robot2Queue", DISPATCH_QUEUE_SERIAL);

  //spawn two robots
  CCNode *robotNode1 = [CCBReader load:@"Robot" owner:robot1];
  CCNode *robotNode2 = [CCBReader load:@"Robot" owner:robot2];

  robotNode1.position = ccp(50,50);
  robot1.operationQueue = robot1Queue;
  [self addChild:robotNode1];

  robotNode2.position = ccp(200,200);
  robot2.operationQueue = robot2Queue;
  [self addChild:robotNode2];
}

- (void)update:(CCTime)delta {
  dispatch_async(robot1Queue, ^{
    [robot1 performAction];
  });

  dispatch_async(robot2Queue, ^{
    [robot2 performAction];
  });
}

@end
