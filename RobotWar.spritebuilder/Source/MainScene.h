//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol GameBoard <NSObject>

// direction should be normalized
- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction;

@end

@interface MainScene : CCNode <GameBoard>

@end
