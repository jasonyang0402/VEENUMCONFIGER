//
//  UIButton+VECustomLayout.m
//  VEENUMCONFIGER
//
//  Created by iOS VESDK Team on 2019/6/5.
//  Copyright © 2019 iOS VESDK Team. All rights reserved.
//

#import "UIButton+VECustomLayout.h"
#import <objc/runtime.h>

@interface UIButton (VECustomLayout)

@property (nonatomic, strong) NSString *prevAction;

@end

@implementation UIButton (VECustomLayout)

+ (void)load{
    Method systemMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    SEL sysSEL = @selector(sendAction:to:forEvent:);
    
    Method customMethod = class_getInstanceMethod(self, @selector(custom_sendAction:to:forEvent:));
    SEL customSEL = @selector(custom_sendAction:to:forEvent:);
    
    //添加方法 语法：BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types) 若添加成功则返回No
    // cls：被添加方法的类  name：被添加方法方法名  imp：被添加方法的实现函数  types：被添加方法的实现函数的返回值类型和参数类型的字符串
    BOOL didAddMethod = class_addMethod(self, sysSEL, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
    
    //如果系统中该方法已经存在了，则替换系统的方法  语法：IMP class_replaceMethod(Class cls, SEL name, IMP imp,const char *types)
    if (didAddMethod) {
        class_replaceMethod(self, customSEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, customMethod);
        
    }
}

- (NSTimeInterval )custom_acceptEventInterval{
    return [objc_getAssociatedObject(self, "UIControl_acceptEventInterval") doubleValue];
}

- (void)setCustom_acceptEventInterval:(NSTimeInterval)custom_acceptEventInterval{
    objc_setAssociatedObject(self, "UIControl_acceptEventInterval", @(custom_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval )custom_acceptEventTime{
    return [objc_getAssociatedObject(self, "UIControl_acceptEventTime") doubleValue];
}

- (void)setCustom_acceptEventTime:(NSTimeInterval)custom_acceptEventTime{
    objc_setAssociatedObject(self, "UIControl_acceptEventTime", @(custom_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPrevAction:(NSString *)prevAction
{
    objc_setAssociatedObject(self, "UIControl_prevAction", prevAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)prevAction
{
    NSString *error = objc_getAssociatedObject(self, "UIControl_prevAction");
    return error;
}

- (void)custom_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    // 如果想要设置统一的间隔时间，可以在此处加上以下几句
    // 值得提醒一下：如果这里设置了统一的时间间隔，只会影响UIButton, 如果想统一设置，也想影响UISwitch，建议将UIButton分类，改成UIControl分类，实现方法是一样的
     if (self.custom_acceptEventInterval <= 0) {
         // 如果没有自定义时间间隔，则默认为.4秒
        self.custom_acceptEventInterval = .4;
     }
    
    // 是否小于设定的时间间隔
    BOOL needSendAction = (NSDate.date.timeIntervalSince1970 - self.custom_acceptEventTime >= self.custom_acceptEventInterval);
    
    // 更新上一次点击时间戳
    if (self.custom_acceptEventInterval > 0) {
        self.custom_acceptEventTime = NSDate.date.timeIntervalSince1970;
    }
    // 两次点击的时间间隔小于设定的时间间隔时，才执行响应事件
    if (needSendAction
         || ![NSStringFromSelector(action) isEqualToString:self.prevAction]) {//20230413 修复bug：一个按钮有多个事件，两个事件间隔时间段，后面的事件会无效
        [self custom_sendAction:action to:target forEvent:event];
        self.prevAction = NSStringFromSelector(action);
    }
}

- (void)layoutButtonWithEdgeInsetsStyle:(VEButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space {
    /** 同时有image和label的情况，
     *  image的上左下是相对于button，右边是相对于label的；
     *  title的上右下是相对于button，左边是相对于image的。
     */
    
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;
    if (labelWidth > self.frame.size.width && self.titleLabel.numberOfLines == 0) {
        NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
        attrDict[NSFontAttributeName] = self.titleLabel.font;
        CGSize size = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
        labelWidth = size.width;
        labelHeight = size.height;
    }
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    switch (style) {
        case VEButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case VEButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case VEButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case VEButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

@end
