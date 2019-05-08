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
    if (playModel.audioPlayer && [playModel.audioPlayer isPlaying] && playModel.currentPlayFile && [playModel.currentPlayFile containsString:self.fileName]) {
        currentCell = YES;
    }
    if (currentCell) {
        _playProgress.progress = playModel.audioPlayer.currentTime / playModel.audioPlayer.duration;
        [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Pause"] forState:UIControlStateNormal];
        if (![self.xcWaveContent.subviews containsObject:waveView]) {
            [self.xcWaveContent addSubview:waveView];
            [waveView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.xcWaveContent);
            }];
        }
    }else{
        _playProgress.progress = 0;
        [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Play"] forState:UIControlStateNormal];
        NSArray *views = [self.xcWaveContent subviews];
        for (UIView *subView in views) {
            [subView removeFromSuperview];
        }
    }
}

- (IBAction)playOrStop:(UIButton *)sender{
    XCAudioPlayerModel *playModel = [XCAudioPlayerModel shareInstance];
    if (playModel.audioPlayer && [playModel.audioPlayer isPlaying] && [playModel.currentPlayFile containsString:self.audioData[@"fileName"]]) {
        [XCAudioPlayerModel stop];
        [_xcPlayBtn setImage:[UIImage imageNamed:@"Audio_Play"] forState:UIControlStateNormal];
    }else{
        [XCAudioPlayerModel playAudioWithFile:[XCRecorderModel getLocalAudioFile:self.audioData[@"fileName"]] withDelegate:_viewControl];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
