//
//  YKWaterfallLayout.m
//  WaterfallDemo
//
//  Created by Yang Kai on 15/12/13.
//  Copyright © 2015年 lamewing. All rights reserved.
//

#import "YKWaterfallLayout.h"

NSString *NSStringFromNSIndexPath(NSIndexPath *indexPath)
{
    return [NSString stringWithFormat:@"%ld__%ld", indexPath.section, indexPath.item];
}

NSIndexPath *NSIndexPathFromNSString(NSString *indexPathStr)
{
    NSArray *comps = [indexPathStr componentsSeparatedByString:@"__"];
    if (comps.count != 2) {
        return nil;
    }
    
    NSInteger section = [comps[0] integerValue];
    NSInteger item = [comps[1] integerValue];
    return [NSIndexPath indexPathForItem:item inSection:section];
}


@interface YKWaterfallLayout ()

@property (nonatomic, assign) NSInteger columnNum;

@property (nonatomic, strong) NSMutableDictionary *frame2IndexPathDict;

@property (nonatomic, strong) NSMutableDictionary *indexPath2FrameDict;

@end

@implementation YKWaterfallLayout

- (instancetype)init
{
    if (self = [super init]) {
        
        self.columnNum = 2;
        self.frame2IndexPathDict = [NSMutableDictionary dictionary];
        self.indexPath2FrameDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithWaterfallColumnNum:(NSInteger)columnNum
{
    if (self =[self init]) {
        
        self.columnNum = columnNum >= 1 ?columnNum : 2;
    }
    return self;
}

#pragma mark - implementing superclass' methods
- (void)prepareLayout
{
    [super prepareLayout];
    
    [self generateCellFrames];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    layoutAttributes.frame = [self frameForIndexPath:indexPath];
    return layoutAttributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttrs = [NSMutableArray array];
    
    NSArray *indexPaths = [self indexPathsOfItemsIntersectingWithRect:rect];
    for (NSIndexPath *indexPath in indexPaths) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttrs addObject:attr];
    }
    
    return [layoutAttrs copy];
}

- (CGSize)collectionViewContentSize
{
    CGSize size = self.collectionView.frame.size;
    
    float maxHeight = 0;
    NSInteger columnNum = self.columnNum;
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = count - 1; i >= 0 && i >= count - columnNum; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGRect frame = [self frameForIndexPath:indexPath];
        CGFloat frameMaxY = CGRectGetMaxY(frame);
        
        if (frameMaxY > maxHeight) {
            maxHeight = frameMaxY;
        }
    }
    
    UIEdgeInsets sectionInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:0];
    size.height = maxHeight + sectionInsets.bottom;
    
    return size;
}

#pragma mark - private methods
- (void)generateCellFrames
{
    [self.frame2IndexPathDict removeAllObjects];
    [self.indexPath2FrameDict removeAllObjects];
    
    // in this layout only section 0 is considered
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    if (!count) {
        return;
    }
    
    id<UICollectionViewDelegateFlowLayout> dlg = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    
    UIEdgeInsets sectionInsets = [dlg collectionView:self.collectionView layout:self insetForSectionAtIndex:0];
    
    const NSInteger columnNum = self.columnNum;
    
    // height of each column
    NSMutableArray *columnHeights = [NSMutableArray array];
    for (NSInteger i = 0; i < columnNum; i++) {
        // initial value: insects.top
        [columnHeights addObject:@(sectionInsets.top)];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGSize itemSize = [dlg collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        // get the current shortest column and the corresponding height
        NSInteger shortCol = 0;
        float shortColHeight = [columnHeights[shortCol] floatValue];
        for (NSInteger j = 1; j < columnNum; j++) {
            float colHeight = [columnHeights[j] floatValue];
            if (colHeight < shortColHeight) {
                shortColHeight = colHeight;
                shortCol = j;
            }
        }
        
        // current item's frame
        CGRect itemFrame = ({
            CGFloat w = itemSize.width;
            CGFloat h = itemSize.height;
            CGFloat x = sectionInsets.left + shortCol * w;
            CGFloat y = shortColHeight;
            
            CGRectMake(x, y, w, h);
        });
        
        // update the column height
        columnHeights[shortCol] = @(CGRectGetMaxY(itemFrame));
        
        // save the frame
        [self saveIndexPath:indexPath andFrame:itemFrame];
    }
}


- (void)saveIndexPath:(NSIndexPath *)indexPath andFrame:(CGRect)frame
{
    NSString *indexPathStr = NSStringFromNSIndexPath(indexPath);
    NSString *frameStr = NSStringFromCGRect(frame);
    
    self.indexPath2FrameDict[indexPathStr] = frameStr;
    self.frame2IndexPathDict[frameStr] = indexPathStr;
}

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath
{
    NSString *indexPathStr = NSStringFromNSIndexPath(indexPath);
    return  CGRectFromString(self.indexPath2FrameDict[indexPathStr]);
}

- (NSIndexPath *)indexPathForFrame:(CGRect)frame
{
    NSString *frameStr = NSStringFromCGRect(frame);
    return NSIndexPathFromNSString(self.frame2IndexPathDict[frameStr]);
}

- (NSArray *)indexPathsOfItemsIntersectingWithRect:(CGRect)rect
{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *frameStr in self.frame2IndexPathDict) {
        CGRect frame = CGRectFromString(frameStr);
        if (CGRectIntersectsRect(frame, rect)) {
            NSIndexPath *indexPath = [self indexPathForFrame:frame];
            [arrM addObject:indexPath];
        }
    }
    return [arrM copy];
}

@end
