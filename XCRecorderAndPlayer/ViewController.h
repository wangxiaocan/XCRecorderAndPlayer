//
//  ViewController.h
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

@interface ViewController : UIViewController


@property (nonatomic, weak) IBOutlet SoundWaveView *waveView;
@property (nonatomic, weak) IBOutlet UIButton      *recorderBtn;
@property (nonatomic, weak) IBOutlet UIButton      *recorderStopBtn;
@property (nonatomic, weak) IBOutlet UILabel       *recorderTimeLabel;
@property (nonatomic, weak) IBOutlet UITableView   *localRecorderTable;


@end

