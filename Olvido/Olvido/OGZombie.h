//
//  OGZombieMan.h
//  Olvido
//
//  Created by Александр Песоцкий on 11/21/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGEnemyEntity.h"
#import "OGResourceLoadable.h"

@interface OGZombie : OGEnemyEntity <OGResourceLoadable>

+ (NSDictionary *)sOGZombieAnimations;

@end
