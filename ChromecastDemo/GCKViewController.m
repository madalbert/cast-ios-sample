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

#import "GCKViewController.h"
#import "GCKAppDelegate.h"
#import "CoreMedia/CoreMedia.h"
#import "AVFoundation/AVFoundation.h"

@interface GCKViewController ()

// Fields for local playback (on sender device)
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

// Fields for second-screen playback
@property (nonatomic, strong) GCKApplicationSession *mSession;
@property (nonatomic, strong) GCKMediaProtocolMessageStream *mMPMS;
@property (nonatomic, strong) GCKMimeData *applicationArgument;

@end

@implementation GCKViewController

@synthesize keys = keys_;
@synthesize urls = urls_;
@synthesize data = data_;
@synthesize playPauseButton = playPauseButton_;
@synthesize stopButton = stopButton_;
@synthesize selectDeviceButton = selectDeviceButton_;
@synthesize volumeSlider = volumeSlider_;
@synthesize playProgressSlider = playProgressSlider_;
@synthesize volumeImage = volumeImage_;

@synthesize mSession = mSession_;
@synthesize mMPMS = mMPMS_;
@synthesize applicationArgument = applicationArgument_;

BOOL playPauseIsPlay = NO;
BOOL stopWasPressedBefore = NO;
BOOL localPlay = YES;
double mediaDuration;
double currentPlayPosition = 0.0;
double playPositionWhenSwitch = 0.0;

#pragma mark - Player Setup

// Play the currently selected media, as specified by mAppDelegate.mediaContent,
// on the sender device without casting.
- (void)playMovie {
  [self.volumeSlider setHidden:YES];
  [self.volumeImage setHidden:YES];
  [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
  if (self.mMPMS) {
    playPositionWhenSwitch = self.mMPMS.streamPosition;
    NSLog(@"playPostion _ playMovie: %f", playPositionWhenSwitch);
    [self.mMPMS stopStream];
  }
  
  NSLog(@"Playing the selected media locally.");
  NSURL *url = [NSURL URLWithString: mAppDelegate.mediaContent];
  self.playerItem = [AVPlayerItem playerItemWithURL:url];
  if (self.player) {
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
  } else {
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
  }
  
  AVPlayerLayer *playerLayer =
      [AVPlayerLayer playerLayerWithPlayer:self.player];
  playerLayer.frame = self.mediaView.bounds;
  CALayer *superLayer = self.mediaView.layer;
  [superLayer addSublayer:playerLayer];
  [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
  CMTime newTime = CMTimeMakeWithSeconds(playPositionWhenSwitch, 1);
  [self.player seekToTime:newTime];
  [self.player play];
}

// Play the currently selected media on the connected second-screen Cast device.
-(void)castMovie {
  [self.volumeSlider setHidden:NO];
  [self.volumeImage setHidden:NO];
  [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
  if (self.player) {
    NSLog(@"Stopping the local player and casting to device.");
    playPositionWhenSwitch = CMTimeGetSeconds([self.player currentTime]);
    NSLog(@"playPosition _ castMovie: %f", playPositionWhenSwitch);
    [self.player pause];
  }
  
  if (mAppDelegate.mDevice) {
    NSLog(@"Setting up session for remote playback.");
    self.applicationArgument =
        [[GCKMimeData alloc] initWithTextData:mAppDelegate.host
                                         type:kGCKMimeText];
    self.mSession =
        [[GCKApplicationSession alloc] initWithContext:mAppDelegate.mContext
                                                device:mAppDelegate.mDevice];
    self.mSession.delegate = self;
    NSLog(@"Starting session.");
    [self.mSession startSessionWithApplication:@"YOUR_APP_ID"
                                      argument:self.applicationArgument];
  } else {
    NSLog(@" Error casting movie; no device connected.");
  }
}

// Updates the state of the display, including the playback progress slider and
// the visibility of the Cast device button, depending on whether Cast devices
// are available to connect to.
- (void)updateStatus {
  [self updateProgressSlider];
  NSString *nowPlaying = @"Currently playing: ";
  if (mAppDelegate.mediaTitle) {
    nowPlaying = [nowPlaying stringByAppendingString:mAppDelegate.mediaTitle];
  }
  self.currentlyPlaying.text = nowPlaying;
  
  if (mAppDelegate.mDeviceArray.count > 0) {
    [self.selectDeviceButton setHidden:NO];
  } else {
    [self.selectDeviceButton setHidden:YES];
  }
}

// Checks the current status of playback.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self.player && [keyPath isEqualToString:@"status"]) {
    if (self.player.status == AVPlayerStatusReadyToPlay) {
      NSLog(@"Player ready to play.");
    } else if (self.player.status == AVPlayerStatusFailed) {
      NSLog(@"Something is wrong with the player.");
    }
  }
}

// Upon view loading, create the fixed set of media objects this app can play,
// and start scanning for devices on the network.
- (void)viewDidLoad {
  [super viewDidLoad];
  self.keys = [NSArray arrayWithObjects:@"Big Buck Bunny", @"Tears of Steel", @"Elephant Dreams", @"Marnau the Vampire",
               @"Project London", @"Reel 2012", @"Google IO 2011 Countdown (MUSIC)",  @"Google IO 2011 Walkout (Music)", nil];
  self.urls = [NSArray arrayWithObjects:@"http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/tears_of_steel_1080p.webm",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/ED_1280.mp4",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/murnau_the_vampire_(2007)_oscar_alvarado%C2%B4s_480x200.mp4",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/project_london-_official_trailer_1280x720.mp4",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/reel_2012_1280x720.mp4",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/Google%20IO%202011-%2030%20min%20Countdown.mp3",
               @"http://commondatastorage.googleapis.com/gtv-videos-bucket/Google%20IO%202011%2045%20Min%20Walk%20Out.mp3",
               nil];
  self.data = [NSDictionary dictionaryWithObjects:self.urls
                                          forKeys:self.keys];
  
  [self startScan];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  [self.mediaTableView reloadData];
  [NSTimer scheduledTimerWithTimeInterval:2
                                   target:self
                                 selector:@selector(updateStatus)
                                 userInfo:nil
                                  repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [mAppDelegate.deviceManager addListener:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"mediaCell";
  UITableViewCell *mediaCell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                     forIndexPath:indexPath];
  mediaCell.textLabel.text = [self.keys objectAtIndex:indexPath.row];
  return mediaCell;
}

#pragma mark - Media Table view delegate

// Upon user selecting a media item to play, determines whether the media should
// be played locally or cast to the connected device.
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSString *mediaTitle = [self.keys objectAtIndex:indexPath.row];
  NSString *mediaUrl = [self.data objectForKey:mediaTitle];
  mAppDelegate.mediaContent = mediaUrl;
  mAppDelegate.mediaTitle = mediaTitle;
  if (localPlay) {
    [self playMovie];
  } else {
    [self castMovie];
  }
}

#pragma mark - Media Controls

// Changes volume based on the value of the UISlider.
- (IBAction)changeVolume:(UISlider *)sender {
  if (!localPlay) {
    if (self.mMPMS) {
      double sliderValue = self.volumeSlider.value;
      [self.volumeSlider setValue:sliderValue animated:YES];
      [self.mMPMS setStreamVolume:sliderValue];
    } else {
      NSLog(@"Can't change volume for connected device; message stream null");
    }
  }
}

- (IBAction)playPauseVideo:(UIButton *)sender {
  self.playPauseButton = sender;
  
  if (localPlay) {
    if (playPauseIsPlay) {
      NSLog(@"Play button pressed");
      [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                      forState:UIControlStateNormal];
      stopWasPressedBefore = !stopWasPressedBefore;
      [self.player play];
    } else {
      NSLog(@"Pause button pressed");
      [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                                      forState:UIControlStateNormal];
      [self.player pause];
    }
    playPauseIsPlay = !playPauseIsPlay;
  } else {
    if (self.mMPMS) {
      if (playPauseIsPlay) {
        NSLog(@"Play button pressed");
        if (stopWasPressedBefore) {
          [self.mMPMS playStream];
          stopWasPressedBefore = !stopWasPressedBefore;
        } else {
          [self.mMPMS resumeStream];
        }
        [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                        forState:UIControlStateNormal];
      } else {
        NSLog(@"Pause button pressed");
        if (self.mMPMS) {
          [self.mMPMS stopStream];
          [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                                          forState:UIControlStateNormal];
        }
      }
      playPauseIsPlay = !playPauseIsPlay;
      
    } else {
      NSLog(@"Can't play or pause connected media; message stream is null");
    }
  }
}

- (IBAction)stopVideo:(UIButton *)sender {
  NSLog(@"Stop button pressed");
  playPauseIsPlay = YES;
  
  if (localPlay) {
    [self.player pause];
  } else {
    if (self.mMPMS) {
      [self.mMPMS stopStream];
      stopWasPressedBefore = !stopWasPressedBefore;
    } else {
      NSLog(@"Can't stop connected video; message stream is null");
    }
  }
  [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                                  forState:UIControlStateNormal];
}

#pragma mark - Progress Bar Controls

// Handles changes made to the progress bar, and in the currently playing media,
// seeks to the new position and starts playback from that position.
- (IBAction)changePlayPosition:(id)sender {
  CMTime newTime = CMTimeMakeWithSeconds(self.playProgressSlider.value, 1);
  
  if (localPlay) {
    [self.player seekToTime:newTime];
    [self.player play];
    
  } else {
    if (self.mMPMS) {
      [self.mMPMS playStreamFrom:self.playProgressSlider.value];
    }
  }
  [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                  forState:UIControlStateNormal];
  playPauseIsPlay = NO;
}

// Updates the display of the progress slider based on the current playback
// time.
- (void)updateProgressSlider {
  if (localPlay) {
    if (self.player) {
      self.playProgressSlider.maximumValue =
          CMTimeGetSeconds([self.playerItem duration]);
      self.playProgressSlider.value =
          CMTimeGetSeconds([self.player currentTime]);
    }
  } else {
    if (self.mMPMS) {
      self.playProgressSlider.maximumValue = [self.mMPMS streamDuration];
      self.playProgressSlider.value = [self.mMPMS streamPosition];
    }
  }
}

#pragma mark - ActionSheet for device selection

// Determines whether the device is an iPad or iPhone.
- (BOOL)isIpad {
  if ([(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
    return YES;
  } else {
    return NO;
  }
}

- (IBAction)showActionSheet:(id)sender {
  UIActionSheet *deviceSelection =
      [[UIActionSheet alloc] initWithTitle:@"Select a Device"
                                  delegate:self
                         cancelButtonTitle:[self isIpad] ? nil : @"Cancel"
                    destructiveButtonTitle:nil
                         otherButtonTitles:@"Local", nil];
  
  for (GCKDevice *dev in mAppDelegate.mDeviceArray){
    [deviceSelection addButtonWithTitle:dev.friendlyName];
  }
  
  deviceSelection.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [deviceSelection showInView:self.view];
}

// Determines the identity of the clicked button, and performs some action based
// on which button was selected.
- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSLog(@"Selected button %d", buttonIndex);
  
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  playPositionWhenSwitch = 0.0;
  if (buttonIndex == actionSheet.firstOtherButtonIndex) {
    NSLog(@"Local play selected");
    localPlay = YES;
    
    if (self.mMPMS) {
      playPositionWhenSwitch = self.mMPMS.streamPosition;
      [self.mMPMS stopStream];
    }
    if (self.player.status == AVPlayerStatusReadyToPlay) {
      CMTime newTime = CMTimeMakeWithSeconds(playPositionWhenSwitch, 1);
      [self.player seekToTime:newTime];
      [self.player play];
    }
    [self.selectDeviceButton
         setBackgroundImage:[UIImage imageNamed:@"device_off.png"]
                                       forState:UIControlStateNormal];
    
  } else {
    if (self.isIpad) {
      mAppDelegate.mDevice =
          [mAppDelegate.mDeviceArray  objectAtIndex:buttonIndex-1];
    } else {
      mAppDelegate.mDevice =
          [mAppDelegate.mDeviceArray  objectAtIndex:buttonIndex-2];
    }
    
    NSLog(@"Remote play selected");
    localPlay = NO;
    double currentPlayPosition;
    if (self.player.status == AVPlayerStatusReadyToPlay) {
      // Consider playing at current position, if already playing.
      currentPlayPosition = CMTimeGetSeconds([self.player currentTime]);
      NSLog(@"currentPlayPostion: %f", currentPlayPosition);
      [self castMovie];
    }
    [self.selectDeviceButton setBackgroundImage:
         [UIImage imageNamed:@"device_on.png"] forState:UIControlStateNormal];
    NSLog(@"Selected device: %@", mAppDelegate.mDevice.friendlyName);
  }
}

// Stops the current scan for devices.
- (void)stopScan {
  [mAppDelegate.deviceManager stopScan];
  [NSTimer scheduledTimerWithTimeInterval:60
                                   target:self
                                 selector:@selector(startScan)
                                 userInfo:nil
                                  repeats:NO];
}

// Starts a new scan for devices.
- (void)startScan {
  [mAppDelegate.deviceManager startScan];
  [NSTimer scheduledTimerWithTimeInterval:3
                                   target:self
                                 selector:@selector(stopScan)
                                 userInfo:nil
                                  repeats:NO];
}

#pragma mark - DeviceManagerListener

// Clears the list of devices upon starting a new scan.
- (void)scanStarted {
  if (mAppDelegate.mDeviceArray) {
    [mAppDelegate.mDeviceArray removeAllObjects];
  }
}

// Sets the visibility of the device select button depending on the number of
// devices found during the last scan.
- (void)scanStopped {
  if (mAppDelegate.mDeviceArray.count >0) {
    [self.selectDeviceButton setHidden:NO];
  } else {
    [self.selectDeviceButton setHidden:YES];
  }
}

// Adds a device to the list when it comes online.
- (void) deviceDidComeOnline:(GCKDevice *)device {
  if (!mAppDelegate.mDeviceArray) {
    mAppDelegate.mDeviceArray = [[NSMutableArray alloc]init];
  }
  
  NSUInteger insertIndex;
  for (insertIndex = 0;
       insertIndex < [mAppDelegate.mDeviceArray count];
       ++insertIndex) {
    GCKDevice *existing = [mAppDelegate.mDeviceArray objectAtIndex:insertIndex];
    if (([existing.friendlyName caseInsensitiveCompare:device.friendlyName]
         >= NSOrderedSame)) {
      break;
    }
  }
  [mAppDelegate.mDeviceArray insertObject:device atIndex:insertIndex];
  NSLog(@"mDeviceDidComeOnline: %@" , device.friendlyName);
}

// Remove a device from the display list when it goes offline.
- (void)deviceDidGoOffline:(GCKDevice *)device {
  [mAppDelegate.mDeviceArray removeObject:device];
  NSLog(@"mDeviceDidGoOffLine  %@" , device.friendlyName);
}

#pragma mark - GCKApplicationSessionDelegate

// Logs when an application fails to start.
- (void)applicationSessionDidFailToStartWithError:
    (GCKApplicationSessionError *)errorCode {
  NSLog(@"GCK Session failed to start: %@", errorCode);
}

// Logs when an application fails to end correctly.
- (void)applicationSessionDidEndWithError:
    (GCKApplicationSessionError *)errorCode {
  NSLog(@"GCK Session ended with error code: %@", errorCode);
}

- (void)applicationSessionDidStart {
  NSLog(@"Application session started");
  GCKApplicationChannel *mChannel = self.mSession.channel;
  self.mMPMS = [[GCKMediaProtocolMessageStream alloc] init];
  NSLog(@"Initiated ramp: %@", self.mMPMS);
  [mChannel attachMessageStream:self.mMPMS];
  
  [self loadMedia];
}

// Load the currently selected piece of media.
- (void)loadMedia {
  GCKContentMetadata *mData =
      [[GCKContentMetadata alloc] initWithTitle:mAppDelegate.mediaTitle
                                       imageURL:nil
                                    contentInfo:nil];
  
  GCKMediaProtocolCommand *cmd =
      [self.mMPMS loadMediaWithContentID:mAppDelegate.mediaContent
                        contentMetadata:mData];
  cmd.delegate = self;
}

// Logs the received message.
- (void) didReceiveMessage: (id) message {
  NSLog(@"Message: %@" , message);
}

#pragma mark - MediaProtocolCommandDelegate

// Begins playback upon successfully loading a piece of media.
- (void) mediaProtocolCommandDidComplete:(GCKMediaProtocolCommand *)command {
  NSLog(@"mediaProtocolCommandDidComplete");
  [self.volumeSlider setValue:[self.mMPMS volume] animated:YES];
  [self.mMPMS setStreamVolume:0.5];
  NSLog(@"Starting cast playback");
  NSLog(@"playPosition: %f", playPositionWhenSwitch);
  [self.mMPMS playStreamFrom:playPositionWhenSwitch];
}

// Logs a cancelled load command.
- (void)mediaProtocolCommandWasCancelled:(GCKMediaProtocolCommand *)command {
  NSLog(@"mediaProtocolCommandWasCancelled");
}

@end
