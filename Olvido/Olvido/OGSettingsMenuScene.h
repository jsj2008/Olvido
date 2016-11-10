//
//  OGSettingsMenuScene.h
//  Olvido
//
//  Created by Александр Песоцкий on 10/27/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "OGBaseScene.h"

@interface OGSettingsMenuScene : OGBaseScene

- (void)activateDrag;
- (void)activateTapContinue;
- (void)activateTapStop;

- (void)changeGodMode;

@end
