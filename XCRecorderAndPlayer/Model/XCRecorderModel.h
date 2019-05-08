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

+ (void)startRecord:(id<XCRecorderModelDelegate>)delegate;

+ (void)stop;

@end


@protocol XCRecorderModelDelegate <NSObject>

@optional
- (void)xCRecorderModelStartRecord:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder;
- (void)xCRecorderModelComplite:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder andRecorderAudioFile:(NSString *)audioFilePath;
- (void)xCRecorderModelRecordFaild:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder;





@end

NS_ASSUME_NONNULL_END
