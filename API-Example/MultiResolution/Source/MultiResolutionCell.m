//
//  MultiResolutionCell.m
//  MultiResolution
//
//  Created by aqi on 2025/6/25.
//

#import "MultiResolutionCell.h"

@implementation MultiResolutionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
