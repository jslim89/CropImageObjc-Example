//
//  ViewController.m
//  CropImageExample
//
//  Created by Js on 12/8/14.
//
//

#import "ViewController.h"
#import "CropViewController.h"

@interface ViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate>

@property (nonatomic) UIImageView *maskView;
@property (nonatomic) UIImageView *cropImageView;
@property (nonatomic) UIButton *photoButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sungoku"]];
    _maskView.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, (CGRectGetHeight(self.view.frame) / 2.0) - 30);
    [self.view addSubview:_maskView];
    
    // kCropFrame = the image frame
    // where _cropImageView is relative to self.view (not _maskView), thus have to adjust the frame
    _cropImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(kCropFrame) + CGRectGetMinX(_maskView.frame), CGRectGetMinY(kCropFrame) + CGRectGetMinY(_maskView.frame), CGRectGetWidth(kCropFrame), CGRectGetHeight(kCropFrame))];
    [self.view insertSubview:_cropImageView belowSubview:_maskView];
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.frame = CGRectMake(20, CGRectGetMaxY(_maskView.frame) + 40, CGRectGetWidth(self.view.frame) - 40, 40);
    _photoButton.layer.cornerRadius = 5;
    _photoButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1];
    _photoButton.titleLabel.textColor = [UIColor whiteColor];
    [_photoButton setTitle:@"Photo" forState:UIControlStateNormal];
    [_photoButton addTarget:self action:@selector(photoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_photoButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event
- (void)photoTapped:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - CropViewControllerDelegate
- (void)cropViewControllerDidCroppedImage:(UIImage *)image
{
    // Solution 1: crop the UIImage to oval shape
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //you have to account for the x and y values of your UIBezierPath rect
    UIGraphicsBeginImageContext(image.size);
    //this gets the graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    //you can stroke and/or fill
    CGContextSetFillColorWithColor(context, [UIColor colorWithPatternImage:image].CGColor);
    [path fill];
    //now get the image from the context
    UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Solution 2: the image remain in rectangle, mask the UIImageView
    /*
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:_cropImageView.bounds];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    _cropImageView.layer.mask = maskLayer;
     */
    
    // save to library
    // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    _cropImageView.image = bezierImage;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        CropViewController *controller = [[CropViewController alloc] init];
        controller.delegate = self;
        controller.faceImage = info[UIImagePickerControllerEditedImage];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:nil];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = buttonIndex == 1 ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

@end
