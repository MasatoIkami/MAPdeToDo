//
//  ViewController.m
//  MAPdeToDo
//
//  Created by Masato Ikami on 2014/11/04.
//  Copyright (c) 2014年 Masato Ikami. All rights reserved.
//

#import "ViewController.h"
#import "BlackStroke.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BlackStroke *bs = [[BlackStroke alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bs];

    [self createMainLabel]; // MAPdeToDoと表示
    [self createNewButton]; // ラベル作成ボタン
    [self createDeleteImage]; // ゴミ箱
    [self createSettingButton]; // 設定
    [self createallDeleteBtn]; // 全削除ボタン
    
    [self createbackView]; // バックビューを下に表示
    
    [self loadFromUserdefaults]; // データを読み出す
    NSLog(@"%@", _LabelArray);
    
    //ビューの初期化時にジェスチャをself.viewに登録
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    
    t = @"TEST";
}

- (void)createMainLabel{
    
    UILabel *mdtLabel = [[UILabel alloc] init];
    
    
    mdtLabel.numberOfLines = 3;
    mdtLabel.text = @"   MAP   \n    de    \n   ToDo   ";
    
    
    // --- テキストの内容によりラベルの大きさを変える ---
    // 表示最大サイズ
    CGSize bounds = CGSizeMake(mdtLabel.frame.size.width, 200);
    // フォント
    UIFont *font = mdtLabel.font;
    // 表示モード
    UILineBreakMode mode = mdtLabel.lineBreakMode;
    // 文字列全体のサイズを取得
    CGSize size;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect rect
        = [mdtLabel.text boundingRectWithSize:bounds
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
        size = rect.size;
    }
    else {
        CGSize size = [mdtLabel.text sizeWithFont:font
                                constrainedToSize:bounds
                                    lineBreakMode:mode];
    }
    size.width  = ceilf(size.width);
    size.height = ceilf(size.height);
    NSLog(@"size: %@", NSStringFromCGSize(size));
    
    // ラベルのサイズを変更
    mdtLabel.frame = CGRectMake(self.view.bounds.size.width / 2 - (size.width / 2), self.view.bounds.size.height / 2 - (size.height / 2), size.width, size.height);
    
    mdtLabel.layer.borderColor = [UIColor blackColor].CGColor;
    mdtLabel.layer.borderWidth = 1.5;
    mdtLabel.layer.cornerRadius = 15;
    
    [self.view addSubview:mdtLabel];
    
    float x = mdtLabel.frame.origin.x;
    float y = mdtLabel.frame.origin.y;
    
    NSLog(@"x:%f, y:%f", x, y);
}

// ラベル作成ボタンがタップされた時
- (void)tapNewBtn:(UIButton *)NewButton{
    NSLog(@"NEW");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    _backView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView commitAnimations];
}

// 設定ボタンがタップされた時
- (void)tapSettingBtn:(UIButton *)SettingButton{
    NSLog(@"Set");
}

// ラベル作成ボタン作成
- (void)createNewButton{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *NewButton = [[UIButton alloc] init]; // ボタン初期化
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定
    [NewButton setTitle:@"ラベル作成" forState:UIControlStateNormal]; // ボタンに文字を設定
    [NewButton setTitleColor:[UIColor colorWithRed:0.19215 green:0.760784 blue:0.952941 alpha:1.0] forState:UIControlStateNormal]; // 色、透明度の設定
    NewButton.frame = CGRectMake(10, 274, 80, 20); // フレーム設定
    
    [NewButton addTarget:self action:@selector(tapNewBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [self.view addSubview:NewButton]; // ビューへ表示
    
}

// ゴミ箱イメージ作成
- (void)createDeleteImage{
    
    UIImageView *DeleteImg = [[UIImageView alloc] init];
    [DeleteImg setFrame:CGRectMake(self.view.bounds.size.width - 100, 274, 40, 20)];
    
    UIImage *img = [UIImage imageNamed:@"l03.jpg"];
    
    [DeleteImg setImage:img];
    
    [self.view addSubview:DeleteImg]; // ビューへ表示
}

// 設定ボタン作成
- (void)createSettingButton{
    
    // UIImage *img = [UIImage imageNamed:@""]; // イメージ読み込み
    UIButton *SettingButton = [[UIButton alloc] init]; // ボタン初期化
    // [NewButton setBackgroundImage:img forState: UIControlStateNormal]; // ボタンに画像を設定
    [SettingButton setTitle:@"設定" forState:UIControlStateNormal]; // ボタンに文字を設定
    [SettingButton setTitleColor:[UIColor colorWithRed:0.19215 green:0.760784 blue:0.952941 alpha:1.0] forState:UIControlStateNormal]; // 色、透明度の設定
    SettingButton.frame = CGRectMake(self.view.bounds.size.width - 50, 274, 40, 20); // フレーム設定
    
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
    _returnBtn.frame = CGRectMake(_backView.bounds.size.width / 2 - 30, _backView.bounds.size.height - 70, 80, 40); // フレーム設定
    
    [_returnBtn addTarget:self action:@selector(tapreturnBtn:)  forControlEvents:UIControlEventTouchUpInside]; // アクションを追加
    
    [_backView addSubview:_returnBtn]; // ビューへ表示
    
    /* -------------------- 決定ボタン -------------------- */
    _decideBtn = [[UIButton alloc] init]; // ボタン初期化
    [_decideBtn setTitle:@"決定" forState:UIControlStateNormal]; // ボタンに文字を設定
    _decideBtn.backgroundColor = [UIColor blackColor];
    _decideBtn.alpha = 1.0;// 色、透明度の設定
    _decideBtn.frame = CGRectMake(_backView.bounds.size.width / 2 + 60, _backView.bounds.size.height - 70, 80, 40); // フレーム設定
    
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
    
    // バックビューを閉じる
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _backView.frame =CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView commitAnimations];

    if (_LabelArray == NULL) {
        _LabelArray = [[NSMutableArray alloc] init];
    }
    
    [_LabelArray addObject:_ListTField.text];
    NSLog(@"_LabelArray: %@", _LabelArray);
    
    [self saveToUserDefaults];
    
    [self createNewLabel];
    
}

// 新たなラベルを作成
- (void)createNewLabel{
    
    _NewLabel = [[UILabel alloc] init];
    _NewLabel.center = CGPointMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height / 2 - 30);
    
    _NewLabel.text = _ListTField.text;
    
    // --- テキストの内容によりラベルの大きさを変える ---
    // 表示最大サイズ
    CGSize bounds = CGSizeMake(_NewLabel.frame.size.width, 200);
    // フォント
    UIFont *font = _NewLabel.font;
    // 表示モード
    UILineBreakMode mode = _NewLabel.lineBreakMode;
    // 文字列全体のサイズを取得
    CGSize size;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect rect
        = [_NewLabel.text boundingRectWithSize:bounds
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
        size = rect.size;
    }
    else {
        CGSize size = [_NewLabel.text sizeWithFont:font
                                constrainedToSize:bounds
                                    lineBreakMode:mode];
    }
    size.width  = ceilf(size.width);
    size.height = ceilf(size.height);
    NSLog(@"size: %@", NSStringFromCGSize(size));
    
    // ラベルのサイズを変更
    _NewLabel.frame = CGRectMake(_NewLabel.frame.origin.x,
                                _NewLabel.frame.origin.y,
                                size.width, size.height);
    //ラベルのカラー指定
    _NewLabel.textColor = [UIColor whiteColor];
    _NewLabel.shadowColor = [UIColor grayColor];
    _NewLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    
    //ラベルの背景色を黒に指定
    _NewLabel.backgroundColor = [UIColor blackColor];
    //ラベルの角丸指定
    [[_NewLabel layer] setCornerRadius:8.0];
    //ラベルのはみ出しを許可するか
    [_NewLabel setClipsToBounds:YES];
    
    //タッチの検知をするか
    _NewLabel.userInteractionEnabled = YES;
    
    [_NewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:withEvent:)]];

    [_NewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesMoved:withEvent:)]];
    
    [_NewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesEnded:withEvent:)]];
    
    [_NewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesCancelled:withEvent:)]];
    
    [self.view addSubview:_NewLabel];
    [self.view bringSubviewToFront:_NewLabel];
}

// ラベルがタッチされた時
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{}

// ラベルが動かされた時
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch view] == _NewLabel){
        
        CGPoint location = [touch locationInView:self.view];
        _NewLabel.center = location;
    }
}

// ラベルが指から離された時
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch view] == _NewLabel){
        
        CGPoint location = [touch locationInView:self.view];
        _NewLabel.center = location;
        
        float x1 = _NewLabel.frame.origin.x;
        float y1 = _NewLabel.frame.origin.y;
        NSLog(@"x1:%f, y1:%f", x1, y1);
        
        
    }
}

// 電話等緊急時の時
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == _NewLabel){
        
        CGPoint location = [touch locationInView:self.view];
        _NewLabel.center = location;
    }
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

- (void)drawRect:(CGRect)rect{
    
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

