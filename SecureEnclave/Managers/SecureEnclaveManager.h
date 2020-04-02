//
//  SecureEnclaveManager.h
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecureEnclaveManager : NSObject

+ (SecKeyRef)createKeyForLabel:(NSString *)aLabel error:(NSError **_Nullable)aError;
+ (SecKeyRef)retreiveKeyFromLabel:(NSString *)aLabel error:(NSError **_Nullable)aError;
+ (void)deleteKeyForLabel:(NSString *)aLabel error:(NSError **_Nullable)aError;

@end

NS_ASSUME_NONNULL_END
