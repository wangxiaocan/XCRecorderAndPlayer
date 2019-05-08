//
//  SoundWaveView.h
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol SoundWaveViewDelegate;

@interface SoundWaveView : UIView

@property (nonatomic, weak) IBOutlet id<SoundWaveViewDelegate> soundWaveViewDelegate;

- (void)addSoundWaveValue:(float)value;

@end


@protocol SoundWaveViewDelegate <NSObject>

@optional
- (CGFloat)getCurrentSoundWaveValue:(SoundWaveView *)saveView;

@end

NS_ASSUME_NONNULL_END
