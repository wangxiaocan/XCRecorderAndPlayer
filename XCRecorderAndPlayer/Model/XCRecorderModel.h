//
//  XCRecorderModel.h
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol XCRecorderModelDelegate;
NS_ASSUME_NONNULL_BEGIN

@interface XCRecorderModel : NSObject

+ (instancetype)shareInstance;
@property (nonatomic, readonly) AVAudioRecorder   *audioRecorder;


+ (void)startRecord:(id<XCRecorderModelDelegate>)delegate;

+ (void)stop;

+ (BOOL)saveAudioFile:(NSString *)cacheFile withNewName:(NSString *)name;
+ (NSString *)getLocalAudioFile:(NSString *)name;

@end


@protocol XCRecorderModelDelegate <NSObject>


@required
- (void)xCRecorderModelStartRecord:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder;
- (void)xCRecorderModelComplete:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder andRecorderAudioFile:(NSString *)audioFilePath;
- (void)xCRecorderModelRecordFaild:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder;

@optional
/** get AVAudioRecorder property values */
- (void)xCRecorderModelValuesChanged:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder;




@end

NS_ASSUME_NONNULL_END
