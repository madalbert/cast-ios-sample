// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import <GCKFramework/GCKFramework.h>

@class GCKContext;
@class GCKDevice;
@class GCKDeviceManager;

// Application stores Cast-related context, device managers, and media metadata.
@interface GCKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *mediaContent;
@property (nonatomic, strong) NSString *mediaTitle;
@property (nonatomic, strong, readwrite) GCKContext *mContext;
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) GCKDevice *mDevice;
@property (nonatomic, strong) NSMutableArray *mDeviceArray;

// URL specifying the location of the receiver
@property (nonatomic, strong) NSString *host;

@end

#define mAppDelegate \
((GCKAppDelegate *) [UIApplication sharedApplication].delegate)