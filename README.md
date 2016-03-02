# LLSlideViewController
UIPageViewController alternative to prevent crash

####When using UIPageViewController, if it responds to your drag and some notification posted at the same time, you highly likely meet these crash logs:
######*1.Invalid Parameters count==3*
######*2.Assertion failure and Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'No view controller managing visible view.*

This LLSlideViewController solve these problems for you. Similar usage as UIPageViewController,
For example:

<pre><code>[self.slideViewController setViewController:[self viewControllerAtIndex:0]
                                    direction:LLSlideViewControllerDirectionForward
                                     animated:YES
                                   completion:^{
                                       NSLog(@"completed");
                                   }];</code></pre>
<br>

####Notice:
######1.If you don't implement datasoure property of LLSlideViewController, it won't support drag gesture.
######2.If you call setViewController:direction:animated:completion in the completion block, you have to use async methods on main queue. 

