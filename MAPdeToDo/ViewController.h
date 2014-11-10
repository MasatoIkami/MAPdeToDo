//
//  ViewController.h
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/04.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>{
    
    UIView *_backView;
    UIButton *_returnBtn;
    UIButton *_decideBtn;
    UITextField *_ListTField;
    
    NSMutableArray *_LabelArray;
    
    UILabel *_NewLabel;
    
}

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

