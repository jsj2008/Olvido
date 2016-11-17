//
//  OGGameScene.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "OGBaseScene.h"
#import "OGTransitionComponentDelegate.h"
#import "OGEntityManaging.h"

@protocol OGGameSceneDelegate <NSObject>

- (void)gameSceneDidCallFinish;
- (void)gameSceneDidCallRestart;

@end

@interface OGGameScene : OGBaseScene <SKPhysicsContactDelegate, OGTransitionComponentDelegate, OGEntityManaging>

@property (nonatomic, copy) NSNumber *identifier;
@property (nonatomic, weak) id<OGGameSceneDelegate> sceneDelegate;

- (void)pause;

- (void)restart;

- (void)resume;

- (void)pauseWithPauseScreen;

- (void)gameOver;

- (void)runStoryConclusion;

@end
