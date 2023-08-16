//
//  VEExportProgressView.m
//  VE
//
//  Created by iOS VESDK Team on 2016/12/1.
//  Copyright © 2016年 VE. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "VEHelp.h"
#import "VEExportProgressView.h"
@interface UIRectProgressView()
@property(nonatomic,strong) UIImageView *topView;
@property(nonatomic,strong) UIImageView *rightView;
@property(nonatomic,strong) UIImageView *buttomView;
@property(nonatomic,strong) UIImageView *leftView;
@property(nonatomic,strong) UILabel *progressLabel;

@end
@implementation UIRectProgressView

- (instancetype)initWithFrame:(CGRect)frame coverImage:(UIImage *)coverImage{
    if(self = [super initWithFrame:frame]){
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kNavgationBar_Height - 44, 44, 44)];
        cancelBtn.exclusiveTouch = YES;
        cancelBtn.tag = 100;
        cancelBtn.backgroundColor = [UIColor clearColor];
        UIImage *cancelImage = [VEHelp imageNamed:@"左上角叉_默认_@3x"];
        [cancelBtn setImage:cancelImage forState:UIControlStateNormal];
        _cancelBtn = cancelBtn;
        [self addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelExportAction) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cancelBtn.frame) + 10, CGRectGetWidth(frame), 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = UIColorFromRGB(0x131313);
        label.text = NSLocalizedString(@"努力导出中...", nil);
        [self addSubview:label];
        
        UILabel *desclabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), CGRectGetWidth(frame), 30)];
        desclabel.textAlignment = NSTextAlignmentCenter;
        desclabel.backgroundColor = [UIColor clearColor];
        desclabel.font = [UIFont boldSystemFontOfSize:13];
        desclabel.textColor = UIColorFromRGB(0x727272);
        desclabel.text = NSLocalizedString(@"请保持屏幕点亮，不要锁屏或切换程序", nil);
        [self addSubview:desclabel];
        
        float width = (CGRectGetWidth(frame) - 100);
        float height = width * (coverImage.size.height/coverImage.size.width);
        
        if(coverImage.size.width < coverImage.size.height){
            height = MIN(height, self.frame.size.height - CGRectGetMaxY(desclabel.frame) - kBottomSafeHeight - 240);
            width = height * (coverImage.size.width/coverImage.size.height);
        }
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - width)/2.0, CGRectGetMaxY(desclabel.frame) + ((coverImage.size.width < coverImage.size.height) ? 10 : 44), width, height)];
        _coverImageView.image = coverImage;
        
        [self addSubview:_coverImageView];
        
        UIImageView *borderView = [[UIImageView alloc] initWithFrame:_coverImageView.bounds];
        borderView.image = coverImage;
        borderView.layer.borderColor = UIColorFromRGB(0xcdd0d7).CGColor;
        borderView.layer.borderWidth = 6;
        [_coverImageView addSubview:borderView];
        {
            _progressLabel = [[UILabel alloc] initWithFrame:_coverImageView.bounds];
            _progressLabel.textAlignment = NSTextAlignmentCenter;
            _progressLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
            _progressLabel.font = [UIFont boldSystemFontOfSize:24];
            _progressLabel.textColor = UIColorFromRGB(0xFFFFFF);
            _progressLabel.text = NSLocalizedString(@"0%%", nil);
            [_coverImageView addSubview:_progressLabel];
        }
        
        {
            _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 6)];
            _topView.backgroundColor = UIColorFromRGB(0x131313);
            [_coverImageView addSubview:_topView];
            
            _rightView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_coverImageView.frame) - 6, 0, 6, 0)];
            _rightView.backgroundColor = UIColorFromRGB(0x131313);
            [_coverImageView addSubview:_rightView];
            
            _buttomView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_coverImageView.frame)-6, CGRectGetHeight(_coverImageView.frame)-6, 0, 6)];
            _buttomView.backgroundColor = UIColorFromRGB(0x131313);
            [_coverImageView addSubview:_buttomView];
            
            
            _leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6, 6, 0)];
            _leftView.backgroundColor = UIColorFromRGB(0x131313);
            [_coverImageView addSubview:_leftView];
            
            [self setProgress:0.0];
        }
    }
    return self;
}
- (void)setIsHiddenCancelBtn:(BOOL)isHiddenCancelBtn{
    _isHiddenCancelBtn = isHiddenCancelBtn;
    _cancelBtn.hidden = _isHiddenCancelBtn;
}
- (void)cancelExportAction{
    if(_cancelExportBlock){
        _cancelExportBlock();
    }
}

- (void)dismiss{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    [self removeFromSuperview];
    
}


- (void)setProgress:(double)progress{
    _progress = progress;
    _progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%02i%%", nil),(int)(_progress * 100)];
    float totalWidth = (_coverImageView.frame.size.width + _coverImageView.frame.size.height) * 2 - 6 * 4;
    
    float progressWidth = totalWidth * _progress;
    if(progressWidth < CGRectGetWidth(_coverImageView.frame)){
        _topView.frame = CGRectMake(0, 0, progressWidth, 6);
        _rightView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame) - 6, 0, 6, 0);
        _buttomView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame)-6, CGRectGetHeight(_coverImageView.frame)-6, 0, 6);
        _leftView.frame = CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6, 6, 0);
    }
    else if(progressWidth < CGRectGetWidth(_coverImageView.frame) + CGRectGetHeight(_coverImageView.frame)-6){
        float height = progressWidth - CGRectGetWidth(_coverImageView.frame);
        _topView.frame = CGRectMake(0, 0, CGRectGetWidth(_coverImageView.frame), 6);
        _rightView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame) - 6, 6, 6, height);
        _buttomView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame)-6, CGRectGetHeight(_coverImageView.frame)-6, 0, 6);
        _leftView.frame = CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6, 6, 0);
    }else if(progressWidth < CGRectGetWidth(_coverImageView.frame) + CGRectGetHeight(_coverImageView.frame) - 6 + CGRectGetWidth(_coverImageView.frame)-6){
        float width = progressWidth - CGRectGetWidth(_coverImageView.frame) - (CGRectGetHeight(_coverImageView.frame) - 6);
        _topView.frame = CGRectMake(0, 0, CGRectGetWidth(_coverImageView.frame), 6);
        _rightView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame) - 6, 6, 6, (CGRectGetHeight(_coverImageView.frame) - 6));
        _buttomView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame)-6 - width, CGRectGetHeight(_coverImageView.frame)-6, width, 6);
        _leftView.frame = CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6, 6, 0);
        
    }else{
        float height = progressWidth - CGRectGetWidth(_coverImageView.frame) - (CGRectGetHeight(_coverImageView.frame) - 6) - (CGRectGetWidth(_coverImageView.frame) - 6);
        
        _topView.frame = CGRectMake(0, 0, CGRectGetWidth(_coverImageView.frame), 6);
        _rightView.frame = CGRectMake(CGRectGetWidth(_coverImageView.frame) - 6, 6, 6, (CGRectGetHeight(_coverImageView.frame) - 6));
        _buttomView.frame = CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6, (CGRectGetWidth(_coverImageView.frame) - 6), 6);
        _leftView.frame = CGRectMake(0, CGRectGetHeight(_coverImageView.frame)-6 - height, 6, height);
    }
    
    
}

@end




@interface VEExportProgressView()
{
   UIView *_childrensView;
   
   UILabel *_trackprogressLabel;
   UIImageView *_trackbackGround;
   UIImageView *_trackprogress;
    float _progress;
}
@end
@implementation VEExportProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        
        CGRect childViewFrame = CGRectMake(40, (frame.size.height - 60)/2.0, frame.size.width - 80, 70);

        [self initChildrensView:childViewFrame];
        
        _canTouchUpCancel = NO;
    }
    return self;
}

- (void)initChildrensView:(CGRect )frame{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    if(!self.backgroundColor){
        self.backgroundColor = [UIColor clearColor];
    }
    _canTouchUpCancel = NO;
    _childrensView = [[UIView alloc] initWithFrame:frame];
    _childrensView.backgroundColor = [UIColor clearColor];
    _progressTitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(0,0, _childrensView.frame.size.width, 25)];
    _progressTitleLabel.textColor = [UIColor whiteColor];
    _progressTitleLabel.font = [UIFont systemFontOfSize:13];
    _progressTitleLabel.textAlignment = NSTextAlignmentCenter;
    _progressTitleLabel.text = VELocalizedString(@"视频导出中，请耐心等待...", nil);
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(_childrensView.frame.size.width - 44, (_childrensView.frame.size.height - 25 - 15 - 44)/2.0 + 25, 44, 44)];
    _cancelBtn.backgroundColor = [UIColor clearColor];
    _cancelBtn.imageEdgeInsets = UIEdgeInsetsMake((44-17)/2.0, (44-17)/2.0, (44-17)/2.0, (44-17)/2.0);
    [_cancelBtn setImage:[VEHelp imageNamed:@"next_jianji/ProgressImage/进度取消默认_"] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelExportAction) forControlEvents:UIControlEventTouchUpInside];
    
    _trackbackGround= [[UIImageView alloc] initWithFrame:CGRectMake(0, (_childrensView.frame.size.height - 25 - 15 - 4)/2.0 + 25, _cancelBtn.frame.origin.x - 20, 4)];
    if(_trackbackTintColor){
        _trackbackGround.backgroundColor = _trackbackTintColor;
    }
    if(_trackbackImage){
        _trackbackGround.image = _trackbackImage;
        _trackbackGround.contentMode = UIViewContentModeScaleAspectFill;
    }
    _trackbackGround.layer.masksToBounds = YES;
    
    _trackprogress = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 0, _trackbackGround.frame.size.height)];
    _trackprogress.backgroundColor = [UIColor clearColor];
    if(_trackprogressTintColor){
        _trackbackGround.backgroundColor = _trackprogressTintColor;
    }
    if(_trackprogressImag){
        _trackprogress.image = _trackprogressImag;
        _trackprogress.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    _trackprogressLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, _childrensView.frame.size.height - 15, _childrensView.frame.size.width, 15)];
    _trackprogressLabel.textColor = [UIColor whiteColor];
    _trackprogressLabel.font = [UIFont systemFontOfSize:17];
    _trackprogressLabel.textAlignment = NSTextAlignmentCenter;
    _trackprogressLabel.text = @"0.0%";

    [_childrensView addSubview:_progressTitleLabel];
    [_childrensView addSubview:_trackbackGround];
    [_trackbackGround addSubview:_trackprogress];
    [_childrensView addSubview:_trackprogressLabel];
    [_childrensView addSubview:_cancelBtn];
    
    [self addSubview:_childrensView];
    
    _trackbackGround.backgroundColor = UIColorFromRGB(0x888888);
    _trackprogress.backgroundColor = UIColorFromRGB(0xfed430);
    _trackbackGround.layer.cornerRadius = 2;
    _trackprogress.layer.cornerRadius = 2;
    _trackbackGround.layer.masksToBounds = YES;
    _trackprogress.layer.masksToBounds = YES;
}

- (void)setProgressTitle:(NSString *)progressTitle{
    _progressTitleLabel.text = progressTitle;

}
- (void)setProgress:(double)progress animated:(BOOL)animated{
    
    if(isnan(progress) || progress <0){
//        progress = 0.f;
        _trackprogressLabel.text = @"0.0%";
        return;
    }
    _progress = progress;
    
    float flag = animated ? 0.15:0.;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(animated){
            [UIView setAnimationsEnabled:YES];
            [UIView animateWithDuration:flag animations:^{
                if(self->_trackprogressLabel){
                    self->_trackprogress.frame = CGRectMake(0, 0, progress/100.0 * self->_trackbackGround.frame.size.width , self->_trackbackGround.frame.size.height);
                    @try {
                        self->_trackprogressLabel.text = [NSString stringWithFormat:@"%.1f%%",self->_progress];
                    } @catch (NSException *exception) {
                        NSLog(@"exception:%@",exception);
                    }
                }
            } completion:^(BOOL finished) {
            }];
        }
        else{
            if(self->_trackprogressLabel){
                @try {
                    self->_trackprogress.frame = CGRectMake(0, 0, progress/100.0 * MAX(self->_trackbackGround.frame.size.width, 0) , self->_trackbackGround.frame.size.height);
                    self->_trackprogressLabel.text = [NSString stringWithFormat:@"%.1f%%",MAX(self->_progress, 0)];
                } @catch (NSException *exception) {
                    NSLog(@"exception:%@",exception);
                }
            }
        }
        
   });
}

- (void)setProgress2:(double)progress animated:(BOOL)animated{
    
    if(isnan(progress) || progress <=0){
        progress = 0.f;
        _trackprogressLabel.text = @"0.0%";
    }
    _progress = progress;
    
    float flag = animated ? 0.15:0.;
    if(animated){
        [UIView setAnimationsEnabled:YES];
        [UIView animateWithDuration:flag animations:^{
            if(self->_trackprogressLabel){
                self->_trackprogress.frame = CGRectMake(0, 0, progress/100.0 * self->_trackbackGround.frame.size.width , self->_trackbackGround.frame.size.height);
                @try {
                    self->_trackprogressLabel.text = [NSString stringWithFormat:@"%.1f%%",self->_progress];
                } @catch (NSException *exception) {
                    NSLog(@"exception:%@",exception);
                }
            }
        } completion:^(BOOL finished) {
        }];
    }
    else{
        if(_trackprogressLabel){
            @try {
                _trackprogress.frame = CGRectMake(0, 0, progress/100.0 * MAX(_trackbackGround.frame.size.width, 0) , _trackbackGround.frame.size.height);
                _trackprogressLabel.text = [NSString stringWithFormat:@"%.1f%%",MAX(_progress, 0)];
            } @catch (NSException *exception) {
                NSLog(@"exception:%@",exception);
            }
        }
    }
        
}

- (void)setTrackbackImage:(UIImage *)trackbackImage{
    if(_trackbackGround && trackbackImage){
        _trackbackGround.image = trackbackImage;
        _trackbackGround.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)setTrackbackTintColor:(UIColor *)trackbackTintColor{
    if(!_trackbackGround && trackbackTintColor){
        _trackbackGround.backgroundColor = trackbackTintColor;
    }
}

- (void)setTrackprogressImag:(UIImage *)trackprogressImag{
    if(_trackprogress && trackprogressImag){
        _trackprogress.image = trackprogressImag;
        _trackprogress.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)setTrackprogressTintColor:(UIColor *)trackprogressTintColor{
    if(!_trackprogress && trackprogressTintColor){
        _trackprogress.backgroundColor = trackprogressTintColor;
    }
}

- (void)setIsHiddenCancelBtn:(BOOL)isHiddenCancelBtn {
    if (isHiddenCancelBtn) {
        [_cancelBtn removeFromSuperview];
        CGRect frame = _trackbackGround.frame;
        frame.size.width = _childrensView.frame.size.width;
        _trackbackGround.frame = frame;
    }
}

- (void)cancelExportAction{
    if(_cancelBtn.selected){
        return;
    }
    if((isnan(_progress) || _progress <=0) && !_canTouchUpCancel){
        return;
    }
    //_cancelBtn.selected = YES;
    if(_cancelExportBlock){
        _cancelExportBlock();
    }
    
    //[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelExportActionBlock) object:nil];
    //[self performSelector:@selector(cancelExportActionBlock) withObject:nil afterDelay:0.4];
}
- (void)cancelExportActionBlock{
    if(_cancelExportBlock){
        _cancelExportBlock();
    }
}

- (void)dismiss{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    [self removeFromSuperview];
    
}

//20170330
- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
