//
//  OGLevelManager.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGLevelManager.h"
#import "OGGameScene.h"
#import "OGStoryScene.h"
#import "OGConstants.h"
#import "OGsceneManager.h"

#import "OGPauseLevelState.h"
#import "OGGameLevelState.h"

NSString *const kOGLevelManagerGameSceneIdentifierKey = @"GameSceneIdentifier";
NSString *const kOGLevelManagerStorySceneIdentifierKey = @"StorySceneIdentifier";
NSString *const kOGLevelManagerLevelMapName = @"LevelsMap";

@interface OGLevelManager () <OGGameSceneDelegate, OGGameSceneStoryDelegate>

@property (nonatomic, copy, readwrite) NSArray<NSDictionary *> *levelMap;
@property (nonatomic, copy, readwrite) NSString *currentSceneName;

@property (nonatomic, strong) NSNumber *currentStorySceneIdentifier;
@property (nonatomic, strong) NSNumber *currentGameSceneIdentifier;

@property (nonatomic, strong) OGGameScene *currentGameScene;
@property (nonatomic, strong) OGStoryScene *currentStoryScene;

@end

@implementation OGLevelManager

+ (instancetype)levelManager;
{
    OGLevelManager *levelManager = [[OGLevelManager alloc] init];
    [levelManager loadLevelMap];
    
    return levelManager;
}

- (void)loadLevelMap
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kOGLevelManagerLevelMapName
                                                          ofType:kOGPropertyFileExtension];
    
    NSArray *plistData = [NSArray arrayWithContentsOfFile:plistPath];
    
    self.levelMap = plistData;
}

#pragma mark - GameSceneDelegate methods

- (void)gameSceneDidCallFinish
{
    [NSException raise:NSInternalInconsistencyException
                format:@"Not implemented %@", NSStringFromSelector(_cmd)];
}

- (void)gameSceneDidCallRestart
{
    [self loadLevelWithIdentifier:self.currentGameSceneIdentifier];
    [self runGameScene];
}

#pragma mark - GameSceneStoreDelegate method

- (void)storySceneDidCallFinish
{
    [self runGameScene];
}

#pragma mark - Loading and Running levels

- (void)runGameScene
{
    if (self.currentGameSceneIdentifier)
    {
        [self.sceneManager transitionToSceneWithIdentifier:self.currentGameSceneIdentifier.integerValue
                                         completionHandler:^(OGBaseScene *scene)
         {
             self.currentGameScene = (OGGameScene *)scene;
             self.currentGameScene.sceneDelegate = self;
         }];
    }
}

- (void)runStoryScene
{
    if (self.currentStorySceneIdentifier)
    {
        [self.sceneManager transitionToSceneWithIdentifier:self.currentStorySceneIdentifier.integerValue
                                         completionHandler:^(OGBaseScene *scene)
         {
             self.currentStoryScene = (OGStoryScene *)scene;
             self.currentStoryScene.sceneDelegate = self;
         }];
        
        [self.sceneManager prepareSceneWithIdentifier:self.currentGameSceneIdentifier.integerValue];
    }
    else
    {
        [self runGameScene];
    }
}

- (void)loadLevelWithIdentifier:(NSNumber *)identifier
{
    self.currentGameSceneIdentifier = self.levelMap[identifier.integerValue][kOGLevelManagerGameSceneIdentifierKey];
    self.currentStorySceneIdentifier = self.levelMap[identifier.integerValue][kOGLevelManagerStorySceneIdentifierKey];
    
    [self runStoryScene];
}

- (void)pause
{
    if (self.currentGameScene)
    {
        [self.currentGameScene.stateMachine enterState:OGPauseLevelState.self];
    }
}

- (void)resume
{
    if (self.currentGameScene)
    {
        [self.currentGameScene.stateMachine enterState:OGGameLevelState.self];
    }
}

@end
