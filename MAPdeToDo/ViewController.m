//
//  ViewController.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/04.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BlackStroke.h" // 点線を描くビュー
#import "DotLine.h" // 実線を描くビュー
#import "Horaizon.h" // 境界線を描くビュー

@interface ViewController (){
    
    DotLine *_previous_dt;
    BlackStroke *_previous_bs;
    
    NSMutableArray *_dt_array; // 初期に描画した線を保存する配列
    NSMutableArray *_labelObject_array; // 描画したラベルを保存する配列

    DotLine *_previous_list_dt;
    BlackStroke *_previous_list_bs;
    
    NSMutableArray *_listObject_array; // 描画したリストを保存する配列
    NSMutableArray *_dt_listarray; // 初期に描画したリストの線を保存する配列
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _Flag = NO;
    
    /* -------------------- 第一画面の配置 -------------------- */
    [self createNewMapBtn]; // 真ん中ボタンかつラベル作成ボタン
    [self createDeleteImage]; // ゴミ箱
    [self createSettingButton]; // 設定
    [self createallDeleteBtn]; // 全削除ボタン
    [self createHoraizon]; // 境界線作成
    [self createbackView]; // バックビューを下に表示
    
    
    /* -------------------- データ読み出しとユーザ作成物の表示 -------------------- */
    _dt_array = [[NSMutableArray alloc] init];
    _labelObject_array = [[NSMutableArray alloc] init];
    
    _dt_listarray = [[NSMutableArray alloc] init];
    _listObject_array = [[NSMutableArray alloc] init];
    
    [self indicateLabelLine]; // 記憶したラベルと線を表示

    _previous_dt = nil;
    
    /* -------------------- ビューの初期化時にジェスチャをself.viewに登録 -------------------- */
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    
    
    t = @"TEST"; // NSLog用変数
    
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

// 起動時にラベルと線を描画するメソッド
- (void)indicateLabelLine{
    
    [self loadFromUserdefaults]; // データを読み出す
    NSLog(@"%@", _LabelArray);
    
    if (_LabelArray.count != 0) {
        for (int i = 0; i < _LabelArray.count; i++){
            
            // 必要なデータ取り出し
            NSDictionary *tmp = [[NSDictionary alloc] init];
            tmp = [_LabelArray objectAtIndex:i];
            NSString *name = [tmp objectForKey:@"name"];
            float x = [[tmp objectForKey:@"x"] floatValue];
            float y = [[tmp objectForKey:@"y"] floatValue];
            float w = [[tmp objectForKey:@"w"] floatValue];
            float h = [[tmp objectForKey:@"h"] floatValue];
            NSInteger num = [[tmp objectForKey:@"id"] integerValue];
            
            
            UILabel *label;
            // 位置と名前付け
            label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
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
            
            // 長押し検知
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(handleLongPressGesture:)];
            longPressGesture.minimumPressDuration = 0.8f;
            [label addGestureRecognizer:longPressGesture];
            
            // ラベルのid付け
            label.tag = num;
            
            // 表示する
            [self.view addSubview:label];
            [self.view bringSubviewToFront:label];
            
            // 線情報を取得
            float lx = [[tmp objectForKey:@"linex"] floatValue];
            float ly = [[tmp objectForKey:@"liney"] floatValue];
            float lw = [[tmp objectForKey:@"linew"] floatValue];
            float lh = [[tmp objectForKey:@"lineh"] floatValue];
            
            // 線を表示
            DotLine *dt = [[DotLine alloc] init];
            dt.frame = CGRectMake(lx, ly, lw, lh);
            [self.view addSubview:dt];
            [self.view sendSubviewToBack:dt];
            
            _previous_dt = dt;
            
            // 線とラベルを配列に保存(_LabelArrayのインデックス順)
            [_labelObject_array addObject:label];
            [_dt_array addObject:_previous_dt];
            
            NSArray *Atmp = [[NSArray alloc] init];
            Atmp = [tmp objectForKey:@"List"];
            
            for(int li = 0; li < Atmp.count; li++){
                
                NSDictionary *Dtmp = [[NSDictionary alloc] init];
                Dtmp = [Atmp objectAtIndex:li];
                
                NSString *listname = [Dtmp objectForKey:@"name"];
                float listx = [[Dtmp objectForKey:@"x"] floatValue];
                float listy = [[Dtmp objectForKey:@"y"] floatValue];
                float listw = [[Dtmp objectForKey:@"w"] floatValue];
                float listh = [[Dtmp objectForKey:@"h"] floatValue];
                NSInteger listnum = [[Dtmp objectForKey:@"id"] integerValue];
                
                UILabel *list = [[UILabel alloc] initWithFrame:CGRectMake(listx, listy, listw, listh)];
                list.text = listname;
                list.tag = listnum;
                
                //ラベルのカラー指定
                list.textColor = [UIColor grayColor];
                list.shadowColor = [UIColor grayColor];
                list.shadowOffset = CGSizeMake(0.5, 0.5);
                
                //ラベルの背景色を黒に指定
                list.backgroundColor = [UIColor yellowColor];
                list.layer.borderColor = [UIColor orangeColor].CGColor;
                list.layer.borderWidth = 1.5f;
                //ラベルの角丸指定
                [[list layer] setCornerRadius:8.0];
                //ラベルのはみ出しを許可するか
                [list setClipsToBounds:YES];
                
                //タッチの検知をするか
                list.userInteractionEnabled = YES;
                
                // 長押し検知
                UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                                  initWithTarget:self
                                                                  action:@selector(handleLongPressGesture:)];
                longPressGesture.minimumPressDuration = 0.8f;
                [list addGestureRecognizer:longPressGesture];
                
                // 表示する
                [self.view addSubview:list];
                [self.view bringSubviewToFront:list];
                
                // リスト線の描画
                float llx = [[Dtmp objectForKey:@"linex"] floatValue];
                float lly = [[Dtmp objectForKey:@"liney"] floatValue];
                float llw = [[Dtmp objectForKey:@"linew"] floatValue];
                float llh = [[Dtmp objectForKey:@"lineh"] floatValue];
                
                AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                basic.basicX = x + w / 2;
                basic.basicY = y + h / 2;
                
                DotLine *dt = [[DotLine alloc] init];
                dt.frame = CGRectMake(llx, lly, llw, llh);
                
                [self.view addSubview:dt];
                [self.view sendSubviewToBack:dt];
                
                _previous_list_dt = dt;
                
                [_listObject_array addObject:list];
                [_dt_listarray addObject:_previous_list_dt];
            }
        }
    }
}

// インデックス計算用メソッド
- (NSInteger)calcNewIndex:(UILabel *)checkLabel{
    
    NSInteger NewIndex = 0;
    NSInteger i;
    
    for (NSDictionary *tmpdic in _LabelArray){
        
        i = [[tmpdic objectForKey:@"id"] integerValue];
        if (checkLabel.tag == i)
            break;
        NewIndex++;
        
    }
    return NewIndex;
}

// 上下境界線の設定
- (void)createHoraizon{
    
    Horaizon *view = [[Horaizon alloc] init];
    view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    
}

// MAPdeToDoという名のラベル作成ボタンを作成
- (void)createNewMapBtn{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *NewMapBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height / 2 - 35, 70, 70)]; // 初期化と位置決定
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定1
    [NewMapBtn setTitle:@"   MAP   \n    de    \n   ToDo   " forState:UIControlStateNormal]; // 名前
    NewMapBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NewMapBtn.titleLabel.numberOfLines = 3;
    NewMapBtn.titleLabel.textColor = [UIColor blackColor];
    [NewMapBtn.layer setBackgroundColor:[[UIColor greenColor] CGColor]];
    [NewMapBtn setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    NewMapBtn.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [[NewMapBtn layer] setCornerRadius:15];
    [[NewMapBtn layer] setBorderColor:[[UIColor orangeColor] CGColor]];
    [[NewMapBtn layer] setBorderWidth:1.5f];
    
    [NewMapBtn addTarget:self action:@selector(tapNewMapBtn:) forControlEvents:UIControlEventTouchUpInside]; // メソッド作成
    
    [self.view addSubview:NewMapBtn]; // 表示
}

// ラベル作成ボタンがタップされた時
- (void)tapNewMapBtn:(UIButton *)NewMapButton{
    
    /* -------------------- アニメーションでラベル作成ビューを表示 -------------------- */
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
    
    UIImageView *DeleteImg = [[UIImageView alloc] init]; // 初期化
    [DeleteImg setFrame:CGRectMake(self.view.bounds.size.width / 2 - 30, self.view.bounds.size.height - 35, 60, 30)]; // 位置
    UIImage *img = [UIImage imageNamed:@"l03.jpg"]; // 参照画像
    [DeleteImg setImage:img]; // 画像をセット
    
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
        
        // ラベル(実体)の削除(ラベル配列から1つずつ取り出して削除している。)
        for (UILabel *tmpLabel in _labelObject_array) {
            [tmpLabel removeFromSuperview];
        }
        
        // ラベル線(実体)の削除(線配列から1つずつ取り出して削除している。)
        for (DotLine *tmpLine in _dt_array) {
            [tmpLine removeFromSuperview];
        }
        
        // リスト(実体)の削除
        for (UILabel *tmpLabel in _listObject_array){
            [tmpLabel removeFromSuperview];
        }
        
        // リスト線の削除
        for (DotLine *tmpLine in _dt_listarray){
            [tmpLine removeFromSuperview];
        }
        
        // 全データの削除
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        NSLog(@"%@", _LabelArray);
        
    }
    else{
        return;
    }
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
    explain.textColor = [UIColor colorWithRed:0.502 green:0 blue:0 alpha:1.0];
    [_backView addSubview:explain];
    
    /* -------------------- テキストフィールド作成 --------------------- */
    _LabelTField = [[UITextField alloc] initWithFrame:CGRectMake(40, 100, 240, 30)];
    _LabelTField.backgroundColor = [UIColor grayColor];
    
    [_LabelTField addTarget:self action:@selector(tapReturnLabel:) forControlEvents:
     UIControlEventEditingDidEndOnExit];
    
    [_backView addSubview:_LabelTField];
}

- (void)tapReturnLabel:(UITextField *)LabelTTield{}

// シングルタップされたらresignFirstResponderでキーボードを閉じる
-(void)onSingleTap:(UITapGestureRecognizer *)recognizer{
    [_LabelTField resignFirstResponder];
    [_listTField resignFirstResponder];
}

// キーボードを表示していない時は、他のジェスチャに影響を与えないように無効化しておく。
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.singleTap) {
        // キーボード表示中のみ有効
        if (_LabelTField.isFirstResponder || _listTField.isFirstResponder) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

// (ラベル、リスト作成画面にて)戻るボタンが押された時
- (void)tapreturnBtn:(UIButton *)_returnBtn{
    
    /* -------------------- アニメーションでビューを閉じる -------------------- */
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    _backView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    _listbackView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    _Flag = NO;
    [UIView commitAnimations];
}

// ラベル作成メソッド
- (UILabel *)createLabel:(NSString *)name{
    
    /* -------------------- 新規ラベルの作成 -------------------- */
    UILabel *label = [[UILabel alloc] init]; // 初期化
    
    label.center = CGPointMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height / 2 - 30); // 位置
    label.text = name; // ラベル名
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
    
    // 位置や大きさを再設定
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
    
    
    /* -------------------- タッチ検出機能の追加 -------------------- */
    //タッチの検知をするか
    label.userInteractionEnabled = YES;
    // 長押し検知
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(handleLongPressGesture:)];
    longPressGesture.minimumPressDuration = 0.8f;
    [label addGestureRecognizer:longPressGesture];
    
    
    /* -------------------- ユーザデフォルトへラベルデータ(名前、id、位置、大きさ)保存 -------------------- */
    [self loadFromUserdefaults];
    NSDictionary *tmp = [[NSDictionary alloc] init];
    NSMutableDictionary *Mtmp = [NSMutableDictionary dictionary]; // 配列の初期化
    tmp = [_LabelArray objectAtIndex:_LabelArray.count-1]; // 名前とidを読み出し
    Mtmp = tmp.mutableCopy;
    // 位置と大きさをセット
    [Mtmp setObject:[NSNumber numberWithFloat:label.frame.origin.x] forKey:@"x"];
    [Mtmp setObject:[NSNumber numberWithFloat:label.frame.origin.y] forKey:@"y"];
    [Mtmp setObject:[NSNumber numberWithFloat:size.width] forKey:@"w"];
    [Mtmp setObject:[NSNumber numberWithFloat:size.height] forKey:@"h"];
    [_LabelArray replaceObjectAtIndex:_LabelArray.count-1 withObject:Mtmp];

    [self saveToUserDefaults];
    
    return label;
}

// 決定ボタンが押された時
- (void)tapdecideBtn:(UIButton *)_decideBtn{

    [self loadFromUserdefaults];
    
    /* -------------------- ラベルidをカウント -------------------- */
    NSInteger i; // ラベルidカウント用変数
    
    // 全削除ボタン押した時iと配列の初期化
    if (_LabelArray.count == 0) {
        i = 0;
        _LabelArray = [[NSMutableArray alloc] init];
    }
    // 存在時は1つ前のidをiに入れる
    else {
        NSDictionary *tmpid = [[NSDictionary alloc] init];
        tmpid = [_LabelArray objectAtIndex:_LabelArray.count-1];
        i = [[tmpid objectForKey:@"id"] intValue];
    }
    
    // idカウントを+1
    i = i + 1;
    
    /* -------------------- ラベルデータの格納と表示 -------------------- */
    // 名前とidだけを配列に格納
    NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:
                               _LabelTField.text, @"name",
                               [NSNumber numberWithInteger:i], @"id",
                               nil];
    [_LabelArray addObject:tmp];
    [self saveToUserDefaults];

    UILabel *label = [self createLabel:_LabelTField.text]; // ラベル作成
    label.tag = i;
    [_labelObject_array addObject:label]; // ラベル用配列に格納
    [self.view addSubview:label]; // 画面に表示
    [self.view bringSubviewToFront:label];
    
    //確認用
    [self loadFromUserdefaults];
    NSLog(@"%@", _LabelArray);
    
    /* -------------------- 線配列の初期化 -------------------- */
    _previous_dt = nil;
    
    // ダミーの線情報を入れておく
    DotLine *dt = [[DotLine alloc] init];
    dt.frame = CGRectMake(0, 0, 0, 0);
    [_dt_array addObject:dt];
    
    /* -------------------- アニメーションでラベル作成ビューを閉じる -------------------- */
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _backView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView commitAnimations];
    
}

// リスト作成バックビューの生成
- (void)createlistback:(NSString *)name number:(int)num{
    
    /* -------------------- バックビューの作成 -------------------- */
    _listbackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
    _listbackView.backgroundColor = [UIColor yellowColor];
    _listbackView.alpha = 0.8;
    
    [self.view addSubview:_listbackView];
    
    /* -------------------- 戻るボタン -------------------- */
    _returnBtn = [[UIButton alloc] init]; // ボタン初期化
    [_returnBtn setTitle:@"戻る" forState:UIControlStateNormal]; // ボタンに文字を設定
    _returnBtn.backgroundColor = [UIColor blackColor];
    _returnBtn.alpha = 1.0;// 色、透明度の設定
    _returnBtn.frame = CGRectMake(_backView.bounds.size.width / 2 - 30, _backView.bounds.size.height - 85, 80, 40); // フレーム設定
    
    [_returnBtn addTarget:self action:@selector(tapreturnBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [_listbackView addSubview:_returnBtn]; // ビューへ表示
    
    /* -------------------- 決定ボタン -------------------- */
    _decideBtn = [[UIButton alloc] init]; // ボタン初期化
    [_decideBtn setTitle:@"決定" forState:UIControlStateNormal]; // ボタンに文字を設定
    _decideBtn.backgroundColor = [UIColor blackColor];
    _decideBtn.alpha = 1.0;// 色、透明度の設定
    _decideBtn.frame = CGRectMake(_backView.bounds.size.width / 2 + 60, _backView.bounds.size.height - 85, 80, 40); // フレーム設定
    
    _decideBtn.tag = num;
    
    [_decideBtn addTarget:self action:@selector(tapdecidelistBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [_listbackView addSubview:_decideBtn]; // ビューへ表示
    
    /* -------------------- ラベル情報の表示 -------------------- */
    UILabel *labelname = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 240, 15)];
    labelname.textColor = [UIColor blueColor];
    labelname.text = [NSString stringWithFormat:@"ラベル名: %@", name];
    labelname.alpha = 1.0;
    
    [_listbackView addSubview:labelname];
    
    
    /* -------------------- テキストフィールド作成 --------------------- */
    _listTField = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, 240, 30)];
    
    _listTField.backgroundColor = [UIColor blueColor];
    _listTField.textColor = [UIColor cyanColor];
    _listTField.alpha = 0.5;
    
    [_listTField addTarget:self action:@selector(tapReturnList:) forControlEvents:
     UIControlEventEditingDidEndOnExit];
    
    [_listbackView addSubview:_listTField];
    
    /* -------------------- 詳細記述画面の作成 -------------------- */
    _listDetail = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, _listbackView.bounds.size.width - 20, _listbackView.bounds.size.height - 205)];
    _listDetail.backgroundColor = [UIColor blueColor];
    _listDetail.text = @"詳細を入力してください。";
    _listDetail.textColor = [UIColor cyanColor];
    _listDetail.alpha = 0.5;
    
    [_listbackView addSubview:_listDetail];
    
    _Flag = YES;
    
}

- (void)tapReturnList:(UITextField *)listTTield{}

// ラベル長押し検知時
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender{
    
    if (!_Flag) {
        
        /* -------------------- nameとidを元にバックビューを作成 ------------------- */
        UITouch *touch = sender;
        UILabel *sptchlabel = (UILabel *)[touch view];

        [self loadFromUserdefaults];

        NSDictionary *tmp = [[NSDictionary alloc] init];
        
        tmp = [_LabelArray objectAtIndex:[self calcNewIndex:sptchlabel]];
        NSString *name = [tmp objectForKey:@"name"];
        int num = [[tmp objectForKey:@"id"] intValue];
    
        [self createlistback:name number:num];
        NSLog(@"taped:%@", tmp);
    
        /* -------------------- ToDoリストバックビューをアニメーションで表示 -------------------- */
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        _listbackView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [UIView commitAnimations];
    }
}

// リスト作成メソッド
- (UILabel *)createList:(NSString *)name labelid:(NSInteger)labelid labelx:(float)lx labely:(float)ly listid:(NSInteger)listid{
 
    /* -------------------- 新規リストの作成 -------------------- */
    UILabel *list = [[UILabel alloc] init]; // 初期化
    
    list.center = CGPointMake(lx + 10, ly + 10); // 位置
    list.text = name; // リスト名
    CGSize bounds = CGSizeMake(list.frame.size.width, 200);
    UIFont *font = list.font;
    UILineBreakMode mode = list.lineBreakMode;
    CGSize size;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect rect
        = [list.text boundingRectWithSize:bounds
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil];
        size = rect.size;
    }
    else {
        CGSize size = [list.text sizeWithFont:font
                             constrainedToSize:bounds
                                 lineBreakMode:mode];
    }
    size.width  = ceilf(size.width);
    size.height = ceilf(size.height);
    NSLog(@"size: %@", NSStringFromCGSize(size));
    
    // 位置や大きさを再設定
    list.frame = CGRectMake(list.frame.origin.x,
                             list.frame.origin.y,
                             size.width, size.height);
    
    //ラベルのカラー指定
    list.textColor = [UIColor grayColor];
    list.shadowColor = [UIColor blackColor];
    list.shadowOffset = CGSizeMake(0.5, 0.5);
    //ラベルの背景色を黒に指定
    list.backgroundColor = [UIColor yellowColor];
    list.layer.borderColor = [UIColor orangeColor].CGColor;
    list.layer.borderWidth = 1.5f;
    //ラベルの角丸指定
    [[list layer] setCornerRadius:8.0];
    //ラベルのはみ出しを許可するか
    [list setClipsToBounds:YES];
    
    
    /* -------------------- タッチ検出機能の追加 -------------------- */
    //タッチの検知をするか
    list.userInteractionEnabled = YES;
    // 長押し検知
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(handleLongPressGesture:)];
    longPressGesture.minimumPressDuration = 0.8f;
    [list addGestureRecognizer:longPressGesture];

    
    /* -------------------- ユーザデフォルトへラベルデータ(名前、id、位置、大きさ)保存 -------------------- */
    [self loadFromUserdefaults];
//    NSDictionary *tmp = [[NSDictionary alloc] init];
//    NSMutableDictionary *Mtmp = [NSMutableDictionary dictionary]; // 配列の初期化
    NSMutableDictionary *Mtmp = [_LabelArray objectAtIndex:labelid-1];
    NSMutableArray *listArray = [Mtmp objectForKey:@"List"];
    NSMutableDictionary *MMtmp = [listArray objectAtIndex:listid-10001];
    
    
    // 位置と大きさをセット
    [MMtmp setObject:[NSNumber numberWithFloat:list.frame.origin.x] forKey:@"x"];
    [MMtmp setObject:[NSNumber numberWithFloat:list.frame.origin.y] forKey:@"y"];
    [MMtmp setObject:[NSNumber numberWithFloat:size.width] forKey:@"w"];
    [MMtmp setObject:[NSNumber numberWithFloat:size.height] forKey:@"h"];
    
    [listArray replaceObjectAtIndex:listid-10001 withObject:MMtmp];
    [Mtmp setObject:listArray forKey:@"List"];
    [_LabelArray replaceObjectAtIndex:labelid-1 withObject:Mtmp];
    
    [self saveToUserDefaults];
    
    return list;
    
}

// リストの決定ボタン押された時
- (void)tapdecidelistBtn:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    NSInteger i;
    NSInteger buttonTag = button.tag;
    
    
    [self loadFromUserdefaults];
    NSDictionary *tmp = [[NSDictionary alloc] init];
    NSMutableDictionary *Mtmp = [[NSMutableDictionary alloc] init]; // 移す用のディクショナリ
    tmp = [_LabelArray objectAtIndex:buttonTag-1];
    Mtmp = tmp.mutableCopy;

    float labelx = [[Mtmp objectForKey:@"x"] floatValue]; // ラベルのxを読み出し
    float labely = [[Mtmp objectForKey:@"y"] floatValue]; // ラベルのyを読み出し
    
    NSMutableArray *listArray = [tmp objectForKey:@"List"]; // あればラベルのリスト配列を読みだし
    NSLog(@"%@",listArray);
    if (listArray == nil) {
        listArray = [[NSMutableArray alloc] init]; // リスト用の配列作成
        i = 10000;
    }
    else{
        NSDictionary *tmpdic = [[NSDictionary alloc] init];
        tmpdic = [listArray objectAtIndex:listArray.count-1];
        i = [[tmpdic objectForKey:@"id"] integerValue];
    }
    
    i++;
    
    NSMutableDictionary *tmplist = [[NSMutableDictionary alloc] init]; // 各リスト用配列にリストの名前や位置を入れる
    [tmplist setObject:_listTField.text forKey:@"name"];
    [tmplist setObject:[NSNumber numberWithInteger:i] forKey:@"id"];
    [tmplist setObject:_listDetail.text forKey:@"detail"];
    [tmplist setObject:[NSNumber numberWithInteger:buttonTag] forKey:@"labelid"];
    
    [listArray addObject:tmplist]; // リスト情報を配列に保存
    
    [Mtmp setObject:listArray forKey:@"List"]; // 配列をラベル情報に保存
    
    [_LabelArray replaceObjectAtIndex:buttonTag-1 withObject:Mtmp];
    NSLog(@"%@", _LabelArray);
    
    [self saveToUserDefaults];
    
    UILabel *list = [self createList:_listTField.text labelid:buttonTag labelx:labelx labely:labely listid:i]; // リスト作成
    list.tag = i;
    [_listObject_array addObject:list]; // リスト用配列に格納
    [self.view addSubview:list]; // 画面に表示
    [self.view bringSubviewToFront:list];
    
    
    /* -------------------- 線配列の初期化 -------------------- */
    _previous_list_dt = nil;
    
    // ダミーの線情報を入れておく
    DotLine *dt = [[DotLine alloc] init];
    dt.frame = CGRectMake(0, 0, 0, 0);
    [_dt_listarray addObject:dt];
    
    // バックビューを閉じる
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _listbackView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView commitAnimations];
    _Flag = NO;
    
}

// ラベルがタッチされた時
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [[event allTouches] anyObject];
    UILabel *sptchlabel = (UILabel *)[touch view];
    
    if (sptchlabel.tag > 0){
        
        if (sptchlabel.tag > 10000){
        
            [self loadFromUserdefaults];
            
            CGPoint location = [touch locationInView:self.view];
            sptchlabel.center = location;
            
            float x = sptchlabel.frame.origin.x;
            float y = sptchlabel.frame.origin.y;
            float w = sptchlabel.frame.size.width;
            float h = sptchlabel.frame.size.height;
            
            // 線の表示
            DotLine *dt = [[DotLine alloc] init];
            dt.frame = CGRectMake(x, y, w, h);
        
            // リストがタップされた時
            _previous_list_dt = dt;
            [_dt_listarray[sptchlabel.tag-10001] removeFromSuperview];
        }
        // ラベルがタップされた時
        else {
            
            [self loadFromUserdefaults];
            
            CGPoint location = [touch locationInView:self.view];
            sptchlabel.center = location;
            
            float x = sptchlabel.frame.origin.x;
            float y = sptchlabel.frame.origin.y;
            float w = sptchlabel.frame.size.width;
            float h = sptchlabel.frame.size.height;
            
            // 線の表示
            DotLine *dt = [[DotLine alloc] init];
            dt.frame = CGRectMake(x, y, w, h);
            // dtを今から変更が加わる線として保存
            _previous_dt = dt;
            // 最初に描画した線を削除
            [_dt_array[[self calcNewIndex:sptchlabel]] removeFromSuperview];
        }
    }
}

// ラベルが動かされた時 位置情報を取得しつつ点線を表示
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    UILabel *sptchlabel = (UILabel *)[touch view];
    if (sptchlabel.tag > 0){
        
        if (sptchlabel.tag > 10000) {
            [_previous_list_bs removeFromSuperview];
            
            CGPoint location = [touch locationInView:self.view];
            sptchlabel.center = location;
            
            // タッチされたリストの位置情報を取得
            float x1 = sptchlabel.frame.origin.x;
            float y1 = sptchlabel.frame.origin.y;
            float w1 = sptchlabel.frame.size.width;
            float h1 = sptchlabel.frame.size.width;
            
            NSDictionary *list = [[NSDictionary alloc] init];
            NSInteger listid;
            NSInteger answer;

            [self loadFromUserdefaults];
            // リストの元となるラベルの位置情報を取得
            for (NSDictionary *tmp in _LabelArray) {
                
                list = [tmp objectForKey:@"List"];
                
                for (NSDictionary *ttmp in list){
                    
                    listid = [[ttmp objectForKey:@"id"] integerValue];
                
                    if (sptchlabel.tag == listid) { //ラベルidを取得
                        
                        answer = [[ttmp objectForKey:@"labelid"] integerValue];
                        break;
                    }
                }
            }
            
            NSDictionary *tmp = [[NSDictionary alloc] init];
            tmp = [_LabelArray objectAtIndex:answer-1];
            float lx = [[tmp objectForKey:@"x"] floatValue];
            float ly = [[tmp objectForKey:@"y"] floatValue];
            float lw = [[tmp objectForKey:@"w"] floatValue];
            float lh = [[tmp objectForKey:@"h"] floatValue];
            
            
            // グローバル変数を入れる
            AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            basic.basicX = lx + lw / 2;
            basic.basicY = ly + lh / 2;

            BlackStroke *bs = [[BlackStroke alloc] init];
            
            if ((x1 + w1 / 2) < (lx + lw / 2)) {
                if ((y1 + h1 / 2) < (ly + lh / 2)){ // ラベルの左上
                    bs.frame = CGRectMake(x1 + w1 / 2, y1 + h1 / 2, (lx + lw / 2) - (x1 + w1 / 2), (ly + lh / 2) - (y1 + h1 / 2));
                }
                else{ // ラベルの左下
                    bs.frame = CGRectMake(x1 + w1 / 2, ly + lh / 2, (lx + lw / 2) - (x1 + w1 / 2), (y1 + h1 / 2) - (ly + lh / 2));
                }
            }
            else{
                if ((y1 + h1 / 2) < (ly + lh / 2)){ // ラベルの右上
                    bs.frame = CGRectMake(lx + lw / 2, y1 + h1 / 2, (x1 + w1 / 2) - (lx + lw / 2), (ly + lh / 2) - (y1 + h1 / 2));
                }
                else{ // ラベルの右下
                    bs.frame = CGRectMake(lx + lw / 2, ly + lh / 2, (x1 + w1 / 2) - (lx + lw / 2), (y1 + h1 / 2) - (ly + lh / 2));
                }
            }
            
            [self.view addSubview:bs];
            [self.view sendSubviewToBack:bs];
            
            _previous_list_bs = bs;
            
        }
        
        else{
            [_previous_bs removeFromSuperview];
            
            CGPoint location = [touch locationInView:self.view];
            sptchlabel.center = location;
            
            float x1 = sptchlabel.frame.origin.x;
            float y1 = sptchlabel.frame.origin.y;
            float w1 = sptchlabel.frame.size.width;
            float h1 = sptchlabel.frame.size.height;
            
            // グローバル変数を入れる
            AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            basic.basicX = 160.0;
            basic.basicY = 268.0;
            
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
}

// ラベルが指から離された時
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    UILabel *sptchlabel = (UILabel *)[touch view];
    
    if (sptchlabel.tag > 0){
        if (sptchlabel.tag > 10000){
            // 以前の線を削除
            [_previous_list_bs removeFromSuperview];
            [_previous_list_dt removeFromSuperview];
            
            CGPoint location = [touch locationInView:self.view];
            
            /* -------------------- 範囲外の時は位置を戻す -------------------- */
            if (location.y < 30){
                sptchlabel.center = CGPointMake(location.x, 30);
            }
            else if (location.y > 518){
                // ゴミ箱の位置に移動した時は削除
                if ((location.x > self.view.bounds.size.width / 2 - 15) && (self.view.bounds.size.width / 2 + 15 > location.x)) {
                    
                    [self loadFromUserdefaults];
                    NSDictionary *list = [[NSDictionary alloc] init];
                    NSInteger listid;
                    NSInteger answer;
                    
                    for (NSDictionary *tmp in _LabelArray){
                        list = [tmp objectForKey:@"List"];
                        for (NSDictionary *ttmp in list){
                            listid = [[ttmp objectForKey:@"id"] integerValue];
                            if (sptchlabel.tag == listid) {
                                answer = [[ttmp objectForKey:@"labelid"] integerValue];
                                break;
                            }
                        }
                    }
                    NSMutableDictionary *Mtmp = [NSMutableDictionary dictionary];
                    Mtmp = [_LabelArray objectAtIndex:answer-1];
                    NSMutableArray *Atmp = [[NSMutableArray alloc] init];
                    Atmp = [Mtmp objectForKey:@"List"];
                    NSMutableDictionary *MMtmp = [NSMutableDictionary dictionary];
                    MMtmp = [Atmp objectAtIndex:sptchlabel.tag-10001];
                                                 
                    [Atmp removeObjectAtIndex:sptchlabel.tag-10001];
                    [Mtmp setObject:Atmp forKey:@"List"];
                    [_LabelArray replaceObjectAtIndex:answer-1 withObject:Mtmp];
                    
                    [_dt_listarray removeObjectAtIndex:listid-1];
                    [_listObject_array removeObjectAtIndex:listid-1];
                    
                    [sptchlabel removeFromSuperview];
                    
                    NSLog(@"%@",_LabelArray);
                    [self saveToUserDefaults];
                    return;
                }
                sptchlabel.center = CGPointMake(location.x, 518);
            }
            
            else if (location.x > 125 && 195 > location.x && location.y > 249 && 319 > location.y){
                sptchlabel.center = CGPointMake(160, 219);
            }
            
            else sptchlabel.center = location; // 範囲内の時はその位置へ
            
            // 線表示のためのリスト位置を取得
            float x1 = sptchlabel.frame.origin.x;
            float y1 = sptchlabel.frame.origin.y;
            float w1 = sptchlabel.frame.size.width;
            float h1 = sptchlabel.frame.size.height;
            
            NSDictionary *list = [[NSDictionary alloc] init];
            NSInteger listid;
            NSInteger answer;
            
            [self loadFromUserdefaults];
            // リストの元となるラベルの位置情報を取得
            for (NSDictionary *tmp in _LabelArray) {
                
                list = [tmp objectForKey:@"List"];
                
                for (NSDictionary *ttmp in list){
                    
                    listid = [[ttmp objectForKey:@"id"] integerValue];
                    
                    if (sptchlabel.tag == listid) { //ラベルidを取得
                        
                        answer = [[ttmp objectForKey:@"labelid"] integerValue];
                        break;
                    }
                }
            }
            
            NSDictionary *tmp = [[NSDictionary alloc] init];
            tmp = [_LabelArray objectAtIndex:answer-1];
            float lx = [[tmp objectForKey:@"x"] floatValue];
            float ly = [[tmp objectForKey:@"y"] floatValue];
            float lw = [[tmp objectForKey:@"w"] floatValue];
            float lh = [[tmp objectForKey:@"h"] floatValue];
            
            // 線の表示
            DotLine *dt = [self writeListLine:x1 y:y1 width:w1 height:h1 savedlistId:sptchlabel.tag savedId:answer labelx:lx labely:ly labelw:lw labelh:lh];
            
            [self.view addSubview:dt];
            [self.view sendSubviewToBack:dt];
            
            _previous_list_dt = dt;
            
            [_dt_listarray replaceObjectAtIndex:sptchlabel.tag-10001 withObject:dt];
        }
        else{
            // 以前の線を削除
            [_previous_bs removeFromSuperview];
            [_previous_dt removeFromSuperview];
            
            CGPoint location = [touch locationInView:self.view];
            
            /* -------------------- 範囲外の時は位置を戻す -------------------- */
            if (location.y < 30){
                sptchlabel.center = CGPointMake(location.x, 30);
            }
            else if (location.y > 518){
                // ゴミ箱の位置に移動した時は削除
                if ((location.x > self.view.bounds.size.width / 2 - 15) && (self.view.bounds.size.width / 2 + 15 > location.x)) {
                    
                    [_LabelArray removeObjectAtIndex:[self calcNewIndex:sptchlabel]];
                    [_dt_array removeObjectAtIndex:[self calcNewIndex:sptchlabel]];
                    [_labelObject_array removeObjectAtIndex:[self calcNewIndex:sptchlabel]];
                    
                    [sptchlabel removeFromSuperview];
                    
                    NSLog(@"%@",_LabelArray);
                    [self saveToUserDefaults];
                    return;
                }
                sptchlabel.center = CGPointMake(location.x, 518);
            }
            
            else if (location.x > 125 && 195 > location.x && location.y > 249 && 319 > location.y){
                sptchlabel.center = CGPointMake(160, 219);
            }
            
            else sptchlabel.center = location; // 範囲内の時はその位置へ
            
            // 線表示のためのラベル位置を取得
            float x1 = sptchlabel.frame.origin.x;
            float y1 = sptchlabel.frame.origin.y;
            float w1 = sptchlabel.frame.size.width;
            float h1 = sptchlabel.frame.size.height;
            
            // 線の表示
            DotLine *dt = [self writeLine:x1 y:y1 width:w1 height:h1 savedIndex:(int)[self calcNewIndex:sptchlabel]];
            
            [self.view addSubview:dt];
            [self.view sendSubviewToBack:dt];
            
            _previous_dt = dt;
            
            [_dt_array replaceObjectAtIndex:[self calcNewIndex:sptchlabel] withObject:dt];

        }
    }
}

// 実線の作成(ラベル)
- (DotLine *)writeLine:(float)x y:(float)y width:(float)width height:(float)height savedIndex:(int)savedIndex{
    
    // グローバル変数を入れる
    AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    basic.basicX = 160.0;
    basic.basicY = 268.0;

    DotLine *dt = [[DotLine alloc] init];
    
    // ユーザデフォルトへのデータ保存
    [self loadFromUserdefaults];
    NSMutableDictionary *Mtmp = [NSMutableDictionary dictionary];
    NSDictionary *tmp = [[NSDictionary alloc] init];
    
    tmp = [_LabelArray objectAtIndex:savedIndex];
    Mtmp = tmp.mutableCopy;
    
    [Mtmp setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
    [Mtmp setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
    [Mtmp setObject:[NSNumber numberWithFloat:width] forKey:@"w"];
    [Mtmp setObject:[NSNumber numberWithFloat:height] forKey:@"h"];
    
    // 範囲を決める
    float r1 = sqrtf((160 - (x + width / 2)) * (160 - (x + width / 2)) + (284 - (y + height / 2)) * (284 - (y + height / 2)));
    float r2 = sqrtf((160 - (x + width / 2)) * (160 - (x + width / 2)) + ((y + height / 2) - 284) * ((y + height / 2) - 284));
    float r3 = sqrtf(((x + width / 2) - 160) * ((x + width / 2) - 160) + (284 - (y + height / 2)) * (284 - (y + height / 2)));
    float r4 = sqrtf(((x + width / 2) - 160) * ((x + width / 2) - 160) + ((y + height / 2) - 284) * ((y + height / 2) - 284));
    
    // 線を描画、そして保存
    if ( x < 160.0 ){
        if ( y < 284.0 ){ //左上
            if (r1 < 180){
                
                dt.frame = CGRectMake(x + width / 2, y + height / 2, 160 - (x + width / 2), 284 - (y + height / 2));
                float lx = x + width / 2;
                float ly = y + height / 2;
                float lw = 160 - (x + width / 2);
                float lh = 284 - (y + height / 2);
                
                [Mtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                [Mtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                [Mtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                [Mtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
            }
        }
        else{ // 左下
            if (r2 < 180){
                
                dt.frame = CGRectMake(x + width / 2, 284, 160 - (x + width / 2), (y + height / 2) - 284);
                float lx = x + width / 2;
                float ly = 284;
                float lw = 160 - (x + width / 2);
                float lh = (y + height / 2) - 284;
                
                [Mtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                [Mtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                [Mtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                [Mtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
            }
        }
    }
    else{
        if ( y < 284.0 ){ // 右上
            if (r3 < 180){
                
                dt.frame = CGRectMake(160, y + height / 2, (x + width / 2) - 160, 284 - (y + height / 2));
                float lx = 160;
                float ly = y + height / 2;
                float lw = (x + width / 2) - 160;
                float lh = 284 - (y + height / 2);
                
                [Mtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                [Mtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                [Mtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                [Mtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
            }
        }
        else{ // 右下
            
            if (r4 < 180){
                
                dt.frame = CGRectMake(160, 284, (x + width / 2) - 160, (y + height / 2) - 284);
                float lx = 160;
                float ly = 284;
                float lw = (x + width / 2) - 160;
                float lh = (y + height / 2) - 284;
                
                [Mtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
                [Mtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
                [Mtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
                [Mtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
            }
        }
    }
    
    //MtmpをLabelArrayに保存
    [_LabelArray replaceObjectAtIndex:savedIndex withObject:Mtmp];
    
    [self saveToUserDefaults];
    NSLog(@"%@", _LabelArray);
    return dt;
}

// 実線の作成(リスト)
- (DotLine *)writeListLine:(float)x y:(float)y width:(float)width height:(float)height savedlistId:(int)savedlistId savedId:(int)savedId labelx:(float)labelx labely:(float)labely labelw:(float)labelw labelh:(float)labelh{
    
    // グローバル変数を入れる
    AppDelegate *basic = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    basic.basicX = labelx + labelw / 2;
    basic.basicY = labely + labelh / 2;

    DotLine *dt = [[DotLine alloc] init];
    
    // ユーザデフォルトへのデータ保存
    [self loadFromUserdefaults];
    NSMutableDictionary *Mtmp = [NSMutableDictionary dictionary];
    NSDictionary *tmp = [[NSDictionary alloc] init];
    
    tmp = [_LabelArray objectAtIndex:savedId-1];
    Mtmp = tmp.mutableCopy;
    
    NSMutableArray *Atmp = [[NSMutableArray alloc] init];
    Atmp = [Mtmp objectForKey:@"List"];
    
    NSMutableDictionary *MMtmp = [NSMutableDictionary dictionary];
    MMtmp = [Atmp objectAtIndex:savedlistId-10001];
    
    [MMtmp setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
    [MMtmp setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
    [MMtmp setObject:[NSNumber numberWithFloat:width] forKey:@"w"];
    [MMtmp setObject:[NSNumber numberWithFloat:height] forKey:@"h"];
    
    // 線を描画、そして保存
    if ((x + width / 2) < (labelx + labelw / 2)) {
        if ((y + height / 2) < (labely + labelh / 2)){ // ラベルの左上
            
            float lx = x + width / 2;
            float ly = y + height / 2;
            float lw = (labelx + labelw / 2) - (x + width / 2);
            float lh = (labely + labelh / 2) - (y + height / 2);
            
            dt.frame = CGRectMake(lx, ly, lw, lh);
            
            [MMtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
            [MMtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
            [MMtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
            [MMtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
        }
        else{ // ラベルの左下
            
            float lx = x + width / 2;
            float ly = labely + labelh / 2;
            float lw = (labelx + labelw / 2) - (x + width / 2);
            float lh = (y + height / 2) - (labely + labelh / 2);
            
            dt.frame = CGRectMake(lx, ly, lw, lh);
            
            [MMtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
            [MMtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
            [MMtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
            [MMtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
        }
    }
    else{
        if ((y + height / 2) < (labely + labelh / 2)){ // ラベルの右上
            
            float lx = labelx + labelw / 2;
            float ly = y + height / 2;
            float lw = (x + width / 2) - (labelx + labelw / 2);
            float lh = (labely + labelh / 2) - (y + height / 2);
            
            dt.frame = CGRectMake(lx, ly, lw, lh);
            
            [MMtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
            [MMtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
            [MMtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
            [MMtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
        }
        else{ // ラベルの右下
            
            float lx = labelx + labelw / 2;
            float ly = labely + labelh / 2;
            float lw = (x + width / 2) - (labelx + labelw / 2);
            float lh = (y + height / 2) - (labely + labelh / 2);
            
            dt.frame = CGRectMake(lx, ly, lw, lh);
            
            [MMtmp setObject:[NSNumber numberWithFloat:lx] forKey:@"linex"];
            [MMtmp setObject:[NSNumber numberWithFloat:ly] forKey:@"liney"];
            [MMtmp setObject:[NSNumber numberWithFloat:lw] forKey:@"linew"];
            [MMtmp setObject:[NSNumber numberWithFloat:lh] forKey:@"lineh"];
        }
    }
    
    //MMtmpを保存
    [Atmp replaceObjectAtIndex:savedlistId-10001 withObject:MMtmp];
    [Mtmp setObject:Atmp forKey:@"List"];
    [_LabelArray replaceObjectAtIndex:savedId-1 withObject:Mtmp];
    
    [self saveToUserDefaults];
    NSLog(@"%@", _LabelArray);
    return dt;
}

// 電話等緊急時の時
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
//エラー1:いくつかラベルを作りどれかひとつを削除し、その後ラベルを動かすと線が残る。全削除でも線とラベルは消えず

