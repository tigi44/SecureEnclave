//
//  SecureEnclaveManager.m
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import "SecureEnclaveManager.h"

static NSString *const kSecureEnclaveAppLabel = @"kSecureEnclaveAppLabel";

@implementation SecureEnclaveManager

+ (SecKeyRef)createKeyForLabel:(NSString *)aLabel error:(NSError **_Nullable)aError
{
    SecAccessControlRef sSecureEnclaveAccessControlRef =
    SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    kSecAccessControlPrivateKeyUsage,
                                    NULL);

    NSDictionary* attributes = @{
        (id)kSecAttrKeyType:       (id)kSecAttrKeyTypeECSECPrimeRandom,
        (id)kSecAttrKeySizeInBits: @256,
        (id)kSecAttrTokenID:       (id)kSecAttrTokenIDSecureEnclave,
        (id)kSecAttrLabel:         aLabel,
        (id)kSecPrivateKeyAttrs:   @{
                (id)kSecAttrIsPermanent:    @YES,
                (id)kSecAttrApplicationTag: kSecureEnclaveAppLabel,
                (id)kSecAttrAccessControl:  (__bridge id)sSecureEnclaveAccessControlRef
        }
    };
    
    CFErrorRef sErrorCreateKey = NULL;
    SecKeyRef  sPrivateKey     = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &sErrorCreateKey);
    
    if (sErrorCreateKey)
    {
        sPrivateKey = NULL;
        
        *aError = CFBridgingRelease(sErrorCreateKey);
    }
    
    return sPrivateKey;
}

+ (SecKeyRef)retreiveKeyFromLabel:(NSString *)aLabel error:(NSError **_Nullable)aError
{
    SecAccessControlRef sSecureEnclaveAccessControlRef =
    SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    kSecAccessControlPrivateKeyUsage,
                                    NULL);

    
    NSDictionary *sSearchQuery = @{
        (id)kSecClass:              (id)kSecClassKey,
        (id)kSecAttrKeySizeInBits:  @256,
        (id)kSecAttrApplicationTag: kSecureEnclaveAppLabel,
        (id)kSecAttrKeyType:        (id)kSecAttrKeyTypeECSECPrimeRandom,
        (id)kSecAttrTokenID:        (id)kSecAttrTokenIDSecureEnclave,
        (id)kSecAttrLabel:          aLabel,
        (id)kSecReturnRef:          @YES,
        (id)kSecAttrAccessControl : (__bridge id)sSecureEnclaveAccessControlRef
    };
         
    SecKeyRef sPrivateKey  = NULL;
    OSStatus  sResult      = SecItemCopyMatching((__bridge CFDictionaryRef)sSearchQuery, (CFTypeRef *)&sPrivateKey);
    
    if (sResult != errSecSuccess)
    {
        sPrivateKey = NULL;
        
        *aError = [NSError errorWithDomain:NSOSStatusErrorDomain code:sResult userInfo:@{
            @"localizedDescription" : @"failed to retreive Key.",
            @"osstatus" : @(sResult)
        }];
    }
    
    return sPrivateKey;
}

+ (void)deleteKeyForLabel:(NSString *)aLabel error:(NSError **_Nullable)aError
{
    SecAccessControlRef sSecureEnclaveAccessControlRef =
    SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    kSecAccessControlPrivateKeyUsage,
                                    NULL);
       
    NSDictionary *sSearchQuery = @{
        (id)kSecClass:                (id)kSecClassKey,
        (id)kSecAttrApplicationTag:   kSecureEnclaveAppLabel,
        (id)kSecAttrLabel:            aLabel,
        (id)kSecAttrKeyType:          (id)kSecAttrKeyTypeECSECPrimeRandom,
        (id)kSecAttrTokenID:          (id)kSecAttrTokenIDSecureEnclave,
        (id)kSecReturnRef:            @YES,
        (id)kSecAttrAccessControl:    (__bridge id)sSecureEnclaveAccessControlRef
    };
   
    OSStatus sResult = SecItemDelete((__bridge CFDictionaryRef)sSearchQuery);
       
    if (!(sResult == errSecSuccess || sResult == errSecItemNotFound))
    {
        *aError = [NSError errorWithDomain:NSOSStatusErrorDomain code:sResult userInfo:@{
            @"localizedDescription" : @"failed to delete Key.",
            @"osstatus" : @(sResult)
        }];
    }
}

@end
