//
//  TourneyManagementScene.m
//  RobotWar
//
//  Created by Daniel Haaser on 7/5/14.
//  Copyright (c) 2014 MakeGamesWithUs. All rights reserved.
//

#import "TournamentScene.h"
#import "Robot.h"
#import "MainScene.h"

static NSArray* allRobots;
static NSDictionary* schedule;

static const int COUNTDOWN_TIME = 10;

@implementation TournamentScene
{
    CCLabelTTF* roundLabel;
    CCLabelTTF* robotOneLabel;
    CCLabelTTF* robotTwoLabel;
    CCLabelTTF* countdownLabel;
    
    int countdown;
}

#pragma mark -
#pragma mark Init and Scheduling

- (id)init
{
    if (self = [super init])
    {
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            allRobots = ClassGetSubclasses([Robot class]);
            schedule = [self createTournamentScheduleWithBots:allRobots];
        });
    }
    
    return self;
}

NSArray *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    
    classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do
        {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil)
        {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}

- (NSDictionary*)createTournamentScheduleWithBots:(NSArray*)robots
{
    NSMutableArray* matches = [NSMutableArray arrayWithCapacity:(robots.count / 2) * (robots.count - 1)];
    NSMutableDictionary* records = [NSMutableDictionary dictionaryWithCapacity:robots.count];
    
    int matchNumber = 0;
    
    for (int i = 0; i < robots.count; ++i)
    {
        const char* robotOneClassName = class_getName(robots[i]);
        NSString* robotOneClassString = [NSString stringWithUTF8String:robotOneClassName];
        
        for (int j = i + 1; j < robots.count; ++j)
        {
            const char* robotTwoClassName = class_getName(robots[j]);
            NSString* robotTwoClassString = [NSString stringWithUTF8String:robotTwoClassName];
            
            NSDictionary* match = @{@"Match": @(matchNumber),
                                    @"RobotOne": robotOneClassString,
                                    @"RobotTwo": robotTwoClassString,
                                    @"Winner": @""};
            
            [matches addObject:match];
            
            ++matchNumber;
        }
        
        //TODO: Add record (win, loss draw) entry for each bot
        NSDictionary* record = @{@"Wins": @(0), @"Losses": @(0), @"Draws": @(0)};
        [records addObject:record forKey:robotOneClassName];
    }
    
    return @{@"Matches": matches, @"CurrentMatch": @(-1), @"Records": records};
}

#pragma mark -
#pragma mark Tournament Stuff

- (void)didLoadFromCCB
{

}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self incrementMatchNumber];
    
    [self updateLabels];
    
    countdown = COUNTDOWN_TIME;
    [self schedule:@selector(updateCountdown) interval:1.0f];
}

- (void)cleanup
{
    [self unschedule:@selector(updateCountdown)];
}

- (void)incrementMatchNumber
{
    int nextMatchNumber = [[schedule objectForKey:@"CurrentMatch"] intValue] + 1;
    NSArray* matches = [schedule objectForKey:@"Matches"];
    
    if (nextMatchNumber >= matches.count)
    {
        // Load Tournament Winner Screen
    }
    else
    {
        NSMutableDictionary* scheduleCopy = [NSMutableDictionary dictionaryWithDictionary:schedule];
        [scheduleCopy setObject:@(nextMatchNumber) forKey:@"CurrentMatch"];
        schedule = [NSDictionary dictionaryWithDictionary:scheduleCopy];
    }
    
    // TODO: Save state down to disk
}

- (void)updateCountdown
{
    --countdown;
    countdownLabel.string = [NSString stringWithFormat:@"%d", countdown];
    
    if (countdown <= 0)
    {
        [self unschedule:@selector(updateCountdown)];
        [self loadNextMatch];
    }
}

- (void)updateLabels
{
    int matchNumber = [[schedule objectForKey:@"CurrentMatch"] intValue];
    NSArray* matches = [schedule objectForKey:@"Matches"];
    NSDictionary* match = matches[matchNumber];
    
    robotOneLabel.string = [match objectForKey:@"RobotOne"];
    robotTwoLabel.string = [match objectForKey:@"RobotTwo"];
    
    roundLabel.string = [NSString stringWithFormat:@"Round %d", matchNumber];
}

- (void)loadNextMatch
{
    int matchNumber = [[schedule objectForKey:@"CurrentMatch"] intValue];
    NSArray* matches = [schedule objectForKey:@"Matches"];
    NSDictionary* match = matches[matchNumber];
    
    MainScene* nextMatch = (MainScene*) [CCBReader load:@"MainScene"];
    
    // TODO: Randomize Positions
    [nextMatch initWithRobotClassOne: [match objectForKey:@"RobotOne"] andRobotClassTwo:[match objectForKey:@"RobotTwo"]];
    
    CCScene* nextMatchScene = [CCScene node];
    [nextMatchScene addChild:nextMatch];
    [[CCDirector sharedDirector] pushScene:nextMatchScene];
}

@end
