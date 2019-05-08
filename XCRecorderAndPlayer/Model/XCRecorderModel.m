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

+ (void)startRecord:(id<XCRecorderModelDelegate>)delegate{
    XCRecorderModel *model = [XCRecorderModel shareInstance];
    model.recorderDelegate = delegate;
    if (![model.audioRecorder isRecording]) {
        [XCAudioPlayerModel stop];
        [model record];
    }else{
        NSLog(@"start record faild:have recording");
    }
}

+ (void)stop{
    XCRecorderModel *model = [XCRecorderModel shareInstance];
    [model stop];
}

- (void)record{
    if (self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelStartRecord:withRecorder:)] && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelRecordFaild:withRecorder:)] && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelComplete:withRecorder:andRecorderAudioFile:)]) {
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil]) {
            NSLog(@"XCRecorderModel AVAudioSession setCategory AVAudioSessionCategoryPlayAndRecord faild");
        }
        if (![[AVAudioSession sharedInstance] setActive:YES error:nil]) {
            NSLog(@"XCRecorderModel AVAudioSession setActive to YES faild");
        }
        [self.audioRecorder prepareToRecord];
        BOOL recordStatus = [self.audioRecorder record];
        if (recordStatus) {
            [self refreshRecordingValues];
            [self.recorderDelegate xCRecorderModelStartRecord:self withRecorder:self.audioRecorder];
        }else if (!recordStatus) {
            [self.recorderDelegate xCRecorderModelRecordFaild:self withRecorder:self.audioRecorder];
        }
    }else{
        NSLog(@"XCRecorderModel record faild:recorderDelegate error");
    }
}

- (void)stop{
    [self.audioRecorder stop];
    if (![[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil]) {
        NSLog(@"XCRecorderModel AVAudioSession setActive to NO withOptions AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation faild");
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshRecordingValues) object:self];
}


- (void)refreshRecordingValues{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshRecordingValues) object:self];
    if ([self.audioRecorder isRecording] && self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelValuesChanged:withRecorder:)]) {
        [self.recorderDelegate xCRecorderModelValuesChanged:self withRecorder:self.audioRecorder];
        [self performSelector:@selector(refreshRecordingValues) withObject:self afterDelay:0.1];
    }
}


+ (BOOL)saveAudioFile:(NSString *)cacheFile withNewName:(NSString *)name{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fileName = [[NSString stringWithFormat:@"%@%lf",name,[[NSDate date] timeIntervalSince1970]] md5String];
    NSString *newPath = [[[XCRecorderModel shareInstance] recorderDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",fileName]];
    BOOL saveSuccess = NO;
    if ([fileManager fileExistsAtPath:cacheFile isDirectory:nil]) {
        saveSuccess = [fileManager copyItemAtPath:cacheFile toPath:newPath error:nil];
        if (saveSuccess) {
            [self addNewFileToLocal:@{@"name":name,@"fileName":fileName,@"time":@([[NSDate date] timeIntervalSince1970])}];
        }
    }
    return saveSuccess;
}
+ (BOOL)deleteLoaclFile:(NSDictionary *)fileData{
    NSArray *localData = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_audios"];
    NSMutableArray *localAudios = [NSMutableArray arrayWithCapacity:0];
    if (localData) {
        [localAudios addObjectsFromArray:localData];
        [localAudios removeObject:fileData];
    }
    NSString *filePath = [self getLocalAudioFile:fileData[@"fileName"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:nil]) {
        [[NSUserDefaults standardUserDefaults] setObject:localAudios forKey:@"local_audios"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}
+ (NSString *)getLocalAudioFile:(NSString *)name{
    NSString *newPath = [[[XCRecorderModel shareInstance] recorderDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",name]];
    return newPath;
}

+ (void)addNewFileToLocal:(NSDictionary *)files{
    NSArray *localData = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_audios"];
    NSMutableArray *localAudios = [NSMutableArray arrayWithCapacity:0];
    if (localData) {
        [localAudios addObjectsFromArray:localData];
    }
    [localAudios addObject:files];
    [[NSUserDefaults standardUserDefaults] setObject:localAudios forKey:@"local_audios"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma delegate
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelComplete:withRecorder:andRecorderAudioFile:)]) {
        [self.recorderDelegate xCRecorderModelComplete:self withRecorder:self.audioRecorder andRecorderAudioFile:[self recorderCacheFilePath]];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (self.recorderDelegate && [self.recorderDelegate respondsToSelector:@selector(xCRecorderModelRecordFaild:withRecorder:)]) {
        [self.recorderDelegate xCRecorderModelRecordFaild:self withRecorder:self.audioRecorder];
    }
}



- (void)dealloc{
    if (_audioRecorder) {
        _audioRecorder.delegate = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshRecordingValues) object:self];
}

@end
