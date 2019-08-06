//
//  keyNoteSMTPMessage.h
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <CFNetwork/CFNetwork.h>
#import <UIKit/UIKit.h>
enum
{
    kkeyNoteSMTPIdle = 0,
    kkeyNoteSMTPConnecting,
    kkeyNoteSMTPWaitingEHLOReply,
    kkeyNoteSMTPWaitingTLSReply,
    kkeyNoteSMTPWaitingLOGINUsernameReply,
    kkeyNoteSMTPWaitingLOGINPasswordReply,
    kkeyNoteSMTPWaitingAuthSuccess,
    kkeyNoteSMTPWaitingFromReply,
    kkeyNoteSMTPWaitingToReply,
    kkeyNoteSMTPWaitingForEnterMail,
    kkeyNoteSMTPWaitingSendSuccess,
    kkeyNoteSMTPWaitingQuitReply,
    kkeyNoteSMTPMessageSent
};
typedef NSUInteger keyNoteSMTPState;

// Message part keys
extern NSString *kkeyNoteSMTPPartContentDispositionKey;
extern NSString *kkeyNoteSMTPPartContentTypeKey;
extern NSString *kkeyNoteSMTPPartMessageKey;
extern NSString *kkeyNoteSMTPPartContentTransferEncodingKey;

// Error message codes
#define kkeyNoteSMPTErrorConnectionTimeout -5
#define kkeyNoteSMTPErrorConnectionFailed -3
#define kkeyNoteSMTPErrorConnectionInterrupted -4
#define kkeyNoteSMTPErrorUnsupportedLogin -2
#define kkeyNoteSMTPErrorTLSFail -1
#define kkeyNoteSMTPErrorNonExistentDomain 1
#define kkeyNoteSMTPErrorInvalidUserPass 535
#define kkeyNoteSMTPErrorInvalidMessage 550
#define kkeyNoteSMTPErrorNoRelay 530

@class keyNoteSMTPMessage;

@protocol keyNoteSMTPMessageDelegate
@required

-(void)messageSent:(keyNoteSMTPMessage *)message;
-(void)messageFailed:(keyNoteSMTPMessage *)message error:(NSError *)error;

@end

@interface AddressData : NSObject <NSCopying, NSStreamDelegate>

@property(nonatomic, strong) NSString *login;
@property(nonatomic, strong) NSString *pass;
@property(nonatomic, strong) NSString *relayHost;

@property(nonatomic, strong) NSArray *relayPorts;
@property(nonatomic, assign) BOOL requiresAuth;
@property(nonatomic, assign) BOOL wantsSecure;
@property(nonatomic, assign) BOOL validateSSLChain;

@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *keyNote;
@property(nonatomic, strong) NSString *ccEmail;
@property(nonatomic, strong) NSString *bccEmail;
@property(nonatomic, strong) NSArray *parts;

@property(nonatomic, assign) NSTimeInterval connectTimeout;

@property(nonatomic, weak) id <keyNoteSMTPMessageDelegate> delegate;

- (BOOL)send;

@end
