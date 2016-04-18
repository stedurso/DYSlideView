//
//  DYSlideView.m
//  DYSlideView
//
//  Created by Dwarven on 16/4/18.
//  Copyright © 2016年 Dwarven. All rights reserved.
//

#import "DYSlideView.h"

@interface DYSlideView () <UIScrollViewDelegate> {
    NSInteger _numberOfViewControllers;
    NSArray * _titlesForViewControllers;
    BOOL _didSelectItemAtIndexDefined;
    UIView * _slideBar;
    UIView * _slider;
    NSMutableArray *_buttonsArray;
    UIButton * _selectedButton;
    NSInteger _currentBtnIndex;
    UIScrollView *_scrollView;
}

@end

@implementation DYSlideView

- (void)setDelegate:(id<DYSlideViewDelegate>)delegate {
    _delegate = delegate;
    _didSelectItemAtIndexDefined = [_delegate respondsToSelector:@selector(DY_didSelectButtonAtIndex:)];
}

- (id)init {
    self = [super init];
    if (self) {
        _slideBarColor = [UIColor lightGrayColor];
        _sliderColor = [UIColor redColor];;
        _buttonNormalColor = [UIColor whiteColor];
        _buttonSelectedColor = [UIColor blackColor];
        _sliderScale = 1.f;
        _slideBarHeight = 50.f;
        _sliderHeight = 4.f;
        _buttonTitleFont = [UIFont systemFontOfSize:16.f];
        _scrollViewBounces = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _numberOfViewControllers = [self.delegate DY_numberOfViewControllersInSlideView];
    _titlesForViewControllers = [self.delegate DY_titlesForViewControllersInSlideView];
    [self addSlideBar];
    [self addScrollView];
    [self updateSelectedButton];
    [_selectedButton setTitleColor:_buttonSelectedColor forState:UIControlStateNormal];
}

- (void)addSlideBar {
    if (!_slideBar) {
        _slideBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _slideBarHeight)];
        [_slideBar setBackgroundColor:_slideBarColor];
        [self addSubview:_slideBar];
    }
    [self addButtons];
    [self addSlider];
}

- (void)addButtons {
    _buttonsArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _numberOfViewControllers; i++) {
        
        CGFloat width = self.bounds.size.width / _numberOfViewControllers;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake( width * i, 5, width, 35)];
        [button setTag:i];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button.titleLabel setFont:_buttonTitleFont];
        [button setTitleColor:_buttonNormalColor forState:UIControlStateNormal];
        [button setTitle:[_titlesForViewControllers objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_buttonsArray addObject:button];
        [_slideBar addSubview:button];
    }
}

- (void)addSlider {
    if (!_slider) {
        CGFloat buttonWidth = self.bounds.size.width / _numberOfViewControllers;
        CGFloat sliderWidth = buttonWidth * _sliderScale;
        
        _slider = [[UIView alloc] initWithFrame:CGRectMake((buttonWidth - sliderWidth)/2, _slideBarHeight-_sliderHeight, sliderWidth, _sliderHeight)];
        [_slider setBackgroundColor:_sliderColor];
        [_slideBar addSubview:_slider];
    }
}

- (void)addScrollView {
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setFrame:CGRectMake(0, _slideBarHeight, self.bounds.size.width, self.frame.size.height - _slideBarHeight)];
    [_scrollView setDirectionalLockEnabled:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _numberOfViewControllers, 0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setDelegate:self];
    [_scrollView setBounces:_scrollViewBounces];
    
    [self addSubview:_scrollView];
    
    NSArray *cvcs = [self.delegate DY_viewControllersInSlideView];
    for (UIViewController *vc in cvcs) {
        CGRect rect = _scrollView.bounds;
        rect.origin.x = self.bounds.size.width * [cvcs indexOfObject:vc];
        [vc.view setFrame:rect];
        [_scrollView addSubview:vc.view];
    }
}

- (void)buttonClicked:(UIButton *)button {
    [_scrollView setContentOffset:CGPointMake(self.bounds.size.width * button.tag, 0) animated:YES];
}

- (void)updateSelectedButton{
    if (!(_selectedButton && [_buttonsArray indexOfObject:_selectedButton] == _currentBtnIndex)) {
        _selectedButton = [_buttonsArray objectAtIndex:_currentBtnIndex];
        if (_didSelectItemAtIndexDefined) {
            [self.delegate DY_didSelectButtonAtIndex:[_selectedButton tag]];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat buttonWidth = self.bounds.size.width / _numberOfViewControllers;
    CGFloat sliderWidth = buttonWidth * _sliderScale;
    CGRect rect = _slider.frame;
    rect.origin.x = (contentOffset.x/self.bounds.size.width) * buttonWidth + (buttonWidth - sliderWidth)/2;
    [_slider setFrame:rect];
    
    CGFloat ratio = contentOffset.x/self.bounds.size.width;
    NSInteger index = (NSInteger)ratio;
    if (ratio - (NSInteger)ratio >= 0.5) {
        index += 1;
    }
    
    if (_currentBtnIndex != index) {
        _currentBtnIndex = index;
        for (UIButton *button in _buttonsArray) {
            if ([_buttonsArray indexOfObject:button] == _currentBtnIndex) {
                [[_buttonsArray objectAtIndex:_currentBtnIndex] setTitleColor:_buttonSelectedColor forState:UIControlStateNormal];
            } else {
                [button setTitleColor:_buttonNormalColor forState:UIControlStateNormal];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateSelectedButton];
}

@end
