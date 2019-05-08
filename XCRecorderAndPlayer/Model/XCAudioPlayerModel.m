//
//  XCAudioPlayerModel.m
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "XCAudioPlayerModel.h"


NSString *const XCAudioPlayerModelPlaying = @"XCAudioPlayerModelPlaying";

@interface XCAudioPlayerModel()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer     *audioPlayer;

@property (nonatomic, copy) NSString            *currentPlayFile;


@property (nonatomic, weak)   id<XCAudioPlayerModelDelegate> playModelDelegate;

@end

@implementation XCAudioPlayerModel

+ (instancetype)shareInstance{
    static XCAudioPlayerModel *playerModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerModel = [[XCAudioPlayerModel alloc] init];
    });
    return playerModel;
}

+ (void)playAudioWithFile:(NSString *)file withDelegate:(id<XCAudioPlayerModelDelegate>)delegate{
    if ([[XCRecorderModel shareInstance].audioRecorder isRecording]) {
        NSLog(@"XCAudioPlayerModel play faild:XCRecorderModel is recording");
        return;
    }
    
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil]) {
        NSLog(@"XCAudioPlayerModel AVAudioSession setCategory AVAudioSessionCategoryPlayback faild");
    }
    if (![[AVAudioSession sharedInstance] setActive:YES error:nil]) {
        NSLog(@"XCAudioPlayerModel AVAudioSession setActive to YES faild");
    }
    XCAudioPlayerModel *playModel = [XCAudioPlayerModel shareInstance];
    playModel.playModelDelegate = delegate;
    if (playModel.audioPlayer && [playModel.audioPlayer isPlaying]) {
        [playModel.audioPlayer stop];
    }
    NSError *error;
    playModel.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:&error];
    if (!playModel.audioPlayer) {
        NSLog(@"XCAudioPlayerModel init AVAudioPlayer faild:%@",error);
    }else{
        playModel.currentPlayFile = file;
        playModel.audioPlayer.delegate = playModel;
        playModel.audioPlayer.meteringEnabled = YES;
        [playModel.audioPlayer prepareToPlay];
        if ([playModel.audioPlayer play]) {
            [playModel refreshAudioPlayerValue];
            if (playModel.playModelDelegate && [playModel.playModelDelegate respondsToSelector:@selector(xcAudioPlayerModelStartPlaying:)]) {
                [playModel.playModelDelegate xcAudioPlayerModelStartPlaying:playModel];
            }
            NSLog(@"XCAudioPlayerModel start play:%@",file);
        }
    }
}

+ (void)stop{
    XCAudioPlayerModel *playModel = [XCAudioPlayerModel shareInstance];
    if (playModel.audioPlayer && [playModel.audioPlayer isPlaying]) {
        [playModel.audioPlayer stop];
        playModel.currentPlayFile = nil;
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        if (playModel.playModelDelegate && [playModel.playModelDelegate respondsToSelector:@selector(xcAudioPlayerModelPlayComplete:)]) {
            [playModel.playModelDelegate xcAudioPlayerModelPlayComplete:playModel];
        }
    }
}


- (void)refreshAudioPlayerValue{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshAudioPlayerValue) object:self];
    if (self.audioPlayer && [self.audioPlayer isPlaying] && self.playModelDelegate && [self.playModelDelegate respondsToSelector:@selector(xcAudioPlayerModel:audioPlayerValueChanged:)]) {
        [self.playModelDelegate xcAudioPlayerModel:self audioPlayerValueChanged:self.audioPlayer];
        [self performSelector:@selector(refreshAudioPlayerValue) withObject:self afterDelay:0.1];
    }
}


/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.currentPlayFile = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (self.playModelDelegate && [self.playModelDelegate respondsToSelector:@selector(xcAudioPlayerModelPlayComplete:)]) {
        [self.playModelDelegate xcAudioPlayerModelPlayComplete:self];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    self.currentPlayFile = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (self.playModelDelegate && [self.playModelDelegate respondsToSelector:@selector(xcAudioPlayerModelPlayFaild:)]) {
        [self.playModelDelegate xcAudioPlayerModelPlayFaild:self];
    }
}

@end
