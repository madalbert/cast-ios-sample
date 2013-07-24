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
#import "MediaPlayer/MediaPlayer.h"

// A view controller which handles device selection, casting to the connected
// device, and other playback controls.
@interface GCKViewController : UIViewController
    <UITableViewDelegate,
    UITableViewDataSource,
    GCKDeviceManagerListener,
    UIActionSheetDelegate,
    GCKApplicationSessionDelegate,
    GCKMediaProtocolCommandDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mediaTableView;
@property (weak, nonatomic) IBOutlet UIView *mediaView;
@property (weak, nonatomic) IBOutlet UISlider *playProgressSlider;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentlyPlaying;
@property (weak, nonatomic) IBOutlet UIImageView *volumeImage;

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *selectDeviceButton;

// Either plays or pauses the currently selected media, depending on whether it
// is currently playing.
- (IBAction)playPauseVideo:(UIButton *)sender;

// Stops the currently playing media.
- (IBAction)stopVideo:(UIButton *)sender;

// Handles volume changes for the currently playing media and device.
- (IBAction)changeVolume:(UISlider *)sender;

// Displays the list of devices found on the network.
- (IBAction)showActionSheet:(id)sender;

@end
