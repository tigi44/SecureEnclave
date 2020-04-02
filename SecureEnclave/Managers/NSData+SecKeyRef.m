//
//  NSData+SecKeyRef.m
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import "NSData+SecKeyRef.h"


@implementation NSData (SecKeyRef)

+ (NSData *)dataFromKey:(SecKeyRef)aKeyRef
{
    NSData *sResult;
    CFErrorRef sErrorRef;
    
    if (@available(iOS 10.0, *)) {
        CFDataRef sData = SecKeyCopyExternalRepresentation(aKeyRef, &sErrorRef);
        sResult = (__bridge NSData *)sData;
    } else {
        sResult = nil;
    }
    
    return sResult;
}

@end
