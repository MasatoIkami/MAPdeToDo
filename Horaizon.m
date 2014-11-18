//
//  Horaizon.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/18.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "Horaizon.h"

@implementation Horaizon

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = UIColor.clearColor;
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextSetLineWidth(context, 1.5f);
    CGContextMoveToPoint(context, 0, 20);  // 始点
    CGContextAddLineToPoint(context, 320, 20); // 終点
    CGContextStrokePath(context);  // 描画
    
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context1, UIColor.blackColor.CGColor);
    CGContextSetLineWidth(context1, 1.5f);
    CGContextMoveToPoint(context1, 0, 528);  // 始点
    CGContextAddLineToPoint(context1, 320, 528); // 終点
    CGContextStrokePath(context1);  // 描画
}

@end
