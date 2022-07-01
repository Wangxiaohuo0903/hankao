//
//  YBPopupMenu.m
//  YBPopupMenu
//
//  Created by lyb on 2017/5/10.
//  Copyright © 2017年 lyb. All rights reserved.
//

#import "YBPopupMenu.h"
#import "YBPopupMenuPath.h"

#define YBScreenWidth [UIScreen mainScreen].bounds.size.width
#define YBScreenHeight [UIScreen mainScreen].bounds.size.height
#define YBMainWindow  [UIApplication sharedApplication].keyWindow
#define YB_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

#pragma mark - /////////////
#pragma mark - private cell

@interface YBPopupMenuCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, strong) UIColor * separatorColor;
@property (nonatomic, strong) UILabel * centerLabel;
@end

@implementation YBPopupMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isShowSeparator = YES;
        [self setNeedsDisplay];
    }
    return self;
}
- (UILabel *)centerLabel {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.bounds.size.width - 24, self.bounds.size.height)];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.numberOfLines = 4;
        [self.contentView addSubview:_centerLabel];
    }
    _centerLabel.frame = CGRectMake(12, 0, self.bounds.size.width - 24, self.bounds.size.height);
    return _centerLabel;
}
- (void)layoutSubviews {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.bounds.size.width - 24, self.bounds.size.height)];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.numberOfLines = 4;
        [self.contentView addSubview:_centerLabel];
    }
    _centerLabel.frame = CGRectMake(12, 0, self.bounds.size.width - 24, self.bounds.size.height);
}
- (void)setIsShowSeparator:(BOOL)isShowSeparator
{
    _isShowSeparator = isShowSeparator;
    [self setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    _centerLabel.frame = CGRectMake(12, 0, self.bounds.size.width - 24, self.bounds.size.height);
}

@end



@interface YBPopupMenu ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UIView      * menuBackView;
@property (nonatomic) CGRect                relyRect;
@property (nonatomic, assign) CGFloat       itemWidth;
@property (nonatomic) CGPoint               point;
@property (nonatomic, assign) BOOL          isCornerChanged;
@property (nonatomic, strong) UIColor     * separatorColor;
@property (nonatomic, assign) BOOL          isChangeDirection;
@property (nonatomic, strong) YBPopupMenu *popupMenu;
@end

@implementation YBPopupMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultSettings];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"DismissPop" object:nil];
    }
    return self;
}

#pragma mark - publics
+ (YBPopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] init];
    popupMenu.point = point;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    popupMenu.delegate = delegate;
    [popupMenu showInView:nil];
    return popupMenu;
}

- (YBPopupMenu *)showRelyOnView:(UIView *)view superView:(UIView *)superView titles:(NSArray *)titles icons:(NSArray *)icons difficultyLevel:(int)difficultyLevel menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    if (_popupMenu) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuBeganDismiss)]) {
            [self.delegate ybPopupMenuBeganDismiss];
        }
        //        [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        _menuBackView.alpha = 0;
        //        } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidDismiss)]) {
            [self.delegate ybPopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [_menuBackView removeFromSuperview];
        
        CGRect absoluteRect = [view convertRect:view.bounds toView:superView];
        CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
        _popupMenu.point = relyPoint;
        _popupMenu.relyRect = absoluteRect;
        _popupMenu.titles = titles;
        _popupMenu.images = icons;
        if (!difficultyLevel) {
            _popupMenu.level.text = @"HSK 1";
        }else {
            _popupMenu.level.text = [NSString stringWithFormat:@"HSK %d",difficultyLevel];
        }
        _popupMenu.itemWidth = itemWidth;
        _popupMenu.delegate = delegate;
        [_popupMenu showInView:superView];
        return _popupMenu;
        //        }];
        
    }else {
        _popupMenu = [[YBPopupMenu alloc] init];
        CGRect absoluteRect = [view convertRect:view.bounds toView:superView];
        CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
        _popupMenu.point = relyPoint;
        _popupMenu.relyRect = absoluteRect;
        _popupMenu.titles = titles;
        _popupMenu.images = icons;
        if (!difficultyLevel) {
            _popupMenu.level.text = @"HSK 1";
        }else {
            _popupMenu.level.text = [NSString stringWithFormat:@"HSK %d",difficultyLevel];
        }
        _popupMenu.itemWidth = itemWidth;
        _popupMenu.delegate = delegate;
        [_popupMenu showInView:superView];
        return _popupMenu;
        
    }
}

+ (YBPopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (YBPopupMenu * popupMenu))otherSetting
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] init];
    popupMenu.point = point;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    YB_SAFE_BLOCK(otherSetting,popupMenu);
    [popupMenu showInView:nil];
    return popupMenu;
}

+ (YBPopupMenu *)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (YBPopupMenu * popupMenu))otherSetting
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:YBMainWindow];
    CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] init];
    popupMenu.point = relyPoint;
    popupMenu.relyRect = absoluteRect;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    YB_SAFE_BLOCK(otherSetting,popupMenu);
    [popupMenu showInView:nil];
    return popupMenu;
}

- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuBeganDismiss)]) {
        [self.delegate ybPopupMenuBeganDismiss];
    }
//    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        _menuBackView.alpha = 0;
//    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidDismiss)]) {
            [self.delegate ybPopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [_menuBackView removeFromSuperview];
//    }];
}

#pragma mark tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ybPopupMenu";
    YBPopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YBPopupMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.centerLabel.numberOfLines = 0;
    }
    if (indexPath.row == 2) {
        cell.centerLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
        cell.centerLabel.numberOfLines = 4;
    }else {
        cell.centerLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        cell.centerLabel.numberOfLines = 1;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat font = [@[@16,@18,@12][indexPath.row] floatValue];
    cell.centerLabel.font = [UIFont systemFontOfSize:font];
    cell.centerLabel.textAlignment = NSTextAlignmentCenter;
    cell.centerLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    if ([_titles[indexPath.row] isKindOfClass:[NSAttributedString class]]) {
        cell.centerLabel.attributedText = _titles[indexPath.row];
    }else if ([_titles[indexPath.row] isKindOfClass:[NSString class]]) {
        cell.centerLabel.text = _titles[indexPath.row];
    }else {
        cell.centerLabel.text = nil;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //英文的高度
    CGSize rect = [_titles[2] boundingRectWithSize:CGSizeMake(180 - 24, 92) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:12]} context:nil].size;
    CGFloat height = rect.height;
    if (height > 92) {
        height = 92;
    }
    if (indexPath .row == 0) {
        return 16 + 5;
    }else if (indexPath .row == 1) {
        return 18 + 5;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    if (_dismissOnSelected) [self dismiss];
    //
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidSelectedAtIndex:ybPopupMenu:)]) {
    //
    //        [self.delegate ybPopupMenuDidSelectedAtIndex:indexPath.row ybPopupMenu:self];
    //    }
    //
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenu:didSelectedAtIndex:)]) {
    //        [self.delegate ybPopupMenu:self didSelectedAtIndex:indexPath.row];
    //    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([[self getLastVisibleCell] isKindOfClass:[YBPopupMenuCell class]]) {
        YBPopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([[self getLastVisibleCell] isKindOfClass:[YBPopupMenuCell class]]) {
        YBPopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = NO;
    }
}

- (YBPopupMenuCell *)getLastVisibleCell
{
    NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row < obj2.row;
    }];
    NSIndexPath *indexPath = indexPaths.firstObject;
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - privates
- (void)showInView:(UIView *)superView
{
    
    if (superView == nil) {
        [YBMainWindow addSubview:_menuBackView];
        [YBMainWindow addSubview:self];
    }else {
        [superView addSubview:_menuBackView];
        [superView addSubview:self];
        [superView addSubview:_menuBackView];
        [superView bringSubviewToFront:self];
    }
    if ([[self getLastVisibleCell] isKindOfClass:[YBPopupMenuCell class]]) {
        YBPopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuBeganShow)]) {
        [self.delegate ybPopupMenuBeganShow];
    }
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        _menuBackView.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidShow)]) {
            [self.delegate ybPopupMenuDidShow];
        }
    }];
}

- (void)setDefaultSettings
{
    _cornerRadius = 5.0;
    _rectCorner = UIRectCornerAllCorners;
    self.isShowShadow = YES;
    _dismissOnSelected = YES;
    _dismissOnTouchOutside = YES;
    _fontSize = 15;
    _textColor = [UIColor blackColor];
    _offset = 0.0;
    _relyRect = CGRectZero;
    _point = CGPointZero;
    _borderWidth = 0.0;
    _borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _arrowWidth = 15.0;
    _arrowHeight = 5.0;
    _backColor = [UIColor whiteColor];
    _type = YBPopupMenuTypeDefault;
    _arrowDirection = YBPopupMenuArrowDirectionTop;
    _priorityDirection = YBPopupMenuPriorityDirectionTop;
    _minSpace = 50.0;
    _maxVisibleCount = 5;
    _itemHeight = 44;
    _tableViewHeight = 65;
    _isCornerChanged = NO;
    _showMaskView = YES;
    _menuBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YBScreenWidth, YBScreenHeight)];
    _menuBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _menuBackView.alpha = 1;
    _menuBackView.userInteractionEnabled = NO;
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(touchOutSide)];
    //    [_menuBackView addGestureRecognizer: tap];
    self.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    [self bringSubviewToFront:self.tableView];
    [self addSubview:self.level];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
- (UILabel *)level {
    if (!_level) {
        _level = [[UILabel alloc] initWithFrame:CGRectZero];
        _level.textColor = [UIColor whiteColor];
        _level.textAlignment = NSTextAlignmentCenter;
        _level.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:116.0/255.0 blue:206.0/255.0 alpha:1];
        _level.font = [UIFont fontWithName:@"PingFangSC-Regular" size:8];
        
    }
    return _level;
}
- (void)touchOutSide
{
    if (_dismissOnTouchOutside) {
        [self dismiss];
    }
}

- (void)setIsShowShadow:(BOOL)isShowShadow
{
    _isShowShadow = isShowShadow;
    self.layer.shadowOpacity = isShowShadow ? 0.1 : 0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = isShowShadow ? 5.0 : 0;
}

- (void)setShowMaskView:(BOOL)showMaskView
{
    _showMaskView = showMaskView;
    _menuBackView.backgroundColor = showMaskView ? [[UIColor blackColor] colorWithAlphaComponent:0.1] : [UIColor clearColor];
}

- (void)setType:(YBPopupMenuType)type
{
    _type = type;
    switch (type) {
        case YBPopupMenuTypeDark:
        {
            _textColor = [UIColor lightGrayColor];
            _backColor = [UIColor colorWithRed:0.25 green:0.27 blue:0.29 alpha:1];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
            
        default:
        {
            _textColor = [UIColor blackColor];
            _backColor = [UIColor whiteColor];
            //            _separatorColor = [UIColor lightGrayColor];
        }
            break;
    }
    [self updateUI];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self.tableView reloadData];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self.tableView reloadData];
}

- (void)setPoint:(CGPoint)point
{
    _point = point;
    [self updateUI];
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    _itemWidth = itemWidth;
    [self updateUI];
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    _itemHeight = itemHeight;
    [self updateUI];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self updateUI];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self updateUI];
}

- (void)setArrowPosition:(CGFloat)arrowPosition
{
    _arrowPosition = arrowPosition;
    [self updateUI];
}

- (void)setArrowWidth:(CGFloat)arrowWidth
{
    _arrowWidth = arrowWidth;
    [self updateUI];
}

- (void)setArrowHeight:(CGFloat)arrowHeight
{
    _arrowHeight = arrowHeight;
    [self updateUI];
}

- (void)setArrowDirection:(YBPopupMenuArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self updateUI];
}

- (void)setMaxVisibleCount:(NSInteger)maxVisibleCount
{
    _maxVisibleCount = maxVisibleCount;
    [self updateUI];
}

- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    [self updateUI];
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self updateUI];
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    [self updateUI];
}

- (void)setPriorityDirection:(YBPopupMenuPriorityDirection)priorityDirection
{
    _priorityDirection = priorityDirection;
    [self updateUI];
}

- (void)setRectCorner:(UIRectCorner)rectCorner
{
    _rectCorner = rectCorner;
    [self updateUI];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self updateUI];
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    [self updateUI];
}

- (void)updateUI
{
    CGFloat height;
    //英文的高度
    CGSize rect = [_titles[2]  boundingRectWithSize:CGSizeMake(180 - 24, 92) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:12]} context:nil].size;
    CGFloat cellHeight = rect.height;
    if (cellHeight > 92) {
        cellHeight = 92;
    }
    if (_titles.count > _maxVisibleCount) {
        height =  16 + 18 + 10 + cellHeight + 15;
        self.tableView.bounces = YES;
    }else {
        height = 16 + 18 + 10 + cellHeight + 15;
        self.tableView.bounces = NO;
    }
    _isChangeDirection = NO;
    if (_priorityDirection == YBPopupMenuPriorityDirectionTop) {
        if (_point.y + height + _arrowHeight > YBScreenHeight - _minSpace) {
            _arrowDirection = YBPopupMenuArrowDirectionBottom;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = YBPopupMenuArrowDirectionTop;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == YBPopupMenuPriorityDirectionBottom) {
        if (_point.y - height - _arrowHeight < _minSpace) {
            _arrowDirection = YBPopupMenuArrowDirectionTop;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = YBPopupMenuArrowDirectionBottom;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == YBPopupMenuPriorityDirectionLeft) {
        if (_point.x + _itemWidth + _arrowHeight > YBScreenWidth - _minSpace) {
            _arrowDirection = YBPopupMenuArrowDirectionRight;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = YBPopupMenuArrowDirectionLeft;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == YBPopupMenuPriorityDirectionRight) {
        if (_point.x - _itemWidth - _arrowHeight < _minSpace) {
            _arrowDirection = YBPopupMenuArrowDirectionLeft;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = YBPopupMenuArrowDirectionRight;
            _isChangeDirection = NO;
        }
    }
    [self setArrowPosition];
    [self setRelyRect];
    
    if (_arrowDirection == YBPopupMenuArrowDirectionTop) {
        CGFloat y = _isChangeDirection ? _point.y  : _point.y ;
        y = y + 5;
        if (_arrowPosition > _itemWidth / 2) {
            self.frame = CGRectMake(YBScreenWidth - _minSpace - _itemWidth, y, _itemWidth, height + _arrowHeight);
        }else if (_arrowPosition < _itemWidth / 2) {
            self.frame = CGRectMake(_minSpace, y, _itemWidth, height + _arrowHeight);
        }else {
            self.frame = CGRectMake(_point.x - _itemWidth / 2, y, _itemWidth, height + _arrowHeight);
        }
    }else if (_arrowDirection == YBPopupMenuArrowDirectionBottom) {
        CGFloat y = _isChangeDirection ? _point.y - _arrowHeight - height : _point.y - _arrowHeight - height;
        y = y + 5;
        if (_arrowPosition > _itemWidth / 2) {
            self.frame = CGRectMake(YBScreenWidth - _minSpace - _itemWidth, y, _itemWidth, height + _arrowHeight);
        }else if (_arrowPosition < _itemWidth / 2) {
            self.frame = CGRectMake(_minSpace, y, _itemWidth, height + _arrowHeight);
        }else {
            self.frame = CGRectMake(_point.x - _itemWidth / 2, y, _itemWidth, height + _arrowHeight);
        }
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft) {
        CGFloat x = _isChangeDirection ? _point.x : _point.x;
        if (_arrowPosition < _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else if (_arrowPosition > _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }
    }else if (_arrowDirection == YBPopupMenuArrowDirectionRight) {
        CGFloat x = _isChangeDirection ? _point.x - _itemWidth - _arrowHeight : _point.x - _itemWidth - _arrowHeight;
        if (_arrowPosition < _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else if (_arrowPosition > _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }
    }else if (_arrowDirection == YBPopupMenuArrowDirectionNone) {
        
    }
    
    if (_isChangeDirection) {
        [self changeRectCorner];
    }
    [self setAnchorPoint];
    [self setOffset];
    [self.tableView reloadData];
    [self setNeedsDisplay];
}

- (void)setRelyRect
{
    if (CGRectEqualToRect(_relyRect, CGRectZero)) {
        return;
    }
    if (_arrowDirection == YBPopupMenuArrowDirectionTop) {
        _point.y = _relyRect.size.height + _relyRect.origin.y;
    }else if (_arrowDirection == YBPopupMenuArrowDirectionBottom) {
        _point.y = _relyRect.origin.y;
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft) {
        _point = CGPointMake(_relyRect.origin.x + _relyRect.size.width, _relyRect.origin.y + _relyRect.size.height / 2);
    }else {
        _point = CGPointMake(_relyRect.origin.x, _relyRect.origin.y + _relyRect.size.height / 2);
    }
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //英文的高度
    //英文的高度
    CGSize rect = [_titles[2]  boundingRectWithSize:CGSizeMake(180 - 24, 92) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:12]} context:nil].size;
    CGFloat cellHeight = rect.height;
    if (cellHeight > 92) {
        cellHeight = 92;
    }
    if (_arrowDirection == YBPopupMenuArrowDirectionTop) {
        self.tableView.frame = CGRectMake(_borderWidth, 14, frame.size.width - _borderWidth * 2, 16 + 18 + 10 + 12 + cellHeight);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionBottom) {
        self.tableView.frame = CGRectMake(_borderWidth, 14, frame.size.width - _borderWidth * 2, 16 + 18 + 10 + 12 + cellHeight);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft) {
        self.tableView.frame = CGRectMake(_borderWidth + _arrowHeight, 25 , frame.size.width - _borderWidth * 2 - _arrowHeight, 16 + 18 + 10 + 12 + cellHeight);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionRight) {
        self.tableView.frame = CGRectMake(_borderWidth , 14 , frame.size.width - _borderWidth * 2 - _arrowHeight, 16 + 18 + 10 + 12 + cellHeight);
    }
    self.level.frame = CGRectMake(0, 5, 30, 13);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_level.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _level.bounds;
    //赋值
    maskLayer.path = maskPath.CGPath;
    _level.layer.mask = maskLayer;
}

- (void)changeRectCorner
{
    if (_isCornerChanged || _rectCorner == UIRectCornerAllCorners) {
        return;
    }
    BOOL haveTopLeftCorner = NO, haveTopRightCorner = NO, haveBottomLeftCorner = NO, haveBottomRightCorner = NO;
    if (_rectCorner & UIRectCornerTopLeft) {
        haveTopLeftCorner = YES;
    }
    if (_rectCorner & UIRectCornerTopRight) {
        haveTopRightCorner = YES;
    }
    if (_rectCorner & UIRectCornerBottomLeft) {
        haveBottomLeftCorner = YES;
    }
    if (_rectCorner & UIRectCornerBottomRight) {
        haveBottomRightCorner = YES;
    }
    
    if (_arrowDirection == YBPopupMenuArrowDirectionTop || _arrowDirection == YBPopupMenuArrowDirectionBottom) {
        
        if (haveTopLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomLeft);
        }
        if (haveTopRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomRight);
        }
        if (haveBottomLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopLeft);
        }
        if (haveBottomRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopRight);
        }
        
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft || _arrowDirection == YBPopupMenuArrowDirectionRight) {
        if (haveTopLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopRight);
        }
        if (haveTopRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopLeft);
        }
        if (haveBottomLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomRight);
        }
        if (haveBottomRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomLeft);
        }
    }
    
    _isCornerChanged = YES;
}

- (void)setOffset
{
    if (_itemWidth == 0) return;
    
    CGRect originRect = self.frame;
    
    if (_arrowDirection == YBPopupMenuArrowDirectionTop) {
        originRect.origin.y += _offset;
    }else if (_arrowDirection == YBPopupMenuArrowDirectionBottom) {
        originRect.origin.y -= _offset;
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft) {
        originRect.origin.x += _offset;
    }else if (_arrowDirection == YBPopupMenuArrowDirectionRight) {
        originRect.origin.x -= _offset;
    }
    self.frame = originRect;
}

- (void)setAnchorPoint
{
    if (_itemWidth == 0) return;
    
    CGPoint point = CGPointMake(0.5, 0.5);
    if (_arrowDirection == YBPopupMenuArrowDirectionTop) {
        point = CGPointMake(_arrowPosition / _itemWidth, 0);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionBottom) {
        point = CGPointMake(_arrowPosition / _itemWidth, 1);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft) {
        point = CGPointMake(0, (_itemHeight - _arrowPosition) / _itemHeight);
    }else if (_arrowDirection == YBPopupMenuArrowDirectionRight) {
        point = CGPointMake(1, (_itemHeight - _arrowPosition) / _itemHeight);
    }
    CGRect originRect = self.frame;
    self.layer.anchorPoint = point;
    self.frame = originRect;
}

- (void)setArrowPosition
{
    if (_priorityDirection == YBPopupMenuPriorityDirectionNone) {
        return;
    }
    if (_arrowDirection == YBPopupMenuArrowDirectionTop || _arrowDirection == YBPopupMenuArrowDirectionBottom) {
        if (_point.x + _itemWidth / 2 > YBScreenWidth - _minSpace) {
            _arrowPosition = _itemWidth - (YBScreenWidth - _minSpace - _point.x);
        }else if (_point.x < _itemWidth / 2 + _minSpace) {
            _arrowPosition = _point.x - _minSpace;
        }else {
            _arrowPosition = _itemWidth / 2;
        }
        
    }else if (_arrowDirection == YBPopupMenuArrowDirectionLeft || _arrowDirection == YBPopupMenuArrowDirectionRight) {
        //        if (_point.y + _itemHeight / 2 > YBScreenHeight - _minSpace) {
        //            _arrowPosition = _itemHeight - (YBScreenHeight - _minSpace - _point.y);
        //        }else if (_point.y < _itemHeight / 2 + _minSpace) {
        //            _arrowPosition = _point.y - _minSpace;
        //        }else {
        //            _arrowPosition = _itemHeight / 2;
        //        }
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [YBPopupMenuPath yb_bezierPathWithRect:rect rectCorner:_rectCorner cornerRadius:_cornerRadius borderWidth:_borderWidth borderColor:_borderColor backgroundColor:[UIColor whiteColor] arrowWidth:_arrowWidth arrowHeight:_arrowHeight arrowPosition:_arrowPosition arrowDirection:_arrowDirection];
    [bezierPath fill];
    [bezierPath stroke];
}

@end
