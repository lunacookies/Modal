@interface LibraryAlbumCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier LibraryAlbumCellViewIdentifier = @"org.xoria.Modal.LibraryAlbumCellViewIdentifier";

@interface LibraryAlbumLabelCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier LibraryAlbumLabelCellViewIdentifier =
        @"org.xoria.Modal.LibraryAlbumLabelCellViewIdentifier";

@interface LibraryAlbumsWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@end

const NSUserInterfaceItemIdentifier LibraryAlbumsTitleColumnIdentifier =
        @"org.xoria.Modal.LibraryAlbumsTitleColumnIdentifier";
const NSUserInterfaceItemIdentifier LibraryAlbumsTrackCountColumnIdentifier =
        @"org.xoria.Modal.LibraryAlbumsTrackCountColumnIdentifier";

@implementation LibraryAlbumsWindowController {
	dispatch_queue_t importQueue;
	NSTableView *tableView;
	NSMutableArray<Album *> *albums;
	NSMutableDictionary<NSString *, NSNumber *> *albumIndexes;
	AlbumWindowController *albumWindowController;
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
	importQueue = dispatch_queue_create("org.xoria.Modal.LibraryViewController.ImportQueue", DISPATCH_QUEUE_SERIAL);
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

	NSTableColumn *titleColumn = [[NSTableColumn alloc] initWithIdentifier:LibraryAlbumsTitleColumnIdentifier];
	titleColumn.title = @"Title";
	[tableView addTableColumn:titleColumn];

	NSTableColumn *trackCountColumn =
	        [[NSTableColumn alloc] initWithIdentifier:LibraryAlbumsTrackCountColumnIdentifier];
	trackCountColumn.title = @"Track Count";
	[tableView addTableColumn:trackCountColumn];

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
	if (tableView.clickedRow < 0) {
		return;
	}
	Album *album = albums[(NSUInteger)tableView.clickedRow];
	albumWindowController = [AlbumWindowController controllerWithAlbum:album];
	[albumWindowController showWindow:nil];
}

- (NSView *)tableView:(NSTableView *)_ viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([tableColumn.identifier isEqualToString:LibraryAlbumsTitleColumnIdentifier]) {
		LibraryAlbumCellView *view = [tableView makeViewWithIdentifier:LibraryAlbumCellViewIdentifier owner:nil];
		if (view == nil) {
			view = [[LibraryAlbumCellView alloc] init];
		}
		return view;
	}

	if ([tableColumn.identifier isEqualToString:LibraryAlbumsTrackCountColumnIdentifier]) {
		LibraryAlbumLabelCellView *view = [tableView makeViewWithIdentifier:LibraryAlbumLabelCellViewIdentifier
		                                                              owner:nil];
		if (view == nil) {
			view = [[LibraryAlbumLabelCellView alloc] init];
		}
		return view;
	}

	NSAssert(false, @"unknown column identifier %@", tableColumn.identifier);
	return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)_ {
	return (NSInteger)albums.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	Album *album = albums[(NSUInteger)row];

	if ([tableColumn.identifier isEqualToString:LibraryAlbumsTitleColumnIdentifier]) {
		return album;
	}

	if ([tableColumn.identifier isEqualToString:LibraryAlbumsTrackCountColumnIdentifier]) {
		return [NSNumber numberWithUnsignedInteger:album.tracks.count];
	}

	NSAssert(false, @"unknown column identifier %@", tableColumn.identifier);
	return nil;
}

- (void)libraryURLDidChange:(NSNotification *)notification {
	NSURL *libraryURL = notification.object;

	dispatch_async(importQueue, ^{
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
				if (albumIndex == nil) {
					Album *album = [[Album alloc] init];
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
					Album *album = albums[albumIndex.unsignedIntegerValue];
					[album.tracks addObject:track];
					NSInteger trackCountColumnIndex =
					        [tableView columnWithIdentifier:LibraryAlbumsTrackCountColumnIdentifier];
					NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:albumIndex.unsignedIntegerValue];
					NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndex:(NSUInteger)trackCountColumnIndex];
					[tableView reloadDataForRowIndexes:rowIndexes columnIndexes:columnIndexes];
				}
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

@implementation LibraryAlbumLabelCellView {
	NSTextField *label;
	id objectValue;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = LibraryAlbumLabelCellViewIdentifier;

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
	return objectValue;
}

- (void)setObjectValue:(id)objectValue_ {
	objectValue = objectValue_;

	if ([objectValue isKindOfClass:[NSString class]]) {
		NSString *string = objectValue;
		label.stringValue = string;
		label.font = [NSFont systemFontOfSize:NSFont.systemFontSize weight:NSFontWeightRegular];
		label.alignment = NSTextAlignmentNatural;
		return;
	}

	if ([objectValue isKindOfClass:[NSNumber class]]) {
		NSNumber *number = objectValue;
		label.stringValue = number.stringValue;
		label.font = [NSFont monospacedDigitSystemFontOfSize:NSFont.systemFontSize weight:NSFontWeightRegular];
		label.alignment = NSTextAlignmentRight;
		return;
	}

	NSAssert(false, @"LibraryAlbumLabelCellView objectValue must be NSString or NSNumber");
}

@end
