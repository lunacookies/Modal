@implementation MainViewController {
	OnboardingViewController *onboardingViewController;
	LibraryViewController *libraryViewController;
}

- (instancetype)init {
	self = [super init];
	self.title = @"Modal";
	onboardingViewController = [OnboardingViewController controllerWithTarget:self
	                                                                   action:@selector(didChooseLibraryFolder)];
	[self addChildViewController:onboardingViewController];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:onboardingViewController.view];
}

- (void)didChooseLibraryFolder {
	NSLog(@"%@", onboardingViewController.libraryURL);
	libraryViewController = [[LibraryViewController alloc] init];
	[self addChildViewController:libraryViewController];
	[self transitionFromViewController:onboardingViewController
	                  toViewController:libraryViewController
	                           options:NSViewControllerTransitionSlideUp
	                 completionHandler:^{
		                 [onboardingViewController removeFromParentViewController];
		                 onboardingViewController = nil;
	                 }];
}

@end
