//
//  OGSceneManagerDelegate.h
//  Olvido
//
//  Created by Алексей Подолян on 11/8/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>

@class OGSceneManager;

@protocol OGSceneManagerDelegate <NSObject>

- (void)sceneManager:(OGSceneManager *)sceneManager didTransitionToScene:(SKScene *)scene;

@end
