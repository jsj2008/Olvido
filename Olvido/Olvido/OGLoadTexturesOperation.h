//
//  OGLoadTexturesOperation.h
//  Olvido
//
//  Created by Алексей Подолян on 11/23/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGLoadTexturesOperation : NSOperation

+ (instancetype)loadTexturesOperationWithUnitName:(NSString *)unitName atlasName:(NSString *)atlasName;

@end
