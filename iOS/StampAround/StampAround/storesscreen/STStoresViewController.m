//
//  STStoresViewController.m
//  StampAround
//
//  Created by Thibault on 09/08/14.
//  Copyright (c) 2014 StampAround. All rights reserved.
//

#import "STStoresViewController.h"

@interface STStoresViewController ()

@end

@implementation STStoresViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:MY_UICOLOR_FROM_HEX_RGB(0xf4f6f0)];
    
    // back gesture
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBackGesture:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:swipeGestureRecognizer];
    [swipeGestureRecognizer setDelegate:self];
    
    [[STNetworkManager managerWithDelegate:self] requestStoresByCategory:_categoryId];
    
    //[self.collectionView registerClass:[STStoreCell class] forCellWithReuseIdentifier:@"STStoreCell"];
    UINib *cellNib = [UINib nibWithNibName:@"STStoreCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"STStoreCell"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView setBackgroundColor:MY_UICOLOR_FROM_HEX_RGB(0xf4f6f0)];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Actions

-(void)swipeBackGesture:(UIGestureRecognizer*)gesture{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ST Bottom bar delegate

- (void)mapClicked
{
    
}

- (void)stampClicked
{
    
}

- (void)myCardsClicked
{
    
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STStoreCell *storeCell = [cv dequeueReusableCellWithReuseIdentifier:@"STStoreCell" forIndexPath:indexPath];
    if(!storeCell){
        storeCell = [[STStoreCell alloc] init];
    }
    
    return storeCell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Deselect item
}


#pragma mark - Network Delegate


-(void)downloadResponse:(id)responseObject message:(NSString *)message{
    
    NSLog(@"%@", responseObject);
    NSLog(@"%@", message);
    
}

-(void)downloadFailureCode:(int)errCode message:(NSString *)message{
    
    NSLog(@"error %@", message);
    
    [TSMessage showNotificationInViewController:self title:@"Error" subtitle:message type:TSMessageNotificationTypeError duration:4.0 canBeDismissedByUser:YES];
    
}

@end
