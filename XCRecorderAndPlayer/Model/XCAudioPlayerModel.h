//
//  XCAudioPlayerModel.h
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const XCAudioPlayerModelPlaying;

@protocol XCAudioPlayerModelDelegate;

@interface XCAudioPlayerModel : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, readonly) AVAudioPlayer     *audioPlayer;

@property (nonatomic, readonly) NSString          *currentPlayFile;

+ (void)playAudioWithFile:(NSString *)file withDelegate:(id<XCAudioPlayerModelDelegate>)delegate;

+ (void)stop;

@end


@protocol XCAudioPlayerModelDelegate <NSObject>

@optional
- (void)xcAudioPlayerModel:(XCAudioPlayerModel *)model audioPlayerValueChanged:(AVAudioPlayer *)player;

@required
- (void)xcAudioPlayerModelStartPlaying:(XCAudioPlayerModel *)model;
- (void)xcAudioPlayerModelPlayComplete:(XCAudioPlayerModel *)model;
- (void)xcAudioPlayerModelPlayFaild:(XCAudioPlayerModel *)model;

@end

NS_ASSUME_NONNULL_END
