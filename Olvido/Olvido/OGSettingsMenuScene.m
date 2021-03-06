//
//  OGSettingsMenuScene.m
//  Olvido
//
//  Created by Александр Песоцкий on 10/27/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGSettingsMenuScene.h"
#import "OGLevelManager.h"
#import "OGConstants.h"
#import "OGButtonNode.h"
#import "OGMenuManager.h"

NSString *const kOGSettingsMenuSceneMainMenuButtonNodeName = @"MainMenuButton";

@implementation OGSettingsMenuScene

- (void)onButtonClick:(OGButtonNode *)button
{
    [super onButtonClick:button];
    
    if ([button.name isEqualToString:kOGSettingsMenuSceneMainMenuButtonNodeName])
    {
        [self.menuManager loadMenuWithName:kOGMainMenuName];
    }
}

@end
