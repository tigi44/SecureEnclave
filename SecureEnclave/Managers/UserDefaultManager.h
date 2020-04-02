//
//  UserDefaultManager.h
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultManager : NSObject

+ (instancetype)sharedInstance;

- (NSData *)dataWithKey:(NSString *)aKey;
- (void)saveDataWithKey:(NSString *)aKey data:(NSData *)aData;
- (void)deleteDataWithKey:(NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
