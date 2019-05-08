//
//  LocalAudioFileCell.h
//  XCRecorderAndPlayer
//
//  Created by 王文科 on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalAudioFileCell : UITableViewCell

@property (nonatomic, weak) UIViewController    *viewControl;

@property (nonatomic, weak) IBOutlet UILabel    *xcTitle;
@property (nonatomic, weak) IBOutlet UILabel    *xcTime;
@property (nonatomic, weak) IBOutlet UIView     *xcWaveContent;
@property (nonatomic, weak) IBOutlet UIButton   *xcPlayBtn;
@property (nonatomic, weak) IBOutlet UIProgressView *playProgress;


@property (nonatomic, readonly) NSString    *fileName;

- (void)setAudioData:(NSDictionary *)audioData;

@end

NS_ASSUME_NONNULL_END
