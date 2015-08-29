//
// Created by zzdjk6 on 15/8/29.
// Copyright (c) 2015 zzdjk6. All rights reserved.
//

#import "MCDSignupContainerViewController.h"
#import "MCDSignupContentViewController.h"

@interface MCDSignupContainerViewController ()

@property(nonatomic, strong) MCDSignupContentViewController *contentViewController;
@property(nonatomic, assign) CGRect                         contentViewFrame;

@property(nonatomic, weak) IBOutlet UIScrollView       *scrollView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation MCDSignupContainerViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerKeyBoardObserver];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self loadContentViewController];
    self.contentViewController.view.frame = self.contentViewFrame;
    [self.contentViewController.view layoutIfNeeded];

}

#pragma mark - private

- (void)loadContentViewController
{
    if (self.contentViewController != nil)
        return;

    NSString *contentViewControllerID = NSStringFromClass([MCDSignupContentViewController class]);
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:contentViewControllerID];

    self.contentViewFrame                 = self.scrollView.bounds;
    self.contentViewController.view.frame = self.contentViewFrame;

    // UIScrollView 只在 ContentSize 比自己大的时候才滚动
    CGSize contentSize = self.contentViewFrame.size;
    contentSize.height++;
    self.scrollView.contentSize = contentSize;

    [self addChildViewController:self.contentViewController];
    [self.scrollView addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)registerKeyBoardObserver
{
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification
                                                           object:nil]
        subscribeNext:^(NSNotification *notification) {
            NSDictionary *info  = [notification userInfo];
            CGSize       kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
            self.scrollView.contentInset          = contentInsets;
            self.scrollView.scrollIndicatorInsets = contentInsets;

            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            CGRect aRect = self.view.frame;
            aRect.size.height -= kbSize.height;
            if (!CGRectContainsPoint(aRect, self.contentViewController.activeField.frame.origin)) {
                [self.scrollView scrollRectToVisible:self.contentViewController.activeField.frame animated:YES];
            }
        }];

    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification
                                                           object:nil]
        subscribeNext:^(id x) {
            UIEdgeInsets contentInsets = UIEdgeInsetsZero;
            self.scrollView.contentInset          = contentInsets;
            self.scrollView.scrollIndicatorInsets = contentInsets;
        }];
}

@end