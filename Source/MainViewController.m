@implementation MainViewController {
	OnboardingViewController *onboardingViewController;
	LibraryViewController *libraryViewController;
}

- (instancetype)init {
	self = [super init];
	self.title = @"Modal";

	onboardingViewController = [OnboardingViewController controllerWithTarget:self
	                                                                   action:@selector(completedOnboarding)];
	[self addChildViewController:onboardingViewController];

	libraryViewController = [[LibraryViewController alloc] init];
	[self addChildViewController:libraryViewController];

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:onboardingViewController.view];
}

- (void)completedOnboarding {
	[self transitionFromViewController:onboardingViewController
	                  toViewController:libraryViewController
	                           options:NSViewControllerTransitionSlideUp
	                 completionHandler:^{
		                 [onboardingViewController removeFromParentViewController];
		                 onboardingViewController = nil;
	                 }];
}

@end
