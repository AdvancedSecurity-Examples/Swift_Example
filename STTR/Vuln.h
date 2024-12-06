//
//  ObjC.h
//  STTR
//
//  Created by Logan Keim on 6/24/21.
//
#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//defines an interface to implement in vuln.m
@interface Vuln : NSObject

//defines the necessary functions
- (void) trustCerts;
- (void) unsecureDownload;
@end
