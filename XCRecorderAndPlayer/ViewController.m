//
//  ViewController.m
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import "ViewController.h"
#import "LocalAudioFileCell.h"
#import "LocalAudioHeader.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,XCRecorderModelDelegate,XCAudioPlayerModelDelegate>

@property (nonatomic, strong) NSMutableArray    *localAudioFiles;

@property (nonatomic, strong) SoundWaveView     *cellSoundView;

@end

@implementation ViewController

- (NSMutableArray *)localAudioFiles{
    if (!_localAudioFiles) {
        _localAudioFiles = [NSMutableArray arrayWithCapacity:0];
    }
    return _localAudioFiles;
}

- (SoundWaveView *)cellSoundView{
    if (!_cellSoundView) {
        self.cellSoundView = [[SoundWaveView alloc] init];
    }
    return _cellSoundView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshLocalAudioFileData];
    
    
    [_localRecorderTable registerNib:[UINib nibWithNibName:@"LocalAudioFileCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([LocalAudioFileCell class])];
    [_localRecorderTable registerClass:[LocalAudioHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([LocalAudioHeader class])];
}



- (IBAction)startRecord:(UIButton *)sender{
    [XCRecorderModel startRecord:self];
}

- (IBAction)stopRecord:(UIButton *)sender{
    [XCRecorderModel stop];
}

#pragma mark- record delegate
- (void)xCRecorderModelStartRecord:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder{
    
}
- (void)xCRecorderModelComplete:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder andRecorderAudioFile:(NSString *)audioFilePath{
    __strong NSString *weakFile = audioFilePath;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"录制结束，是否保存音频文件？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入新的音频名称";
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.recorderTimeLabel.text = @"00:00:00";
    }];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *field = [alertControl textFields][0];
        [ProgressHUD show:@"保存中..." Interaction:NO];
        if ([XCRecorderModel saveAudioFile:weakFile withNewName:field.text]) {
            [weakSelf refreshLocalAudioFileData];
            [ProgressHUD showSuccess:@"保存成功" Interaction:NO];
        }else{
            [ProgressHUD showError:@"保存失败" Interaction:NO];
        }
        weakSelf.recorderTimeLabel.text = @"00:00:00";
    }];
    [alertControl addAction:cancle];
    [alertControl addAction:save];
    [self presentViewController:alertControl animated:YES completion:nil];
}
- (void)xCRecorderModelRecordFaild:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder{
    _recorderTimeLabel.text = @"00:00:00";
}

- (void)xCRecorderModelValuesChanged:(XCRecorderModel *)model withRecorder:(AVAudioRecorder *)recorder{
    if ([recorder isRecording]) {
        NSTimeInterval currentTime = [recorder currentTime];
        NSInteger hour = currentTime / 3600;
        NSInteger minute = (currentTime - hour * 3600) / 60;
        NSInteger second = currentTime - hour * 3600 - minute * 60;
        _recorderTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    }else{
        _recorderTimeLabel.text = @"00:00:00";
    }
}

- (CGFloat)getCurrentSoundWaveValue:(SoundWaveView *)saveView{
    XCRecorderModel *model = [XCRecorderModel shareInstance];
    if ([model.audioRecorder isRecording]) {
        [model.audioRecorder updateMeters];
        float volumeAve = [model.audioRecorder averagePowerForChannel:0];
        return POWER_TO_DB(volumeAve) * (20.0 / 110.0);
    }
    return -1;
}

#pragma mark- audio player delegate
- (void)xcAudioPlayerModelStartPlaying:(XCAudioPlayerModel *)model{
    NSLog(@"start play");
    [self audioPlayStatusChanged];
}
- (void)xcAudioPlayerModelPlayComplete:(XCAudioPlayerModel *)model{
    NSLog(@"play complete");
    [self audioPlayStatusChanged];
}
- (void)xcAudioPlayerModelPlayFaild:(XCAudioPlayerModel *)model{
    NSLog(@"play faild");
    [self audioPlayStatusChanged];
}
- (void)xcAudioPlayerModel:(XCAudioPlayerModel *)model audioPlayerValueChanged:(AVAudioPlayer *)player{
    [player updateMeters];
    float power = [player averagePowerForChannel:0];
    [self.cellSoundView addSoundWaveValue:POWER_TO_DB(power) * (20.0 / 110.0)];
    [self refreshLocalAudioFileData];
}



- (void)refreshLocalAudioFileData{
    NSArray *files = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_audios"];
    if (files) {
        [self.localAudioFiles removeAllObjects];
        [self.localAudioFiles addObjectsFromArray:files];
        [_localRecorderTable reloadData];
    }
}

#pragma mark- table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.localAudioFiles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    LocalAudioHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([LocalAudioHeader class])];
    header.contentView.backgroundColor = [UIColor colorWithRed:240.0 / 250.0 green:240.0 / 250.0 blue:240.0 / 250.0 alpha:1.0];
    header.xcTitleLabel.text = @"本地录音文件";
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [UIView new];
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocalAudioFileCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalAudioFileCell class]) forIndexPath:indexPath];
    cell.viewControl = self;
    [cell setAudioData:self.localAudioFiles[indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak NSDictionary *weakData = self.localAudioFiles[indexPath.row];
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"删除本地录音文件" message:weakData[@"name"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ProgressHUD show:@"删除中..." Interaction:NO];
            if ([XCRecorderModel deleteLoaclFile:weakData]) {
                [ProgressHUD showSuccess:@"录音文件已删除" Interaction:NO];
                [weakSelf refreshLocalAudioFileData];
            }else{
                [ProgressHUD showError:@"删除失败" Interaction:NO];
            }
        }];
        [alertControl addAction:delete];
        [alertControl addAction:cancle];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self audioPlayStatusChanged];
}

- (void)audioPlayStatusChanged{
    [[NSNotificationCenter defaultCenter] postNotificationName:XCAudioPlayerModelPlaying object:nil userInfo:@{@"waveView":self.cellSoundView}];
}


@end
