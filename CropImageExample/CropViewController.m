//
//  CropViewController.m
//  CropImageExample
//
//  Created by Js on 12/8/14.
//
//

#import "CropViewController.h"

@interface CropViewController ()

@property (nonatomic) UIImageView *maskImageView;
@property (nonatomic) UIScrollView *faceScrollView;
@property (nonatomic) UIImageView *faceImageView;

@end

@implementation CropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Crop";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    
    _faceScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _faceScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    _faceScrollView.delegate = self;
    _faceScrollView.showsHorizontalScrollIndicator = NO;
    _faceScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_faceScrollView];
    
    _faceImageView = [[UIImageView alloc] initWithImage:_faceImage];
    _faceScrollView.contentSize = _faceImageView.bounds.size;
    _faceScrollView.maximumZoomScale = 2;
    _faceScrollView.minimumZoomScale = _faceScrollView.frame.size.width  / _faceImageView.frame.size.width;;
    _faceScrollView.zoomScale = _faceScrollView.minimumZoomScale;
    [_faceScrollView addSubview:_faceImageView];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    overlayView.userInteractionEnabled = NO;
    [self.view addSubview:overlayView];
    
    _maskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sungoku"]];
    _maskImageView.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, (CGRectGetHeight(self.view.frame) / 2.0) - 30);
    [self.view addSubview:_maskImageView];
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:overlayView.bounds];
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(_maskImageView.frame) + CGRectGetMinX(kCropFrame), CGRectGetMinY(_maskImageView.frame) + CGRectGetMinY(kCropFrame), CGRectGetWidth(kCropFrame), CGRectGetHeight(kCropFrame))];
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    [overlayView.layer addSublayer:fillLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (UIImage *)image:(UIImage *)image cropInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

#pragma mark - event
- (void)closeTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped:(id)sender
{
    CGRect placeholderInGlobalSpace = [self.view convertRect:kCropFrame fromView:_maskImageView];
    CGRect selectedRectInFaceImage = [self.view convertRect:placeholderInGlobalSpace toView:_faceImageView];
    
    UIImage *croppedImage = [self image:_faceImage cropInRect:selectedRectInFaceImage];
    
    if ([_delegate respondsToSelector:@selector(cropViewControllerDidCroppedImage:)]) {
        [_delegate cropViewControllerDidCroppedImage:croppedImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)faceScrollView
{
    return _faceImageView;
}

@end
