//
//  OGMenuManager.h
//  Olvido
//
//  Created by Алексей Подолян on 11/11/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAudioManager.h"

@class OGSceneManager;
@class OGLevelManager;

@interface OGMenuManager : NSObject

@property (nonatomic, strong) OGSceneManager *sceneManager;
@property (nonatomic, strong) OGAudioManager *audioManager;
@property (nonatomic, weak) OGLevelManager *levelManager;

+ (instancetype)menuManager;

- (void)loadMainMenu;

- (void)loadMenuWithIdentifier:(NSUInteger)menuIdentifier;

- (void)loadMenuWithName:(NSString *)menuName;

@end
