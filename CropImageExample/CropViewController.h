//
//  CropViewController.h
//  CropImageExample
//
//  Created by Js on 12/8/14.
//
//

#import <UIKit/UIKit.h>

@protocol CropViewControllerDelegate <NSObject>

- (void)cropViewControllerDidCroppedImage:(UIImage *)image;

@end

@interface CropViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<CropViewControllerDelegate> delegate;
@property (nonatomic) UIImage *faceImage;

@end
