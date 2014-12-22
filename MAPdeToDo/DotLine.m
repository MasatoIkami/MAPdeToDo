//
//  DotLine.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/14.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "DotLine.h"
#import "AppDelegate.h"

@implementation DotLine

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
    //NSLog(@"LINESIZE: %f, %f, %f, %f", x, y, w, h);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, UIColor.orangeColor.CGColor);
    
    CGContextSetLineWidth(context, 2.5);
    
    // グローバル変数のカプセル化
    AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( x < basic.basicX ){
        if ( y < basic.basicY ) {
            
            CGContextMoveToPoint(context, 0, 0);  // 始点
            CGContextAddLineToPoint(context, w, h); // 終点
            
        }else{
            
            CGContextMoveToPoint(context, w, 0); // 始点
            CGContextAddLineToPoint(context, 0, h); // 終点
        }
    }
    else{
        if (y < basic.basicY) {
            
            CGContextMoveToPoint(context, w, 0); // 始点
            CGContextAddLineToPoint(context, 0, h); // 終点
            
        }else{
            
            CGContextMoveToPoint(context, 0, 0);  // 始点
            CGContextAddLineToPoint(context, w, h); // 終点
            
        }
    }
    
    CGContextStrokePath(context);  // 描画
}

@end
