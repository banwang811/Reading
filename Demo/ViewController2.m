//
//  ViewController2.m
//  Demo
//
//  Created by mac on 16/3/10.
//  Copyright © 2016年 huajun. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@property (nonatomic, strong) UIView            *navigationView;

@property (nonatomic, strong) UILabel           *contentLabel;

@property (nonatomic, strong) NSString          *contentString;

@property (nonatomic, assign) CGFloat           lineHight;

@property (nonatomic, assign) CGFloat           hight;

@property (nonatomic, strong) UIButton          *nextButton;

@property (nonatomic, strong) UIButton          *previousButton;

@property (nonatomic, assign) NSInteger         page;

@property (nonatomic, strong) NSArray           *rangesArr;

@end

@implementation ViewController2

- (instancetype)init{
    if (self = [super init]) {
        self.hight = [UIScreen mainScreen].bounds.size.height - 64 - 18;
        self.page = 0;
    }
    return self;
}

- (UIButton *)nextButton{
    if (_nextButton == nil) {
        _nextButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(self.view.frame.size.width - 110, 12, 100, 40);
        [_nextButton setTitle:@"下一页" forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(pageControll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)previousButton{
    if (_previousButton == nil) {
        _previousButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _previousButton.frame = CGRectMake(10, 12, 100, 40);
        [_previousButton setTitle:@"上一页" forState:UIControlStateNormal];
        [_previousButton addTarget:self action:@selector(pageControll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousButton;
}

- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _contentLabel;
}


- (void)pageControll:(UIButton *)button{
    if (button == _previousButton) {
        if (self.page > 0) {
            self.page--;
        }
    }else{
        if (self.page < [self.rangesArr count]) {
            self.page++;
        }
    }
    NSRange range = [[self.rangesArr objectAtIndex:self.page] rangeValue];
    self.contentLabel.text = [self.contentString substringWithRange:range];
}

- (UIView *)navigationView{
    if (_navigationView == nil) {
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _navigationView.backgroundColor = [UIColor redColor];
    }
    return _navigationView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.previousButton];
    [self.navigationView addSubview:self.nextButton];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.contentLabel];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
    self.contentString = [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    self.rangesArr = [self getPageRanges];
    NSRange range = [[self.rangesArr objectAtIndex:0] rangeValue];
    self.contentLabel.text = [self.contentString substringWithRange:range];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (NSArray *)getPageRanges{
    NSMutableArray *ranges = [NSMutableArray array];
    NSArray *paras = [self.contentString componentsSeparatedByString:@"\n"];
    self.lineHight = [@"测试" sizeWithFont:[UIFont systemFontOfSize:15]].height;
    NSInteger maxLine = floor(self.hight/_lineHight);
    NSInteger totalLines = 0;
    NSString  *lastParaLeft = nil;
    NSRange range = NSMakeRange(0, 0);
    for (int i = 0; i < [paras count]; i++) {
        NSString *content = nil;
        if (lastParaLeft != nil) {
            content = lastParaLeft;
            lastParaLeft = nil;
        }else{
            content = [paras objectAtIndex:i];
            content = [content stringByAppendingString:@"\n"];
        }
        CGSize contentSize = [self getContentSize:content];
        NSInteger paraLines = floor(contentSize.height/_lineHight);
        if (totalLines + paraLines < maxLine) {
            totalLines += paraLines;
            range.length += [content length];
            range = NSMakeRange(range.location, range.length);
            if (i == [paras count] - 1) {
                [ranges addObject:[NSValue valueWithRange:range]];
            }
        }else if(totalLines + paraLines == maxLine){
            range.length += [content length];
            [ranges addObject:[NSValue valueWithRange:range]];
            totalLines = 0;
            range.location = range.location + [content length];
            range.length = 0;
        }else{
            NSInteger lineLeft = maxLine - totalLines;
            CGSize tmpSize;
            int j = 0;
            for (j = 0; j < [content length]; j++) {
                NSString *tempStr = [content substringToIndex:j];
                tmpSize = [self getContentSize:tempStr];
                int nowLine = floor(tmpSize.height/_lineHight);
                if (lineLeft < nowLine) {
                    lastParaLeft = [content substringFromIndex:j - 1];
                    break;
                }
            }
            range.length += j -1;
            [ranges addObject:[NSValue valueWithRange:range]];
            range.location += range.length;
            range.length = 0;
            totalLines = 0;
            i--;
        }
    }
    return ranges;
}


- (CGSize)getContentSize:(NSString *)content{
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15]
                      constrainedToSize:CGSizeMake(self.view.frame.size.width,MAXFLOAT)
                          lineBreakMode:NSLineBreakByCharWrapping];
    return size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
