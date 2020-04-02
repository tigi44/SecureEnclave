//
//  NSData+SecKeyRef.h
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (SecKeyRef)

+ (NSData *)dataFromKey:(SecKeyRef)aKeyRef;

@end

NS_ASSUME_NONNULL_END
