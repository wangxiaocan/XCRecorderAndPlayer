//
//  SoundWaveView.m
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "SoundWaveView.h"


CGFloat const SoundWaveValuesNum = 10;
CGFloat const SoundWaveMinumValue = 10.0;
CGFloat const SoundWaveMaxValue = 60;

CGFloat const  LineSpace = 3.0;
CGFloat const  LineWidth = 4.0;
CGFloat const  LineLeftSpace = 2.0;

@interface SoundWaveView()

@property (nonatomic, strong) NSMutableArray    *soundWaveValues;

@end

@implementation SoundWaveView

- (NSMutableArray *)soundWaveValues{
    if (!_soundWaveValues) {
        self.soundWaveValues = [NSMutableArray arrayWithCapacity:SoundWaveValuesNum];
        for (NSUInteger i = 0; i < SoundWaveValuesNum; i++) {
            [_soundWaveValues addObject:@(SoundWaveMinumValue)];
        }
    }
    return _soundWaveValues;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initWaveView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWaveView];
    }
    return self;
}

- (void)initWaveView{
    self.clipsToBounds = YES;
    [self redrawView];
    [self refreshWaveValue];
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:CGRectMake(0, 0, [self soundWaveViewWidth], [self soundWaveViewHeight])];
}

- (void)refreshWaveValue{
    if (self.soundWaveViewDelegate && [self.soundWaveViewDelegate respondsToSelector:@selector(getCurrentSoundWaveValue:)]) {
        [self addSoundWaveValue:[self.soundWaveViewDelegate getCurrentSoundWaveValue:self]];
    }else{
        [self addSoundWaveValue:0];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshWaveValue) object:self];
    [self performSelector:@selector(refreshWaveValue) withObject:self afterDelay:0.1];
}

- (void)addSoundWaveValue:(float)value{
    if (value < SoundWaveMinumValue) {
        value = random() % 3 + SoundWaveMinumValue;
    }else if (value > SoundWaveMaxValue) {
        value = SoundWaveMaxValue;
    }
    [self.soundWaveValues removeObjectAtIndex:0];
    [self.soundWaveValues addObject:@(value)];
    [self redrawView];
}


- (void)redrawView{
    [self removeAllLayers];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    NSInteger index = 0;
    for (NSNumber *value in self.soundWaveValues) {
        CGFloat pointY = [self soundWaveViewHeight] - [value floatValue];
        CGFloat pointX = LineLeftSpace + LineWidth / 2.0 + (LineWidth + LineSpace) * index;
        [bezierPath moveToPoint:CGPointMake(pointX, [self soundWaveViewHeight])];
        [bezierPath addLineToPoint:CGPointMake(pointX, pointY)];
        index++;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [bezierPath CGPath];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = LineWidth;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:shapeLayer];
}


- (void)removeAllLayers{
    NSArray *layers = [self.layer sublayers];
    for (CALayer *layer in layers) {
        [layer removeFromSuperlayer];
    }
}

- (CGFloat)soundWaveViewWidth{
    CGFloat width = SoundWaveValuesNum * LineWidth + (SoundWaveValuesNum - 1) * LineSpace;
    return width + LineLeftSpace * 2;
}

- (CGFloat)soundWaveViewHeight{
    return SoundWaveMaxValue + LineLeftSpace;
}


@end
