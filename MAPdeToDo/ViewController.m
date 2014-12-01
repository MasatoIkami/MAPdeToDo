//
//  ViewController.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/04.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "ViewController.h"
#import "BlackStroke.h" // 点線を描くビュー
#import "DotLine.h" // 実線を描くビュー
#import "Horaizon.h" // 境界線を描くビュー

@interface ViewController (){
    
    DotLine *_previous_dt;
    BlackStroke *_previous_bs;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createNewMapBtn]; // 真ん中ボタンかつラベル作成ボタン
    [self createDeleteImage]; // ゴミ箱
    [self createSettingButton]; // 設定
    [self createallDeleteBtn]; // 全削除ボタン
    [self createHoraizon]; // 境界線作成
    
    [self createbackView]; // バックビューを下に表示
    
    [self loadFromUserdefaults]; // データを読み出す
    NSLog(@"%@", _LabelArray);
    
    // 記憶したラベルと線を表示
    if (_LabelArray != nil) {
        for (int i = 0; i < _LabelArray.count; i++){
        
            NSDictionary *tmp = [[NSDictionary alloc] init];
            tmp = [_LabelArray objectAtIndex:i];
            NSString *name = [tmp objectForKey:@"name"];
            float x = [[tmp objectForKey:@"x"] floatValue];
            float y = [[tmp objectForKey:@"y"] floatValue];
            float w = [[tmp objectForKey:@"w"] floatValue];
            float h = [[tmp objectForKey:@"h"] floatValue];
            NSInteger num = [[tmp objectForKey:@"id"] intValue];
            
            //NSLog(@"ラベル中身 %f, %f, %f, %f" , x,y,w,h);
        
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
            label.text = name;
            //ラベルのカラー指定
            label.textColor = [UIColor whiteColor];
            label.shadowColor = [UIColor grayColor];
            label.shadowOffset = CGSizeMake(0.5, 0.5);
        
            //ラベルの背景色を黒に指定
            label.backgroundColor = [UIColor greenColor];
            label.layer.borderColor = [UIColor orangeColor].CGColor;
            label.layer.borderWidth = 1.5f;
            //ラベルの角丸指定
            [[label layer] setCornerRadius:8.0];
            //ラベルのはみ出しを許可するか
            [label setClipsToBounds:YES];
        
            //タッチの検知をするか
            label.userInteractionEnabled = YES;
            //タッチ機能の追加
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:withEvent:)]];
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesMoved:withEvent:)]];
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesEnded:withEvent:)]];
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesCancelled:withEvent:)]];
        
            label.tag = num;
            [self.view addSubview:label];
            [self.view bringSubviewToFront:label];
            
            //線を表示
            float lx = [[tmp objectForKey:@"linex"] floatValue];
            float ly = [[tmp objectForKey:@"liney"] floatValue];
            float lw = [[tmp objectForKey:@"linew"] floatValue];
            float lh = [[tmp objectForKey:@"lineh"] floatValue];
            
            DotLine *dt = [[DotLine alloc] init];
            dt.frame = CGRectMake(lx, ly, lw, lh);
            [self.view addSubview:dt];
            [self.view sendSubviewToBack:dt];
            
            _previous_dt = dt;

        }
        
    }
    
    //ビューの初期化時にジェスチャをself.viewに登録
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    
    t = @"TEST";
}

// 境界線の設定
- (void)createHoraizon{
    
    Horaizon *view = [[Horaizon alloc] init];
    view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    
}

// MAPdeToDoという名のラベル作成ボタンを作成
- (void)createNewMapBtn{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *NewMapBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height / 2 - 35, 70, 70)];
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定1
    [NewMapBtn setTitle:@"   MAP   \n    de    \n   ToDo   " forState:UIControlStateNormal];
    NewMapBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NewMapBtn.titleLabel.numberOfLines = 3;
    NewMapBtn.titleLabel.textColor = [UIColor blackColor];
    [NewMapBtn.layer setBackgroundColor:[[UIColor greenColor] CGColor]];
    [NewMapBtn setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    NewMapBtn.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [[NewMapBtn layer] setCornerRadius:15];
    [[NewMapBtn layer] setBorderColor:[[UIColor orangeColor] CGColor]];
    [[NewMapBtn layer] setBorderWidth:1.5f];
    
    [NewMapBtn addTarget:self action:@selector(tapNewMapBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:NewMapBtn];
    
}

// ラベル作成ボタンがタップされた時
- (void)tapNewMapBtn:(UIButton *)NewMapButton{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    _backView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView commitAnimations];
}

// 設定ボタンがタップされた時
- (void)tapSettingBtn:(UIButton *)SettingButton{
    NSLog(@"Set");
}

// ゴミ箱イメージ作成
- (void)createDeleteImage{
    
    UIImageView *DeleteImg = [[UIImageView alloc] init];
    [DeleteImg setFrame:CGRectMake(self.view.bounds.size.width / 2 - 30, self.view.bounds.size.height - 35, 60, 30)];
    
    UIImage *img = [UIImage imageNamed:@"l03.jpg"];
    
    [DeleteImg setImage:img];
    
    [self.view addSubview:DeleteImg]; // ビューへ表示
    [self.view sendSubviewToBack:DeleteImg];
}

// 設定ボタン作成
- (void)createSettingButton{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *SettingButton = [[UIButton alloc] init]; // ボタン初期化
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定
    [SettingButton setTitle:@"設定" forState:UIControlStateNormal]; // ボタンに文字を設定
    [SettingButton setTitleColor:[UIColor colorWithRed:0.19215 green:0.760784 blue:0.952941 alpha:1.0] forState:UIControlStateNormal]; // 色、透明度の設定
    SettingButton.frame = CGRectMake(20, self.view.bounds.size.height - 30, 40, 20); // フレーム設定
    
    [SettingButton addTarget:self action:@selector(tapSettingBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [self.view addSubview:SettingButton]; // ビューへ表示
    
}
// ラベル作成画面の追加
- (void)createbackView{
    
    /* -------------------- バックビューの作成 -------------------- */
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
    _backView.backgroundColor = [UIColor blueColor];
    _backView.alpha = 0.2;
    
    [self.view addSubview:_backView];
    
    /* -------------------- 戻るボタン -------------------- */
    _returnBtn = [[UIButton alloc] init]; // ボタン初期化
    [_returnBtn setTitle:@"戻る" forState:UIControlStateNormal]; // ボタンに文字を設定
    _returnBtn.backgroundColor = [UIColor blackColor];
    _returnBtn.alpha = 1.0;// 色、透明度の設定
    _returnBtn.frame = CGRectMake(_backView.bounds.size.width / 2 - 30, _backView.bounds.size.height - 85, 80, 40); // フレーム設定
    
    [_returnBtn addTarget:self action:@selector(tapreturnBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [_backView addSubview:_returnBtn]; // ビューへ表示
    
    /* -------------------- 決定ボタン -------------------- */
    _decideBtn = [[UIButton alloc] init]; // ボタン初期化
    [_decideBtn setTitle:@"決定" forState:UIControlStateNormal]; // ボタンに文字を設定
    _decideBtn.backgroundColor = [UIColor blackColor];
    _decideBtn.alpha = 1.0;// 色、透明度の設定
    _decideBtn.frame = CGRectMake(_backView.bounds.size.width / 2 + 60, _backView.bounds.size.height - 85, 80, 40); // フレーム設定
    
    [_decideBtn addTarget:self action:@selector(tapdecideBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [_backView addSubview:_decideBtn]; // ビューへ表示

    /* -------------------- 説明文作成 -------------------- */
    UILabel *explain = [[UILabel alloc]initWithFrame:CGRectMake(40, 50, 240, 60)];
    explain.text = @"ラベル名を入力してください。";
    explain.textColor = [UIColor colorWithRed:0.502 green:0 blue:0 alpha:1.0];;
    [_backView addSubview:explain];
    
    /* -------------------- テキストフォールド作成 --------------------- */
    _ListTField = [[UITextField alloc] initWithFrame:CGRectMake(40, 100, 240, 30)];
    
    _ListTField.backgroundColor = [UIColor grayColor];
    
    [_ListTField addTarget:self action:@selector(tapReturnList:) forControlEvents:
     UIControlEventEditingDidEndOnExit];
    
    [_backView addSubview:_ListTField];
}

- (void)tapReturnList:(UITextField *)ListTTield{}

//シングルタップされたらresignFirstResponderでキーボードを閉じる
-(void)onSingleTap:(UITapGestureRecognizer *)recognizer{
    [_ListTField resignFirstResponder];
}

//キーボードを表示していない時は、他のジェスチャに影響を与えないように無効化しておく。
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.singleTap) {
        // キーボード表示中のみ有効
        if (_ListTField.isFirstResponder) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

// 戻るボタンが押された時
- (void)tapreturnBtn:(UIButton *)_returnBtn{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    _backView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView commitAnimations];
}

// 決定ボタンが押された時
- (void)tapdecideBtn:(UIButton *)_decideBtn{

    NSInteger i;

    [self loadFromUserdefaults];
    // 全削除ボタン押した時iと配列の初期化
    if (_LabelArray == nil) {
        i = 0;
        _LabelArray = [[NSMutableArray alloc] init];
    }
    // 存在時はidをiに入れる
    else {
        NSDictionary *tmp = [[NSDictionary alloc] init];
        tmp = [_LabelArray objectAtIndex:_LabelArray.count - 1];
        i = [[tmp objectForKey:@"id"] intValue];
    }
    
    // idカウントを+1
    i = i + 1;
    
    // 配列の初期化
    _basicData = [[NSDictionary alloc] init];
    // 名前とidだけを配列に格納
    _basicData = [NSDictionary dictionaryWithObjectsAndKeys:
                               _ListTField.text, @"name",
                               [NSNumber numberWithInt:i], @"id",
                               nil];

    // ラベル作成と同時に位置座標データの保存
    UILabel *Label = [self createLabel:_ListTField.text];
    Label.tag = i;
    [self.view addSubview:Label];
    [self.view bringSubviewToFront:Label];
    
    //確認用
    [self loadFromUserdefaults];
    NSLog(@"%@", _LabelArray);
    
    // バックビューを閉じる
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _backView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView commitAnimations];
    
}
// ラベル作成メソッド
- (UILabel *)createLabel:(NSString *)name{
    
    UILabel *label = [[UILabel alloc] init];
    
    label.center = CGPointMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height / 2 - 30);
    label.text = name;
    CGSize bounds = CGSizeMake(label.frame.size.width, 200);
    UIFont *font = label.font;
    UILineBreakMode mode = label.lineBreakMode;
    CGSize size;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect rect
        = [label.text boundingRectWithSize:bounds
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
        size = rect.size;
    }
    else {
        CGSize size = [label.text sizeWithFont:font
                                 constrainedToSize:bounds
                                     lineBreakMode:mode];
    }
    size.width  = ceilf(size.width);
    size.height = ceilf(size.height);
    NSLog(@"size: %@", NSStringFromCGSize(size));
    
    label.frame = CGRectMake(label.frame.origin.x,
                                 label.frame.origin.y,
                                 size.width, size.height);
    
    //ラベルのカラー指定
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.5, 0.5);
    //ラベルの背景色を黒に指定
    label.backgroundColor = [UIColor greenColor];
    label.layer.borderColor = [UIColor orangeColor].CGColor;
    label.layer.borderWidth = 1.5f;
    //ラベルの角丸指定
    [[label layer] setCornerRadius:8.0];
    //ラベルのはみ出しを許可するか
    [label setClipsToBounds:YES];
    
    //タッチの検知をするか
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:withEvent:)]];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesMoved:withEvent:)]];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesEnded:withEvent:)]];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesCancelled:withEvent:)]];
    
    // ユーザデフォルトへのデータ保存
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setDictionary:_basicData];
    
    [tmpDic setObject:[NSNumber numberWithFloat:label.frame.origin.x] forKey:@"x"];
    [tmpDic setObject:[NSNumber numberWithFloat:label.frame.origin.y] forKey:@"y"];
    [tmpDic setObject:[NSNumber numberWithFloat:size.width] forKey:@"w"];
    [tmpDic setObject:[NSNumber numberWithFloat:size.height] forKey:@"h"];
    [_LabelArray addObject:tmpDic];
    [self saveToUserDefaults];
    
    return label;
}

// ラベルがタッチされた時
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

  /*  UITouch *touch = [[event allTouches] anyObject];
    
    UILabel *tch = (UILabel *)[touch view]; // タッチされたビューをラベルとして認識

    if (tch.tag > 0)
        NSLog(@"%ld", tch.tag);
    else
        NSLog(@"others"); */
}

// ラベルが動かされた時 位置情報を取得しつつ点線を表示
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    UILabel *sptchlabel = (UILabel *)[touch view];
    if (sptchlabel.tag > 0){
        
        [_previous_bs removeFromSuperview];
        
        CGPoint location = [touch locationInView:self.view];
        sptchlabel.center = location;
        
        float x1 = sptchlabel.frame.origin.x;
        float y1 = sptchlabel.frame.origin.y;
        float w1 = sptchlabel.frame.size.width;
        float h1 = sptchlabel.frame.size.height;
        
        BlackStroke *bs = [[BlackStroke alloc] init];
        float r1 = sqrtf((160 - (x1 + w1 / 2)) * (160 - (x1 + w1 / 2)) + (284 - (y1 + h1 / 2)) * (284 - (y1 + h1 / 2)));
        float r2 = sqrtf((160 - (x1 + w1 / 2)) * (160 - (x1 + w1 / 2)) + ((y1 + h1 / 2) - 284) * ((y1 + h1 / 2) - 284));
        float r3 = sqrtf(((x1 + w1 / 2) - 160) * ((x1 + w1 / 2) - 160) + (284 - (y1 + h1 / 2)) * (284 - (y1 + h1 / 2)));
        float r4 = sqrtf(((x1 + w1 / 2) - 160) * ((x1 + w1 / 2) - 160) + ((y1 + h1 / 2) - 284) * ((y1 + h1 / 2) - 284));
        
        if ( x1 < 160.0 ){
            if ( y1 < 284.0 ){ //左上
                
                if (r1 < 180)
                    bs.frame = CGRectMake(x1 + w1 / 2, y1 + h1 / 2, 160 - (x1 + w1 / 2), 284 - (y1 + h1 / 2));
            }
            else{ // 左下
                if (r2 < 180)
                    bs.frame = CGRectMake(x1 + w1 / 2, 284, 160 - (x1 + w1 / 2), (y1 + h1 / 2) - 284);
            }
        }
        else{
            if ( y1 < 284.0 ){ // 右上
                
                if (r3 < 180)
                    bs.frame = CGRectMake(160, y1 + h1 / 2, (x1 + w1 / 2) - 160, 284 - (y1 + h1 / 2));
            }
            else{ // 右下
                
                if (r4 < 180)
                    bs.frame = CGRectMake(160, 284, (x1 + w1 / 2) - 160, (y1 + h1 / 2) - 284);
            }
        }
        
        [self.view addSubview:bs];
        [self.view sendSubviewToBack:bs];
        
        _previous_bs = bs;

    }
}

// ラベルが指から離された時
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    UILabel *sptchlabel = (UILabel *)[touch view];
    
    if (sptchlabel.tag > 0){
        [_previous_bs removeFromSuperview];
        [_previous_dt removeFromSuperview];
        
        CGPoint location = [touch locationInView:self.view];
        
        if (location.y < 30){
            sptchlabel.center = CGPointMake(location.x, 30);
        }
        else if (location.y > 518){
            sptchlabel.center = CGPointMake(location.x, 518);
        }
        
        else if (location.x > 125 && 195 > location.x && location.y > 249 && 319 > location.y){
            sptchlabel.center = CGPointMake(160, 219);
        }
        
        else sptchlabel.center = location;
        
        
        float x1 = sptchlabel.frame.origin.x;
        float y1 = sptchlabel.frame.origin.y;
        float w1 = sptchlabel.frame.size.width;
        float h1 = sptchlabel.frame.size.height;
        
        // ユーザデフォルトへのデータ保存
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setDictionary:_basicData];
        
        [tmpDic setObject:[NSNumber numberWithFloat:x1] forKey:@"x"];
        [tmpDic setObject:[NSNumber numberWithFloat:y1] forKey:@"y"];
        [tmpDic setObject:[NSNumber numberWithFloat:w1] forKey:@"w"];
        [tmpDic setObject:[NSNumber numberWithFloat:h1] forKey:@"h"];

        // 線の表示
        DotLine *dt = [[DotLine alloc] init];
        float r1 = sqrtf((160 - (x1 + w1 / 2)) * (160 - (x1 + w1 / 2)) + (284 - (y1 + h1 / 2)) * (284 - (y1 + h1 / 2)));
        float r2 = sqrtf((160 - (x1 + w1 / 2)) * (160 - (x1 + w1 / 2)) + ((y1 + h1 / 2) - 284) * ((y1 + h1 / 2) - 284));
        float r3 = sqrtf(((x1 + w1 / 2) - 160) * ((x1 + w1 / 2) - 160) + (284 - (y1 + h1 / 2)) * (284 - (y1 + h1 / 2)));
        float r4 = sqrtf(((x1 + w1 / 2) - 160) * ((x1 + w1 / 2) - 160) + ((y1 + h1 / 2) - 284) * ((y1 + h1 / 2) - 284));
        
        if ( x1 < 160.0 ){
            if ( y1 < 284.0 ){ //左上
                if (r1 < 180){
                    
                    dt.frame = CGRectMake(x1 + w1 / 2, y1 + h1 / 2, 160 - (x1 + w1 / 2), 284 - (y1 + h1 / 2));
                    float lx = x1 + w1 / 2;
                    float ly = y1 + h1 / 2;
                    float lw = 160 - (x1 + w1 / 2);
                    float lh = 284 - (y1 + h1 / 2);
                    
                    [tmpDic setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                    [tmpDic setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
                }
            }
            else{ // 左下
                if (r2 < 180){
                    
                    dt.frame = CGRectMake(x1 + w1 / 2, 284, 160 - (x1 + w1 / 2), (y1 + h1 / 2) - 284);
                    float lx = x1 + w1 / 2;
                    float ly = 284;
                    float lw = 160 - (x1 + w1 / 2);
                    float lh = (y1 + h1 / 2) - 284;
                    
                    [tmpDic setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                    [tmpDic setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
                }
            }
        }
        else{
            if ( y1 < 284.0 ){ // 右上
                if (r3 < 180){
                    
                    dt.frame = CGRectMake(160, y1 + h1 / 2, (x1 + w1 / 2) - 160, 284 - (y1 + h1 / 2));
                    float lx = 160;
                    float ly = y1 + h1 / 2;
                    float lw = (x1 + w1 / 2) - 160;
                    float lh = 284 - (y1 + h1 / 2);
                    
                    [tmpDic setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                    [tmpDic setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
                  }
            }
            else{ // 右下
                
                if (r4 < 180){
                    
                    dt.frame = CGRectMake(160, 284, (x1 + w1 / 2) - 160, (y1 + h1 / 2) - 284);
                    float lx = 160;
                    float ly = 284;
                    float lw = (x1 + w1 / 2) - 160;
                    float lh = (y1 + h1 / 2) - 284;
                    
                    [tmpDic setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                    [tmpDic setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                    [tmpDic setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
                }
            }
        }
        
        NSLog(@"tmpdic%@", tmpDic);
        [_LabelArray replaceObjectAtIndex:sptchlabel.tag-1 withObject:tmpDic];
        
        [self saveToUserDefaults];
        
        [self.view addSubview:dt];
        [self.view sendSubviewToBack:dt];
        
        _previous_dt = dt;
        
    }
}

// 電話等緊急時の時
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

// 全削除ボタンの作成
- (void)createallDeleteBtn{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *AllDeleteButton = [[UIButton alloc] init]; // ボタン初期化
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定
    [AllDeleteButton setTitle:@"全削除" forState:UIControlStateNormal]; // ボタンに文字を設定
    [AllDeleteButton setTitleColor:[UIColor colorWithRed:0.19215 green:0.760784 blue:0.952941 alpha:1.0] forState:UIControlStateNormal]; // 色、透明度の設定
    AllDeleteButton.frame = CGRectMake(self.view.bounds.size.width - 70, self.view.bounds.size.height - 30, 60, 20); // フレーム設定
    
    [AllDeleteButton addTarget:self action:@selector(tapADBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [self.view addSubview:AllDeleteButton]; // ビューへ表示
}

// 全削除ボタンのタップ時のポップアップ
- (void)tapADBtn:(UIButton *)AllDeleteButton{
    UIAlertView *ADalert = [[UIAlertView alloc] initWithTitle:@"全てのデータを削除しますか？"
                                                      message:@"この作業は戻せません。"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"全削除", nil];
    [ADalert show];
}

// 全削除ポップアップのボタン選択時の動作
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [_LabelArray removeAllObjects];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        NSLog(@"%@", _LabelArray);
        
    }
    else{
        return;
    }
}

// ユーザデフォルトに保存
- (void)saveToUserDefaults{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *labelData = [NSKeyedArchiver archivedDataWithRootObject:_LabelArray];
    [userDefaults setObject:labelData forKey:@"LABEL_KEY"];
    [userDefaults synchronize];
}

// ユーザデフォルトから読み出し
- (void)loadFromUserdefaults{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _LabelArray = [[NSMutableArray alloc] init];
    
    NSData *labelData = [userDefaults objectForKey:@"LABEL_KEY"];
    _LabelArray = [NSKeyedUnarchiver unarchiveObjectWithData:labelData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

