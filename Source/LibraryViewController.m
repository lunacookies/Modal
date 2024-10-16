@interface LibraryCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier LibraryCellViewIdentifier = @"org.xoria.Modal.LibraryCellViewIdentifier";

@interface LibraryViewController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation LibraryViewController {
	dispatch_queue_t import_queue;
	NSTableView *tableView;
	NSMutableArray<NSString *> *rows;
}

- (instancetype)init {
	self = [super init];

	import_queue = dispatch_queue_create("org.xoria.Modal.LibraryViewController.ImportQueue", DISPATCH_QUEUE_SERIAL);
	rows = [[NSMutableArray alloc] init];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(libraryURLDidChange:)
	                                           name:LibraryURLDidChangeNotificationName
	                                         object:nil];

	return self;
}

- (void)viewDidLoad {
	tableView = [[NSTableView alloc] init];
	tableView.dataSource = self;
	tableView.delegate = self;

	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
	[tableView addTableColumn:column];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = tableView;
	scrollView.hasVerticalScroller = YES;

	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:scrollView];
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
	]];
}

- (NSView *)tableView:(NSTableView *)_ viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	LibraryCellView *view = [tableView makeViewWithIdentifier:LibraryCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[LibraryCellView alloc] init];
	}
	return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)_ {
	return (NSInteger)rows.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return rows[(NSUInteger)row];
}

- (void)libraryURLDidChange:(NSNotification *)notification {
	NSURL *libraryURL = notification.object;

	dispatch_async(import_queue, ^{
		NSDirectoryEnumerator<NSURL *> *enumerator =
		        [NSFileManager.defaultManager enumeratorAtURL:libraryURL
		                           includingPropertiesForKeys:@[ NSURLContentTypeKey ]
		                                              options:0
		                                         errorHandler:nil];

		for (NSURL *url in enumerator) {
			UTType *type = nil;
			BOOL ok = [url getResourceValue:&type forKey:NSURLContentTypeKey error:nil];
			if (!ok) {
				continue;
			}

			if ([type conformsToType:UTTypeAudio]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[rows addObject:url.path];
					NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:rows.count - 1];
					[tableView insertRowsAtIndexes:indexSet
					                 withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideDown];
				});
			}
		}
	});
}

@end

@implementation LibraryCellView {
	NSTextField *label;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = LibraryCellViewIdentifier;

	label = [NSTextField labelWithString:@""];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:label];
	[NSLayoutConstraint activateConstraints:@[
		[label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
		[label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		[label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
	]];

	return self;
}

- (id)objectValue {
	return label.objectValue;
}

- (void)setObjectValue:(id)objectValue {
	label.objectValue = objectValue;
}

@end
