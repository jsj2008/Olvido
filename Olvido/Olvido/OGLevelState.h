//
//  OGLevelState.h
//  Olvido
//
//  Created by Алексей Подолян on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>

@class OGGameScene;

@interface OGLevelState : GKState

+ (instancetype)stateWithLevelScene:(OGGameScene *)scene;

@end