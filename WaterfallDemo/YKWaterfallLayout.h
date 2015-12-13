//
//  YKWaterfallLayout.h
//  WaterfallDemo
//
//  Created by Yang Kai on 15/12/13.
//  Copyright © 2015年 lamewing. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * in this waterfall layout only section 0 is considered
 */
@interface YKWaterfallLayout : UICollectionViewLayout

/**
 * initializer
 * @param columnNum the number of columns, a positive integer
 */
- (instancetype)initWithWaterfallColumnNum:(NSInteger)columnNum;

@end
