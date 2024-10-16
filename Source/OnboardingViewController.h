@interface OnboardingViewController : NSViewController
+ (instancetype)controllerWithTarget:(id)target action:(SEL)action;
@property(nonatomic, readonly) NSURL *libraryURL;
@end
