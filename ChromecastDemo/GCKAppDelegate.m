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

#import "GCKAppDelegate.h"

static NSString * const kUserAgent = @"com.google.castsample";

@interface GCKAppDelegate()

@end

@implementation GCKAppDelegate

@synthesize mContext = mContext_;
@synthesize deviceManager = deviceManager_;
@synthesize mDevice = mDevice_;
@synthesize mDeviceArray = mDeviceArray_;
@synthesize host = host_;

// Initializes this application with a context, deviceManager, and receiver URL.
- (id)init {
  if (self = [super init]) {
    NSLog(@"Allocating context");
    self.mContext = [[GCKContext alloc] initWithUserAgent:kUserAgent];
    NSLog(@"Allocating deviceManager");
    self.deviceManager =
        [[GCKDeviceManager alloc] initWithContext:self.mContext];
    NSLog(@"init complete");
  }
  return self;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

@end
