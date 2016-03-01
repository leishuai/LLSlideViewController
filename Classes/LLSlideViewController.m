//
//  CYSlideViewController.m
//  ChunyuClinic
//
//  Created by leishuai on 16/2/27.
//  Copyright © 2016年 lvjianxiong. All rights reserved.
//

#import "LLSlideViewController.h"
#import "UIView+LLShortcuts.h"

/**
 * The basic idea is use three views to compose subviews of scroll view.
 * After scroll view is scrolled, set contentOffset and subviews of scroll view to correct state.
 */

@interface LLSlideViewController () <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIScrollView *scrollView;      //contentSize.width is scrollView.width * 3
@property (nonatomic, strong) NSArray *viewsInScrollView;    //of UIView, three subviews
@property (nonatomic, strong) NSMutableArray *cachedViewControllers;  //three view controllers
@property (nonatomic, strong) UIViewController *viewControllerToBeDisappeared;
@property (nonatomic, copy) void(^cachedCompletion)();

@property (nonatomic) BOOL isCachedViewControllersValid;
@property (nonatomic, readwrite, getter=isAnimating) BOOL animating;
@property (nonatomic, getter=isManualScrolling) BOOL manualScrolling;
@property (nonatomic) CGPoint scrollViewTargetOffset;

@end

@implementation LLSlideViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _animating = NO;
        _isCachedViewControllersValid = NO;
        _cachedViewControllers = [NSMutableArray arrayWithObjects:[NSNull null],[NSNull null],[NSNull null],nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initScrollView];
    
}

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = true;
    self.scrollView.scrollEnabled = true;
    self.scrollView.bounces = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:3];
    for (NSUInteger i=0; i<3; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        view.backgroundColor = [UIColor clearColor];
        
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:view];
        
        [mArray addObject:view];
    }
    self.viewsInScrollView = [mArray copy];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (UIView *)subviewOfScrollViewAtIndex:(NSUInteger)index {
    return [self.viewsInScrollView objectAtIndex:index];
}

- (void)addCachedViewController:(UIViewController *)vc toIndex:(NSUInteger)index {
    [self.cachedViewControllers replaceObjectAtIndex:index withObject:vc];
}

- (void)removeCachedViewControllerAtIndex:(NSUInteger)index {
    UIViewController *vc = self.cachedViewControllers[index];
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self.cachedViewControllers replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)addSubview:(UIView *)subview toViewInSrollViewAtIndex:(NSUInteger)index {
    UIView *viewInScrollView = [self subviewOfScrollViewAtIndex:index];
    [viewInScrollView removeSubviews];
    [viewInScrollView addSubview:subview];
}

- (void)updateViewAfterAddingViewToIndex:(NSUInteger)index {
    switch (index) {
        case 0: {
            //clear 3rd view & vc
            UIView *lastViewInScrollView = [self subviewOfScrollViewAtIndex:2];
            [lastViewInScrollView removeSubviews];
            [self removeCachedViewControllerAtIndex:2];
            
            //move 2nd view to 3rd
            UIView *midViewInScrollView = [self subviewOfScrollViewAtIndex:1];
            [lastViewInScrollView addSubview:midViewInScrollView.subviews.firstObject];
            
            //move 1st view to 2nd
            UIView *firstViewInScrollView = [self subviewOfScrollViewAtIndex:0];
            [midViewInScrollView addSubview:firstViewInScrollView.subviews.firstObject];  //now first view has no subviews
            
            //justify cachedViewControllers
            [self.cachedViewControllers exchangeObjectAtIndex:2 withObjectAtIndex:1];
            [self.cachedViewControllers exchangeObjectAtIndex:1 withObjectAtIndex:0]; //now the 1st cached vc is NSNull
            
            //set contentOffset to display center(2nd) view
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0)];
            
        }
            break;
        
        case 1: {
            
        }
            break;
            
        case 2: {
            //clear 1st view & vc
            UIView *firstViewInScrollView = [self subviewOfScrollViewAtIndex:0];
            [firstViewInScrollView removeSubviews];
            [self removeCachedViewControllerAtIndex:0];
            
            //move 2nd view to 1st
            UIView *midViewInScrollView = [self subviewOfScrollViewAtIndex:1];
            [firstViewInScrollView addSubview:midViewInScrollView.subviews.firstObject];
            
            //move 3rd view to 2nd
            UIView *lastViewInScrollView = [self subviewOfScrollViewAtIndex:2];
            [midViewInScrollView addSubview:lastViewInScrollView.subviews.firstObject];  //now last view has no subviews
            
            //justify cachedViewControllers
            [self.cachedViewControllers exchangeObjectAtIndex:1 withObjectAtIndex:0];
            [self.cachedViewControllers exchangeObjectAtIndex:2 withObjectAtIndex:1]; //now the 3rd cached vc is NSNull
            
            //set contentOffset to display center(2nd) view
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0)];
            
        }
            break;
    }
    
    //for view controller's life cycle
    if ([self.viewControllerToBeDisappeared isKindOfClass:[UIViewController class]]) {
        [self.viewControllerToBeDisappeared didMoveToParentViewController:nil];
        self.viewControllerToBeDisappeared = nil;
        [self.cachedViewControllers[1] didMoveToParentViewController:self];
    } else {
        /*
         //raise exception
         [NSException raise:@"view controller to be transitioned to is NSNull"
         format:@"%@",vcToBeTransitedTo];
         */
    }
    
}

- (void)installNewViewControllerForUserScrollingAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: {
            UIViewController *vcBefore = [self.dataSource slideViewController:self viewControllerBeforeViewController:self.cachedViewControllers[1]];
            if (vcBefore) {
                [self addCachedViewController:vcBefore toIndex:0];
                vcBefore.view.frame = self.view.bounds;
                [self addSubview:vcBefore.view toViewInSrollViewAtIndex:0];
                UIEdgeInsets contentInset = self.scrollView.contentInset;
                contentInset.left = 0;
                self.scrollView.contentInset = contentInset;
            } else {        //user can't scroll to right anymore
                [self.viewsInScrollView[0] removeSubviews];
                UIEdgeInsets contentInset = self.scrollView.contentInset;
                contentInset.left = - self.scrollView.bounds.size.width;
                self.scrollView.contentInset = contentInset;
            }
        }
            break;
            
        case 2: {
            UIViewController *vcAfter = [self.dataSource slideViewController:self viewControllerAfterViewController:self.cachedViewControllers[1]];
            if (vcAfter) {
                [self addCachedViewController:vcAfter toIndex:2];
                vcAfter.view.frame = self.view.bounds;
                [self addSubview:vcAfter.view toViewInSrollViewAtIndex:2];
                UIEdgeInsets contentInset = self.scrollView.contentInset;
                contentInset.right = 0;
                self.scrollView.contentInset = contentInset;
            } else {
                [self.viewsInScrollView[2] removeSubviews];
                UIEdgeInsets contentInset = self.scrollView.contentInset;
                contentInset.right = - self.scrollView.bounds.size.width;
                self.scrollView.contentInset = contentInset;
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (void)tidyViewsAfterUserDraggingScrollView:(UIScrollView *)scrollView {
    BOOL userCanceledTransition = NO;
    UIViewController *previousViewController;
    if (self.scrollViewTargetOffset.x == scrollView.bounds.size.width) {
        //user has cancelled scrolling
        userCanceledTransition = YES;
        previousViewController = self.cachedViewControllers[1];
        
    } else if (self.scrollViewTargetOffset.x <= 0) {   //scrolled to right
        [self updateViewAfterAddingViewToIndex:0];
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self installNewViewControllerForUserScrollingAtIndex:0];
        previousViewController = self.cachedViewControllers[2];
        
    } else if (self.scrollViewTargetOffset.x >= scrollView.bounds.size.width * 2) { //scrolled to left
        [self updateViewAfterAddingViewToIndex:2];
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self installNewViewControllerForUserScrollingAtIndex:2];
        previousViewController = self.cachedViewControllers[0];
    }
    //callback
    if ([self.delegate respondsToSelector:@selector(slideViewController:didFinishAnimating:previousViewController:transitionCompleted:)]) {
        [self.delegate slideViewController:self
                        didFinishAnimating:NO
                    previousViewController:previousViewController
                       transitionCompleted:!userCanceledTransition];
    }
}

- (void)invalidateCachedViewControllers {
    self.isCachedViewControllersValid = NO;
    [self removeCachedViewControllerAtIndex:0];
    [self removeCachedViewControllerAtIndex:2];
}

- (void)runCachedCompletion {
    if (self.cachedCompletion) {
        self.cachedCompletion();
        self.cachedCompletion = nil;
    }
}


#pragma mark - public
- (void)setViewController:(UIViewController *)viewController direction:(LLSlideViewControllerDirection)direction animated:(BOOL)animated completion:(void (^)())completion {
    
    //reset scroll view properties
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled = self.dataSource ? YES : NO;
    
    
    [self invalidateCachedViewControllers];
    self.currentViewController = viewController;
    
    UIView *view = viewController.view;
    [viewController willMoveToParentViewController:self];
    view.frame = self.view.bounds;
    
    self.cachedCompletion = completion;
    
    //the view controller displayed in the middle view is about to disappear
    UIViewController *midVc = self.cachedViewControllers[1];
    if ([midVc isKindOfClass:[UIViewController class]]) {
        [midVc willMoveToParentViewController:nil];
        self.viewControllerToBeDisappeared = midVc;
    }
    
    switch (direction) {
        case LLSlideViewControllerDirectionNone: {

            [self addCachedViewController:viewController toIndex:1];
            [self addSubview:view toViewInSrollViewAtIndex:1];
            
            if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
                [self updateViewAfterAddingViewToIndex:1];
                [self runCachedCompletion];
                
            } else {
                if (animated) {
                    self.animating = YES;
                    self.scrollViewTargetOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
                    [self.scrollView setContentOffset:self.scrollViewTargetOffset animated:YES];
                } else {
                    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0) animated:NO];
                    [self updateViewAfterAddingViewToIndex:1];
                    [self runCachedCompletion];
                }
            }
        }   
            break;
            
        case LLSlideViewControllerDirectionForward: {
            
            [self addCachedViewController:viewController toIndex:2];
            [self addSubview:view toViewInSrollViewAtIndex:2];
            
            if (animated) {
                self.animating = YES;
                self.scrollViewTargetOffset = CGPointMake(self.scrollView.bounds.size.width *2, 0);
                [self.scrollView setContentOffset:self.scrollViewTargetOffset animated:YES];
            } else {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width *2, 0) animated:NO];
                [self updateViewAfterAddingViewToIndex:2];
                [self runCachedCompletion];
            }
        }
            break;
            
        case LLSlideViewControllerDirectionReverse: {
            [self addCachedViewController:viewController toIndex:0];
            [self addSubview:view toViewInSrollViewAtIndex:0];
            
            if (animated) {
                self.animating = YES;
                self.scrollViewTargetOffset = CGPointZero;
                [self.scrollView setContentOffset:CGPointZero animated:YES];
            } else {
                [self.scrollView setContentOffset:CGPointZero animated:NO];
                [self updateViewAfterAddingViewToIndex:0];
                [self runCachedCompletion];
            }
        }
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //when user scroll beyond subviews bounds
    if (scrollView.contentOffset.x > self.scrollView.bounds.size.width * 2 && self.manualScrolling) {
        [self updateViewAfterAddingViewToIndex:2];
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self installNewViewControllerForUserScrollingAtIndex:2];
        if ([self.delegate respondsToSelector:@selector(slideViewController:didFinishAnimating:previousViewController:transitionCompleted:)]) {
            [self.delegate slideViewController:self
                            didFinishAnimating:YES
                        previousViewController:self.cachedViewControllers[1]
                           transitionCompleted:YES];
        }
    } else if (scrollView.contentOffset.x < 0 && self.manualScrolling) {
        [self updateViewAfterAddingViewToIndex:0];
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self installNewViewControllerForUserScrollingAtIndex:0];
        if ([self.delegate respondsToSelector:@selector(slideViewController:didFinishAnimating:previousViewController:transitionCompleted:)]) {
            [self.delegate slideViewController:self
                            didFinishAnimating:YES
                        previousViewController:self.cachedViewControllers[1]
                           transitionCompleted:YES];
        }
    }
}

//user gesture driven
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.manualScrolling = YES;
    self.animating = YES;
    
    //user begins to drag view when scroll view is still scrolling
    if (scrollView.isDecelerating) {
        
        [self tidyViewsAfterUserDraggingScrollView:scrollView];
    }
    
    //if cachedViewControllers is not valid, then ask for datasource to get the view controller before and after the current view controller which is in the middle.
    if (!self.isCachedViewControllersValid) {
        if ([self.dataSource respondsToSelector:@selector(slideViewController:viewControllerBeforeViewController:)]) {
            
            [self installNewViewControllerForUserScrollingAtIndex:0];
        }
        
        if ([self.dataSource respondsToSelector:@selector(slideViewController:viewControllerAfterViewController:)]) {
            [self installNewViewControllerForUserScrollingAtIndex:2];
        }
        //set cached view controllers valid
        self.isCachedViewControllersValid = YES;
    }
}

//user gesture driven
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    self.scrollViewTargetOffset = *targetContentOffset;
    
    if ((*targetContentOffset).x != scrollView.bounds.size.width) {  //scrolled to right or left
        UIViewController *vcToBeTransitedTo;
        if ((*targetContentOffset).x == 0) { //scrolled to right
            vcToBeTransitedTo = self.cachedViewControllers[0];
        } else { //scrolled to left
            vcToBeTransitedTo = self.cachedViewControllers[2];
        }
        if ([vcToBeTransitedTo isKindOfClass:[UIViewController class]]) {
            self.currentViewController = vcToBeTransitedTo;
            [vcToBeTransitedTo willMoveToParentViewController:self];
            if ([self.delegate respondsToSelector:@selector(slideViewController:willTransitionToViewController:)]) {
                [self.delegate slideViewController:self willTransitionToViewController:vcToBeTransitedTo];
            }
        } else {
            /*
            //raise exception
            [NSException raise:@"view controller to be transitioned to is NSNull"
                        format:@"%@",vcToBeTransitedTo];
             */
        }
        
        UIViewController *midVc = self.cachedViewControllers[1];
        if ([midVc isKindOfClass:[UIViewController class]]) {
            [midVc willMoveToParentViewController:nil];
            self.viewControllerToBeDisappeared = midVc;
        }
    }
}

//user gesture driven
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self tidyViewsAfterUserDraggingScrollView:scrollView];
    self.manualScrolling = NO;
    self.animating = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    if (self.scrollViewTargetOffset.x == scrollView.bounds.size.width) {
        [self updateViewAfterAddingViewToIndex:1];
    } else if (self.scrollViewTargetOffset.x == 0) {   //scrolled to right
        [self updateViewAfterAddingViewToIndex:0];
    } else if (self.scrollViewTargetOffset.x == scrollView.bounds.size.width * 2) { //scrolled to left
        [self updateViewAfterAddingViewToIndex:2];
    }
    
    self.animating = NO;
    [self runCachedCompletion];
}

@end
