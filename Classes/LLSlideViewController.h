//
//  LLSlideViewController.h
//  ChunyuClinic
//
//  Created by ll on 16/2/27.
//  Copyright © 2016年 ll. All rights reserved.
//

@import UIKit;

/**
 * to avoid crash due to UIPageViewController, e.g.
 * Invalid Parameters count==3
 * Assertion failure and Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'No view controller managing visible view
 * When you meet unexpected behavior, pls try to leave message on github, or check the logic of implementation
 * For now, only supporting horizontal swipe.
 */
@protocol LLSlideViewControllerDelegate;
@protocol LLSlideViewControllerDatasource;

typedef enum :NSInteger {
    LLSlideViewControllerDirectionNone,
    LLSlideViewControllerDirectionReverse,
    LLSlideViewControllerDirectionForward,
}LLSlideViewControllerDirection;

@interface LLSlideViewController : UIViewController

@property (nonatomic, weak) id<LLSlideViewControllerDelegate> delegate;
@property (nonatomic, weak) id<LLSlideViewControllerDatasource> dataSource;

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
/**
 * @return if the scrollView is scrolling or user is dragging
 */
@property (nonatomic, readonly,getter=isAnimating) BOOL animating;

/**
 * call this method to show viewController
 */
- (void)setViewController:(UIViewController *)viewController direction:(LLSlideViewControllerDirection)direction animated:(BOOL)animated completion:(void(^)())completion;

@end


@protocol LLSlideViewControllerDelegate <NSObject>

@optional
/**
 * Only happened when user gesture driven. When the destination view controller has been decided, this method will be called.
 */
- (void)slideViewController:(LLSlideViewController *)slideViewController willTransitionToViewController:(UIViewController *)viewController;
/**
 * Only happened when user gesture driven.
 * @param finished: if scroll animation is finished.
 * @param completed: if user has scrolled page.
 */
- (void)slideViewController:(LLSlideViewController *)slideViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed;

@end

/**
 * if datasource is not implemented, then user can't use swipe gesture.
 */
@protocol LLSlideViewControllerDatasource <NSObject>
- (UIViewController *)slideViewController:(LLSlideViewController *)slideViewController viewControllerBeforeViewController:(UIViewController *)viewController;

- (UIViewController *)slideViewController:(LLSlideViewController *)slideViewController viewControllerAfterViewController:(UIViewController *)viewController;
@end
