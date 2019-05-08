//
//  LocalAudioHeader.m
//  XCRecorderAndPlayer
//
//  Created by 王文科 on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "LocalAudioHeader.h"

@implementation LocalAudioHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _xcTitleLabel = [[UILabel alloc] init];
        _xcTitleLabel.textAlignment = NSTextAlignmentLeft;
        _xcTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_xcTitleLabel];
        [_xcTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.0);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
    }
    return self;
}

@end
