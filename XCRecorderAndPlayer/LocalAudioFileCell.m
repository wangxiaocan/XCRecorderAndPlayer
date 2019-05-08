//
//  LocalAudioFileCell.m
//  XCRecorderAndPlayer
//
//  Created by 王文科 on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "LocalAudioFileCell.h"

@interface LocalAudioFileCell()

@property (nonatomic, weak) NSDictionary    *audioData;

@end

@implementation LocalAudioFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    CGFloat inserts = 7;
    [_xcPlayBtn setImageEdgeInsets:UIEdgeInsetsMake(inserts, inserts, inserts, inserts)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerNotification:) name:XCAudioPlayerModelPlaying object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setAudioData:(NSDictionary *)audioData{
    _audioData = audioData;
    _xcTitle.text = [audioData objectForKey:@"name"];
    NSTimeInterval time = [[audioData objectForKey:@"time"] doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-M-d";
    _xcTime.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Play"] forState:UIControlStateNormal];
}

- (NSString *)fileName{
    NSString *fileName = nil;
    if (self.audioData) {
        return self.audioData[@"fileName"];
    }
    return fileName;
}

- (void)audioPlayerNotification:(NSNotification *)notifi{
    XCAudioPlayerModel *playModel = [XCAudioPlayerModel shareInstance];
    SoundWaveView *waveView = [notifi.userInfo objectForKey:@"waveView"];
    BOOL currentCell = NO;
    if (playModel.currentPlayFile && [playModel.currentPlayFile containsString:self.fileName]) {
        currentCell = YES;
    }
    [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Play"] forState:UIControlStateNormal];
    if (currentCell) {
        [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Pause"] forState:UIControlStateNormal];
    }else{
        NSArray *views = [self.xcWaveContent subviews];
        for (UIView *subView in views) {
            [subView removeFromSuperview];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end