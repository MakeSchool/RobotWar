//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"

static CGFloat const ROBOT_DEGREES_PER_SECOND = 60;

@implementation Robot {
    CCNode *_barell;
}

- (void)turnGunLeft:(NSInteger)degree {
    __block BOOL complete = FALSE;
    
    CGFloat currentRotation = _barell.rotation;
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND;
    
    CCActionRotateTo *rotateTo = [CCActionRotateTo actionWithDuration:duration angle:currentRotation-degree];
    CCActionCallBlock *actionCallBlock = [CCActionCallBlock actionWithBlock:^{
        complete = TRUE;
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionOne:rotateTo two:actionCallBlock];
    
    [self runAction:sequence];
    
    while (!complete) {
        
    }
    
    return;
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self turnGunLeft:180];
        NSLog(@"Turn completed");
        
    });
}

@end
