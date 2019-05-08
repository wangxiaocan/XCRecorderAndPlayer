//
//  XCRecorderModel.m
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "XCRecorderModel.h"

NSString *const LocalRecorderFile = @"recorder.caf";
NSString *const LocalRecorderDirectory = @"recorder";


@interface XCRecorderModel()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder   *audioRecorder;
@property (nonatomic, weak)   id<XCRecorderModelDelegate> recorderDelegate;

@end

@implementation XCRecorderModel

+ (instancetype)shareInstance{
    static XCRecorderModel  *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [[XCRecorderModel alloc] init];
    });
    return recorder;
}

- (AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        NSDictionary *settings = @{AVFormatIDKey:@(kAudioFormatAppleIMA4),
                                   AVSampleRateKey:@(44100.0f),
                                   AVNumberOfChannelsKey:@(1),
                                   AVEncoderBitDepthHintKey:@(16),
                                   AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
                                   };
        NSString *recordFile = [self recorderCacheFilePath];
        NSError *error;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordFile] settings:settings error:&error];
        if (!_audioRecorder) {
            NSLog(@"init AVAudioRecorder faild:%@",error);
        }else{
            _audioRecorder.meteringEnabled = YES;
            _audioRecorder.delegate = self;
        }
    }
    return _audioRecorder;
}

/** 临时录音文件 */
- (NSString *)recorderCacheFilePath{
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [basePath stringByAppendingPathComponent:LocalRecorderFile];
    return filePath;
}

/** 录音文件保存文件夹地址 */
- (NSString *)recorderDirectory{
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directory = [basePath stringByAppendingPathComponent:LocalRecorderDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    BOOL createDirectory = YES;
    if ([manager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        if (isDirectory) {
            createDirectory = NO;
        }
    }
    if (createDirectory) {
        NSError *error;
        if (![manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create recorder directory faild:%@",error);
        }
    }
    return directory;
}



- (void)record{
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil]) {
        NSLog(@"XCRecorderModel AVAudioSession setCategory AVAudioSessionCategoryPlayAndRecord faild");
    }
    if (![[AVAudioSession sharedInstance] setActive:YES error:nil]) {
        NSLog(@"XCRecorderModel AVAudioSession setActive to YES faild");
    }
    [self.audioRecorder prepareToRecord];
    BOOL recordStatus = [self.audioRecorder record];
    if (recordStatus && self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelStartRecord:withRecorder:)]) {
        [self.recorderDelegate xCRecorderModelStartRecord:self withRecorder:self.audioRecorder];
    }else if (!recordStatus && self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelRecordFaild:withRecorder:)]) {
        [self.recorderDelegate xCRecorderModelRecordFaild:self withRecorder:self.audioRecorder];
    }
}

- (void)stop{
    [self.audioRecorder stop];
    if (![[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil]) {
        NSLog(@"XCRecorderModel AVAudioSession setActive to NO withOptions AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation faild");
    }
}


#pragma delegate
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelComplite:withRecorder:andRecorderAudioFile:)]) {
        [self.recorderDelegate xCRecorderModelComplite:self withRecorder:self.audioRecorder andRecorderAudioFile:[self recorderCacheFilePath]];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    
}



- (void)dealloc{
    if (_audioRecorder) {
        _audioRecorder.delegate = nil;
    }
}

@end
