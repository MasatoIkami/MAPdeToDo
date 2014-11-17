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
    
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    // NSLog(@"LINESIZE: %f, %f, %f, %f", x, y, w, h);
    
    UIBezierPath *context = [UIBezierPath bezierPath];
    
    [[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:0.5] set ];
    [context setLineWidth:2.5f];
    
    // 点線のパターンをセット
    CGFloat dashPattern[2] = {5.0f, 2.0f};
    [context setLineDash:dashPattern count:2 phase:0];
    
    if ( x < 160.0 ){
        if ( y < 284 ) {
            
            [context moveToPoint:CGPointMake(0,0)];
            [context addLineToPoint:CGPointMake(w, h)];
            
        }else{
            
            [context moveToPoint:CGPointMake(w,0)];
            [context addLineToPoint:CGPointMake(0, h)];
        }
    }
    else{
        if (y < 284) {
            [context moveToPoint:CGPointMake(w,0)];
            [context addLineToPoint:CGPointMake(0, h)];
        }else{
            [context moveToPoint:CGPointMake(0,0)];
            [context addLineToPoint:CGPointMake(w, h)];
        }
    }
    
    [context stroke];  // 描画
}

@end
