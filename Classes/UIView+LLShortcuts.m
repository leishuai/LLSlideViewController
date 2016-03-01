//
//  UIView+LLShortcuts.m
//  LLSlideViewController
//
//  Created by ll on 16/3/1.
//  Copyright © 2016年 ll. All rights reserved.
//

#import "UIView+LLShortcuts.h"

@implementation UIView (LLShortcuts)

- (void)removeSubviews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end
