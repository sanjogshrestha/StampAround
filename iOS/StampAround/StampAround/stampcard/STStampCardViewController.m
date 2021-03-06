//
//  STStampCardViewController.m
//  StampAround
//
//  Created by Thibault Guégan on 03/07/2014.
//  Copyright (c) 2014 StampAround. All rights reserved.
//

#import "STStampCardViewController.h"
#import <ZFModalTransitionAnimator.h>

@interface STStampCardViewController ()

@property(nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@end

@implementation STStampCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_lblStampInstructions setFont:[UIFont fontWithName:@"DINNextRoundedLTPro-Regular" size:14.0f]];
    _lblStampInstructions.textColor = MY_UICOLOR_FROM_HEX_RGB(0xff6a56);
    _lblStampInstructions.text = @"You get the 10'th cup of coffee for free. Offer valid on all coffee drinks on the menu";
    
    [_lblName setFont:[UIFont fontWithName:@"DINNextRoundedLTPro-Bold" size:14.0f]];
    [_lblAddress setFont:[UIFont fontWithName:@"DINNextRoundedLTPro-Regular" size:14.0f]];
    [_lblPhone setFont:[UIFont fontWithName:@"DINNextRoundedLTPro-Regular" size:14.0f]];
    [_lblWebsite setFont:[UIFont fontWithName:@"DINNextRoundedLTPro-Regular" size:14.0f]];
    _lblName.textColor = MY_UICOLOR_FROM_HEX_RGB(0x02272e);
    _lblAddress.textColor = MY_UICOLOR_FROM_HEX_RGB(0x02272e);
    _lblPhone.textColor = MY_UICOLOR_FROM_HEX_RGB(0x02272e);
    _lblWebsite.textColor = MY_UICOLOR_FROM_HEX_RGB(0x02272e);
    
    //test
    [_lblName setText:_store.name];
    [_lblAddress setText:@"laugavegur 100 101 Reykjavik"];
    [_lblPhone setText:@"+354 5563959"];
    [_lblWebsite setText:@"www.teogkaffi.is"];
    
    _bottomBar.delegate = self;

    if(!MY_IS_SCREENHEIGHT_568)
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 580);
    
    _imgArray = [[NSMutableArray alloc] init];
    [_imgArray addObject:_imgStamp1];
    [_imgArray addObject:_imgStamp2];
    [_imgArray addObject:_imgStamp3];
    [_imgArray addObject:_imgStamp4];
    [_imgArray addObject:_imgStamp5];
    [_imgArray addObject:_imgStamp6];
    [_imgArray addObject:_imgStamp7];
    [_imgArray addObject:_imgStamp8];
    [_imgArray addObject:_imgStamp9];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    [_btnHeart addTarget:self
                 action:@selector(addCardToUser)
       forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ST Bottom bar delegate

- (void)mapClicked
{
    STMapViewController *controller = [[STMapViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:controller];
    
    self.animator.dragable = NO;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    
    controller.transitioningDelegate = self.animator;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)stampClicked
{
    // create the scanning view controller and a navigation controller in which to present it:
    CDZQRScanningViewController *scanningVC = [CDZQRScanningViewController new];
    UINavigationController *scanningNavVC = [[UINavigationController alloc] initWithRootViewController:scanningVC];
    
    // configure the scanning view controller:
    scanningVC.resultBlock = ^(NSString *result) {
        //field.text = result;
        NSLog(@"Scanning result: %@", result);
        //[self updateStamps];
        [[STNetworkManager managerWithDelegate:self] sendQRScanResultForValidation:result];
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.cancelBlock = ^() {
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.errorBlock = ^(NSError *error) {
        // todo: show a UIAlertView orNSLog the error
        [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Failed to scan QR Code!" type:TSMessageNotificationTypeError duration:4.0 canBeDismissedByUser:YES];
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    // present the view controller full-screen on iPhone; in a form sheet on iPad:
    scanningNavVC.modalPresentationStyle = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? UIModalPresentationFullScreen : UIModalPresentationFormSheet;
    [self presentViewController:scanningNavVC animated:YES completion:nil];
}

- (void)myCardsClicked
{
    STMyCardsViewController *controller = [[STMyCardsViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:controller];
    
    self.animator.dragable = YES;
    [self.animator setContentScrollView:controller.collectionView];
    self.animator.direction = ZFModalTransitonDirectionBottom;
    
    controller.transitioningDelegate = self.animator;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Update stamps

- (void)updateStamps:(int)currStamps isFinished:(BOOL)finished
{
    if(finished)
    {
        //9 stamps should be displayed already (no 10th, we make success screen appear)
        
        MY_DELAY_MAIN_QUEUE(0.3,^{
            STSuccessViewController *controller = [[STSuccessViewController alloc] init];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:controller animated:NO completion:nil];
            
            for(UIImageView *img in _imgArray)
            {
                //[self setHiddenAnimated:NO view:img];
                [img setAlpha:0];
            }
        });
    }
    else
    {
        //update: make currStamps - 1 appear (others should be available)
        for(UIImageView *img in _imgArray)
        {
            if([img alpha] == 0)
            {
                [UIView animateWithDuration:0.1 animations:^{img.alpha = 1.0;}];
                
                img.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                
                CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                bounceAnimation.values = [NSArray arrayWithObjects:
                                          [NSNumber numberWithFloat:0.5],
                                          [NSNumber numberWithFloat:1.1],
                                          [NSNumber numberWithFloat:0.8],
                                          [NSNumber numberWithFloat:1.0], nil];
                bounceAnimation.duration = 0.3;
                bounceAnimation.removedOnCompletion = NO;
                [img.layer addAnimation:bounceAnimation forKey:@"bounce"];
                
                img.layer.transform = CATransform3DIdentity;
                
                //vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                break;
            }
        }
    }
    
    
    /*int i = 0;
    for(UIImageView *img in _imgArray)
    {
        i++;

        if([img alpha] == 0)
        {
            [UIView animateWithDuration:0.1 animations:^{img.alpha = 1.0;}];
            
            img.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
            
            CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            bounceAnimation.values = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:1.1],
                                      [NSNumber numberWithFloat:0.8],
                                      [NSNumber numberWithFloat:1.0], nil];
            bounceAnimation.duration = 0.3;
            bounceAnimation.removedOnCompletion = NO;
            [img.layer addAnimation:bounceAnimation forKey:@"bounce"];
            
            img.layer.transform = CATransform3DIdentity;
            
            //vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

            break;
        }
    }
    
    if(i==9)
    {
        MY_DELAY_MAIN_QUEUE(0.3,^{
            STSuccessViewController *controller = [[STSuccessViewController alloc] init];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:controller animated:NO completion:nil];
            
            for(UIImageView *img in _imgArray)
            {
                //[self setHiddenAnimated:NO view:img];
                [img setAlpha:0];
            }
        });
        
        i = 0;
    }*/
}

#pragma mark - User Actions

- (void)swipeBackGesture:(UIGestureRecognizer*)gesture{
    
    [self.navigationController popViewControllerAnimated:YES]; 
}

- (void)addCardToUser
{
    _btnHeart.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.8],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.3;
    bounceAnimation.removedOnCompletion = NO;
    [_btnHeart.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    _btnHeart.layer.transform = CATransform3DIdentity;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network Delegate


-(void)downloadResponse:(id)responseObject message:(NSString *)message{
    
    NSLog(@"%@", responseObject);
    NSLog(@"%@", message);
    
    switch ([responseObject[@"status"] intValue]) {
        case STNetworkManagerStatusSuccess:{
            NSDictionary *dictScanResult = responseObject[@"results"];
            NSDictionary *card = dictScanResult[@"card"];
            [self updateStamps:[card[@"currentStamps"] intValue] isFinished:[card[@"finished"] boolValue]];
            break;
        }
            
        case STNetworkManagerUnauthorized:
            [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Failed to scan QR Code!" type:TSMessageNotificationTypeError duration:4.0 canBeDismissedByUser:YES];
            break;
    }
    
    /*NSDictionary *dictScanResult = responseObject[@"results"];
    switch ([dictScanResult[@"scanIsValid"] intValue]) {
        case 0:
            [self updateStamps];
            break;
            
        case 1:
            [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Failed to scan QR Code!" type:TSMessageNotificationTypeError duration:4.0 canBeDismissedByUser:YES];
            break;
    }*/
}

-(void)downloadFailureCode:(int)errCode message:(NSString *)message{
    
    //TODO: delete token??
    
    NSLog(@"error %@", message);
}

@end
