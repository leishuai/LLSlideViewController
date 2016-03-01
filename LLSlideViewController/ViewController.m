//
//  ViewController.m
//  LLSlideViewController
//
//  Created by leishuai on 16/3/1.
//  Copyright © 2016年 ll. All rights reserved.
//

#import "ViewController.h"
#import "LLSlideViewController.h"

@interface ViewController () <LLSlideViewControllerDatasource, LLSlideViewControllerDelegate>
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) LLSlideViewController *slideViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.currentIndex = 0;
    
    self.slideViewController = [[LLSlideViewController alloc] initWithNibName:nil bundle:nil];
    self.slideViewController.view.frame = CGRectMake(0, 50, self.view.bounds.size.width, 300);
    [self.view addSubview:self.slideViewController.view];
    
    self.slideViewController.dataSource = self;  //activate gesture driven
    self.slideViewController.delegate = self;

    [self.slideViewController setViewController:[self viewControllerAtIndex:0]
                                 direction:LLSlideViewControllerDirectionForward
                                  animated:YES
                                completion:^{
                                    NSLog(@"ViewController:%zi displayed",0);
                                }];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc.view.frame = CGRectMake(0, 50, self.view.bounds.size.width, 100);
    vc.view.backgroundColor = [UIColor cyanColor];
    vc.view.tag = index;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @(index).stringValue;
    label.font = [UIFont boldSystemFontOfSize:60];
    [vc.view addSubview:label];
    return vc;
}


#pragma mark - LLSlideViewControllerDatasource

- (UIViewController *)slideViewController:(LLSlideViewController *)slideViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index= viewController.view.tag - 1;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)slideViewController:(LLSlideViewController *)slideViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index= viewController.view.tag + 1;
    return [self viewControllerAtIndex:index];
}

#pragma mark - LLSlideViewControllerDelegate

- (void)slideViewController:(LLSlideViewController *)slideViewController willTransitionToViewController:(UIViewController *)viewController {
    
}

- (void)slideViewController:(LLSlideViewController *)slideViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed {
    
    if (completed) {
        self.currentIndex = slideViewController.currentViewController.view.tag;
        NSLog(@"ViewController:%zi displayed",self.currentIndex);
    }
}

@end
