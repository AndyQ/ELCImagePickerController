//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"

@interface ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed:)];
        [longPress setMinimumPressDuration:0.25];
        [self addGestureRecognizer:longPress];

	}
	return self;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {

        ELCAsset *asset = [_rowAssets objectAtIndex:i];

        UIImageView *imageView;
        if (i < [_imageViewArray count]) {
            imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
        } else {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageViewArray addObject:imageView];
        }
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        imageView.layer.borderWidth = 1;
        
        if (i < [_overlayViewArray count]) {
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)cellPressed:(UILongPressGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [tapRecognizer locationInView:self];
        CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
        CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
        
        CGRect frame = CGRectMake(startX, 2, 75, 75);
        
        for (int i = 0; i < [_rowAssets count]; ++i)
        {
            if (CGRectContainsPoint(frame, point))
            {
                ELCAsset *asset = [_rowAssets objectAtIndex:i];
                
                CGRect displayFrame = CGRectMake( self.frame.origin.x + frame.origin.x, self.frame.origin.y + 2, 75, 75 );
                [self.delegate cellLongPressed:displayFrame asset:asset];
            }
            frame.origin.x = frame.origin.x + frame.size.width + 4;
        }
    }
    else if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.delegate cellLongReleased];
    }

}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{    
    CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}


@end
