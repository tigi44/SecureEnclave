//
//  ViewController.m
//  SecureEnclave
//
//  Created by tigi on 2020/04/02.
//  Copyright © 2020 tigi. All rights reserved.
//

#import "ViewController.h"
#import "SecureEnclaveManager.h"
#import "UserDefaultManager.h"
#import "NSData+SecKeyRef.h"


static NSString* const kSecureEnclaveLabel = @"kSecureEnclaveLabel";
static NSString* const kUserDefaultLabel   = @"kUserDefaultLabel";

@interface ViewController ()

@end

@implementation ViewController
{
    UIStackView *mStackView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *sView = self.view;
    
    mStackView = [UIStackView new];
    mStackView.translatesAutoresizingMaskIntoConstraints = NO;
    mStackView.axis = UILayoutConstraintAxisVertical;
    mStackView.distribution = UIStackViewDistributionFillEqually;
    mStackView.alignment = UIStackViewAlignmentFill;
    mStackView.spacing = 10.f;
    [sView addSubview:mStackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [mStackView.centerYAnchor constraintEqualToAnchor:sView.centerYAnchor],
        [mStackView.centerXAnchor constraintEqualToAnchor:sView.centerXAnchor],
        [mStackView.widthAnchor constraintEqualToAnchor:sView.widthAnchor multiplier:0.5f],
        [mStackView.heightAnchor constraintEqualToAnchor:sView.heightAnchor multiplier:0.3f],
    ]];
    
    
    _inputTextField = [UITextField new];
    _inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _inputTextField.layer.borderColor = UIColor.grayColor.CGColor;
    _inputTextField.layer.borderWidth = 0.5f;
    _inputTextField.textAlignment = NSTextAlignmentRight;
    _inputTextField.text = @"test text";
    [mStackView addArrangedSubview:_inputTextField];
    
    
    _generateKeyButton = [UIButton new];
    _generateKeyButton.translatesAutoresizingMaskIntoConstraints = NO;
    _generateKeyButton.backgroundColor = UIColor.grayColor;
    [_generateKeyButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_generateKeyButton setTitle:@"키 생성" forState:UIControlStateNormal];
    [_generateKeyButton addTarget:self action:@selector(tappedGenerateKeyButton:) forControlEvents:UIControlEventTouchUpInside];
    [mStackView addArrangedSubview:_generateKeyButton];
    
    _matchTextButton = [UIButton new];
    _matchTextButton.translatesAutoresizingMaskIntoConstraints = NO;
    _matchTextButton.backgroundColor = UIColor.grayColor;
    [_matchTextButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_matchTextButton setTitle:@"텍스트 매칭" forState:UIControlStateNormal];
    [_matchTextButton addTarget:self action:@selector(tappedMatchingTextButton:) forControlEvents:UIControlEventTouchUpInside];
    [mStackView addArrangedSubview:_matchTextButton];
}


#pragma mark - private


- (void)showAlert:(NSString *)aMessage
{
    UIAlertController *sAlertVC         = [UIAlertController alertControllerWithTitle:nil message:aMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction     *aDefaultAction   = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];

    [sAlertVC addAction:aDefaultAction];
    [self presentViewController:sAlertVC animated:YES completion:nil];
}

#pragma mark - action


- (IBAction)tappedGenerateKeyButton:(id)sender
{
    NSString *sText = self.inputTextField.text;
    
    if (sText.length <= 0)
    {
        [self showAlert:@"Empty the Text"];
        return;
    }
    
    NSError     *sErrorCreateKey = nil;
    SecKeyRef   sPriKeyRef       = NULL;
    [SecureEnclaveManager deleteKeyForLabel:kSecureEnclaveLabel error:nil];
    sPriKeyRef = [SecureEnclaveManager createKeyForLabel:kSecureEnclaveLabel error:&sErrorCreateKey];
    
    if (sErrorCreateKey != NULL)
    {
        [self showAlert:[NSString stringWithFormat:@"Create a Key Error : %@", sErrorCreateKey]];
    }
    else if (sPriKeyRef == NULL)
    {
        [self showAlert:@"Create a Key Error"];
    }
    else
    {
        SecKeyRef   sPublicKey          = SecKeyCopyPublicKey(sPriKeyRef);
        NSData      *sDataToBeEncrypted = [sText dataUsingEncoding:NSUTF8StringEncoding];
        CFErrorRef  sErrorEncryptedData = NULL;
        NSData      *sEncryptedData     = (NSData *)CFBridgingRelease(SecKeyCreateEncryptedData(sPublicKey,
                                                                                                kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA224AESGCM,
                                                                                                (__bridge CFDataRef)sDataToBeEncrypted,
                                                                                                &sErrorEncryptedData));
        
        if (sErrorEncryptedData != NULL)
        {
            [self showAlert:[NSString stringWithFormat:@"Encrypted Error : %@", sErrorEncryptedData]];
        }
        else
        {
            [[UserDefaultManager sharedInstance] saveDataWithKey:kUserDefaultLabel data:sEncryptedData];
            [self showAlert:@"Success Generate a Key"];
        }
    }
}

- (IBAction)tappedMatchingTextButton:(id)sender
{
    NSError     *sErrorReteiveKey = nil;
    SecKeyRef   sPriKeyRef        = NULL;
    NSData      *sEncryptedData   = nil;
    
    sPriKeyRef      = [SecureEnclaveManager retreiveKeyFromLabel:kSecureEnclaveLabel error:&sErrorReteiveKey];
    sEncryptedData  = [[UserDefaultManager sharedInstance] dataWithKey:kUserDefaultLabel];
    
    if (sErrorReteiveKey != NULL)
    {
        [self showAlert:[NSString stringWithFormat:@"Retreive a Key Error : %@", sErrorReteiveKey]];
    }
    else if (sPriKeyRef == NULL || sEncryptedData == nil)
    {
        [self showAlert:@"Retreive a Key Error"];
    }
    else
    {
        NSString *sText = self.inputTextField.text;
        
        if (sText.length <= 0)
        {
            [self showAlert:@"Empty the Text"];
            return;
        }
        
        NSData      *sInputTextData     = [sText dataUsingEncoding:NSUTF8StringEncoding];
        CFErrorRef  sErrorDecryptedData = NULL;
        NSData      *sDecryptedData     = (NSData *)CFBridgingRelease(SecKeyCreateDecryptedData(sPriKeyRef, kSecKeyAlgorithmECIESEncryptionStandardVariableIVX963SHA224AESGCM, (__bridge CFDataRef)sEncryptedData, &sErrorDecryptedData));
        
        if (sErrorDecryptedData != NULL)
        {
            [self showAlert:[NSString stringWithFormat:@"Decrypted Error : %@", sErrorDecryptedData]];
        }
        else
        {
            if ([sDecryptedData isEqualToData:sInputTextData])
            {
                [self showAlert:@"Success matching"];
            }
            else
            {
                [self showAlert:@"Fail matching"];
            }
        }
    }
}

@end
