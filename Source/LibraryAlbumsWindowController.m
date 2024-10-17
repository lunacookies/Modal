@interface LibraryAlbumCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier LibraryAlbumCellViewIdentifier = @"org.xoria.Modal.LibraryAlbumCellViewIdentifier";

@interface LibraryAlbumsWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation LibraryAlbumsWindowController {
	dispatch_queue_t import_queue;
	NSTableView *tableView;
	NSMutableArray<Album *> *albums;
	NSMutableDictionary<NSString *, NSNumber *> *albumIndexes;
}

- (instancetype)init {
	return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 500, 500)
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
	                                                    NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
	                                            backing:NSBackingStoreBuffered
	                                              defer:NO];
	[self.window center];
}

- (void)windowDidLoad {
	import_queue = dispatch_queue_create("org.xoria.Modal.LibraryViewController.ImportQueue", DISPATCH_QUEUE_SERIAL);
	albums = [[NSMutableArray alloc] init];
	albumIndexes = [[NSMutableDictionary alloc] init];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(libraryURLDidChange:)
	                                           name:LibraryURLDidChangeNotificationName
	                                         object:nil];

	tableView = [[NSTableView alloc] init];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.target = self;
	tableView.doubleAction = @selector(didDoubleClickOnRow:);

	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
	[tableView addTableColumn:column];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = tableView;
	scrollView.hasVerticalScroller = YES;

	NSView *contentView = self.window.contentView;
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:scrollView];
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
		[scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
	]];
}

- (void)didDoubleClickOnRow:(NSTableView *)_ {
	Album *album = albums[(NSUInteger)tableView.clickedRow];
	[[AlbumWindowController controllerWithAlbum:album] showWindow:nil];
}

- (NSView *)tableView:(NSTableView *)_ viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	LibraryAlbumCellView *view = [tableView makeViewWithIdentifier:LibraryAlbumCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[LibraryAlbumCellView alloc] init];
	}
	return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)_ {
	return (NSInteger)albums.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return albums[(NSUInteger)row];
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

			if (![type conformsToType:UTTypeAudio]) {
				continue;
			}

			Track *track = [[Track alloc] init];
			track.url = url;

			AVAsset *asset = [AVAsset assetWithURL:url];

			track.title = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                filteredByIdentifier:AVMetadataCommonIdentifierTitle]
			                      .firstObject.stringValue;

			track.albumTitle = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                     filteredByIdentifier:AVMetadataCommonIdentifierAlbumName]
			                           .firstObject.stringValue;

			track.artworkData = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                      filteredByIdentifier:AVMetadataCommonIdentifierArtwork]
			                            .firstObject.dataValue;

			if (track.title == nil || track.albumTitle == nil || track.artworkData == nil) {
				continue;
			}

			dispatch_sync(dispatch_get_main_queue(), ^{
				NSNumber *albumIndex = albumIndexes[track.albumTitle];
				Album *album = nil;
				if (albumIndex == nil) {
					album = [[Album alloc] init];
					album.title = track.albumTitle;
					album.tracks = [[NSMutableArray alloc] init];
					[album.tracks addObject:track];

					albumIndex = [NSNumber numberWithUnsignedInteger:albums.count];
					[albums addObject:album];
					[albumIndexes setObject:albumIndex forKey:album.title];
					NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:albumIndex.unsignedIntegerValue];
					[tableView insertRowsAtIndexes:indexSet
					                 withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideDown];
				} else {
					album = albums[albumIndex.unsignedIntegerValue];
				}
				[album.tracks addObject:track];
			});
		}
	});
}

@end

@implementation LibraryAlbumCellView {
	Album *album;
	NSImageView *imageView;
	NSTextField *label;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = LibraryAlbumCellViewIdentifier;

	imageView = [[NSImageView alloc] init];
	imageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:imageView];

	label = [NSTextField labelWithString:@""];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:label];

	[label setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
	[NSLayoutConstraint activateConstraints:@[
		[imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
		[label.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor],

		[imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		[label.leadingAnchor constraintEqualToAnchor:imageView.trailingAnchor constant:8],
		[label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

		[imageView.widthAnchor constraintEqualToAnchor:imageView.heightAnchor],
		[imageView.heightAnchor constraintEqualToAnchor:label.heightAnchor],
	]];

	return self;
}

- (id)objectValue {
	return album;
}

- (void)setObjectValue:(id)objectValue {
	NSAssert([objectValue isKindOfClass:[Album class]], @"LibraryAlbumCellView objectValue must be Album");
	album = objectValue;
	label.stringValue = album.title;
	imageView.image = [[NSImage alloc] initWithData:album.artworkData];
}

@end
