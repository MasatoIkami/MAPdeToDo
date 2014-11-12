//
//  BlackStroke.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/12.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "BlackStroke.h"

@implementation BlackStroke

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
    
    CGContextSetStrokeColorWithColor(context, UIColor.orangeColor.CGColor);
    
    CGContextSetLineWidth(context, 2.5);
    
    CGContextMoveToPoint(context, 0, 0);  // 始点
    CGContextAddLineToPoint(context, 100, 200); // 終点
    CGContextStrokePath(context);  // 描画
}

@end
