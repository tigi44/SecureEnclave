//
//  UserDefaultManager.m
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import "UserDefaultManager.h"

static UserDefaultManager *sharedInstance = nil;
static NSString* const kUserDefaultManagerName = @"kUserDefaultManagerName";

@implementation UserDefaultManager
{
    NSUserDefaults *mUserDefault;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [UserDefaultManager new];
    });
    
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        mUserDefault = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultManagerName];
    }
    return self;
}


- (NSData *)dataWithKey:(NSString *)aKey
{
    return [mUserDefault objectForKey:aKey];
}

- (void)saveDataWithKey:(NSString *)aKey data:(NSData *)aData
{
    [mUserDefault setObject:aData forKey:aKey];
}


- (void)deleteDataWithKey:(NSString *)aKey
{
    [mUserDefault removeObjectForKey:aKey];
}

@end
