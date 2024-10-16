@implementation AppDelegate {
	NSWindow *window;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];

	NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Main Menu"];

	{
		NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:displayName action:nil keyEquivalent:@""];
		[mainMenu addItem:appMenuItem];

		NSMenu *appMenu = [[NSMenu alloc] initWithTitle:displayName];
		appMenuItem.submenu = appMenu;

		NSString *aboutMenuItemTitle = [NSString stringWithFormat:@"About %@", displayName];
		NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:aboutMenuItemTitle
		                                                       action:@selector(orderFrontStandardAboutPanel:)
		                                                keyEquivalent:@""];
		[appMenu addItem:aboutMenuItem];

		[appMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences…"
		                                                             action:nil
		                                                      keyEquivalent:@","];
		[appMenu addItem:preferencesMenuItem];

		[appMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *servicesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Services" action:nil keyEquivalent:@""];
		[appMenu addItem:servicesMenuItem];

		NSMenu *servicesMenu = [[NSMenu alloc] initWithTitle:@"Services"];
		servicesMenuItem.submenu = servicesMenu;
		NSApp.servicesMenu = servicesMenu;

		[appMenu addItem:[NSMenuItem separatorItem]];

		NSString *hideMenuItemTitle = [NSString stringWithFormat:@"Hide %@", displayName];
		NSMenuItem *hideMenuItem = [[NSMenuItem alloc] initWithTitle:hideMenuItemTitle
		                                                      action:@selector(hide:)
		                                               keyEquivalent:@"h"];
		[appMenu addItem:hideMenuItem];

		NSMenuItem *hideOthersMenuItem = [[NSMenuItem alloc] initWithTitle:@"Hide Others"
		                                                            action:@selector(hideOtherApplications:)
		                                                     keyEquivalent:@"h"];
		hideOthersMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagOption;
		[appMenu addItem:hideOthersMenuItem];

		NSMenuItem *showAllMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show All"
		                                                         action:@selector(unhideAllApplications:)
		                                                  keyEquivalent:@""];
		[appMenu addItem:showAllMenuItem];

		[appMenu addItem:[NSMenuItem separatorItem]];

		NSString *quitMenuItemTitle = [NSString stringWithFormat:@"Quit %@", displayName];
		NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitMenuItemTitle
		                                                      action:@selector(terminate:)
		                                               keyEquivalent:@"q"];
		[appMenu addItem:quitMenuItem];
	}

	{
		NSMenuItem *fileMenuItem = [[NSMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@""];
		[mainMenu addItem:fileMenuItem];

		NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
		fileMenuItem.submenu = fileMenu;

		NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"New"
		                                                     action:@selector(newDocument:)
		                                              keyEquivalent:@"n"];
		[fileMenu addItem:newMenuItem];

		NSMenuItem *openMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open…"
		                                                      action:@selector(openDocument:)
		                                               keyEquivalent:@"o"];
		[fileMenu addItem:openMenuItem];

		NSMenuItem *openRecentMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open Recent" action:nil keyEquivalent:@""];
		[fileMenu addItem:openRecentMenuItem];

		NSMenu *openRecentMenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
		openRecentMenuItem.submenu = openRecentMenu;

		NSMenuItem *clearRecentsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Clear Menu"
		                                                              action:@selector(clearRecentDocuments:)
		                                                       keyEquivalent:@""];
		[openRecentMenu addItem:clearRecentsMenuItem];

		[fileMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *closeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Close"
		                                                       action:@selector(performClose:)
		                                                keyEquivalent:@"w"];
		[fileMenu addItem:closeMenuItem];

		NSMenuItem *saveMenuItem = [[NSMenuItem alloc] initWithTitle:@"Save…"
		                                                      action:@selector(saveDocument:)
		                                               keyEquivalent:@"s"];
		[fileMenu addItem:saveMenuItem];

		NSMenuItem *saveAsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Save As…"
		                                                        action:@selector(saveDocumentAs:)
		                                                 keyEquivalent:@"s"];
		saveAsMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagShift;
		[fileMenu addItem:saveAsMenuItem];

		NSMenuItem *revertToSavedMenuItem = [[NSMenuItem alloc] initWithTitle:@"Revert to Saved"
		                                                               action:@selector(revertDocumentToSaved:)
		                                                        keyEquivalent:@"r"];
		[fileMenu addItem:revertToSavedMenuItem];

		[fileMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *pageSetupMenuItem = [[NSMenuItem alloc] initWithTitle:@"Page Setup…"
		                                                           action:@selector(runPageLayout:)
		                                                    keyEquivalent:@"p"];
		pageSetupMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagShift;
		[fileMenu addItem:pageSetupMenuItem];

		NSMenuItem *printMenuItem = [[NSMenuItem alloc] initWithTitle:@"Print…"
		                                                       action:@selector(print:)
		                                                keyEquivalent:@"p"];
		[fileMenu addItem:printMenuItem];
	}

	{
		NSMenuItem *editMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@""];
		[mainMenu addItem:editMenuItem];

		NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
		editMenuItem.submenu = editMenu;

		NSMenuItem *undoMenuItem = [[NSMenuItem alloc] initWithTitle:@"Undo"
		                                                      action:@selector(undo:)
		                                               keyEquivalent:@"z"];
		[editMenu addItem:undoMenuItem];

		NSMenuItem *redoMenuItem = [[NSMenuItem alloc] initWithTitle:@"Redo"
		                                                      action:@selector(redo:)
		                                               keyEquivalent:@"z"];
		redoMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagShift;
		[editMenu addItem:redoMenuItem];

		[editMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *cutMenuItem = [[NSMenuItem alloc] initWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
		[editMenu addItem:cutMenuItem];

		NSMenuItem *copyMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy"
		                                                      action:@selector(copy:)
		                                               keyEquivalent:@"c"];
		[editMenu addItem:copyMenuItem];

		NSMenuItem *pasteMenuItem = [[NSMenuItem alloc] initWithTitle:@"Paste"
		                                                       action:@selector(paste:)
		                                                keyEquivalent:@"v"];
		[editMenu addItem:pasteMenuItem];

		NSMenuItem *selectAllMenuItem = [[NSMenuItem alloc] initWithTitle:@"Select All"
		                                                           action:@selector(selectAll:)
		                                                    keyEquivalent:@"a"];
		[editMenu addItem:selectAllMenuItem];
	}

	{
		NSMenuItem *viewMenuItem = [[NSMenuItem alloc] initWithTitle:@"View" action:nil keyEquivalent:@""];
		[mainMenu addItem:viewMenuItem];

		NSMenu *viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
		viewMenuItem.submenu = viewMenu;

		NSMenuItem *showToolbarMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show Toolbar"
		                                                             action:@selector(toggleToolbarShown:)
		                                                      keyEquivalent:@"t"];
		showToolbarMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagOption;
		[viewMenu addItem:showToolbarMenuItem];

		NSMenuItem *customizeToolbarMenuItem =
		        [[NSMenuItem alloc] initWithTitle:@"Customize Toolbar…"
		                                   action:@selector(runToolbarCustomizationPalette:)
		                            keyEquivalent:@""];
		[viewMenu addItem:customizeToolbarMenuItem];

		[viewMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *showSidebarMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show Sidebar"
		                                                             action:@selector(toggleSidebar:)
		                                                      keyEquivalent:@"s"];
		showSidebarMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagControl;
		[viewMenu addItem:showSidebarMenuItem];

		NSMenuItem *enterFullScreenMenuItem = [[NSMenuItem alloc] initWithTitle:@"Enter Full Screen"
		                                                                 action:@selector(toggleFullScreen:)
		                                                          keyEquivalent:@"f"];
		enterFullScreenMenuItem.keyEquivalentModifierMask |= NSEventModifierFlagControl;
		[viewMenu addItem:enterFullScreenMenuItem];
	}

	{
		NSMenuItem *windowMenuItem = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
		[mainMenu addItem:windowMenuItem];

		NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
		windowMenuItem.submenu = windowMenu;

		NSMenuItem *minimizeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Minimize"
		                                                          action:@selector(performMiniaturize:)
		                                                   keyEquivalent:@"m"];
		[windowMenu addItem:minimizeMenuItem];

		NSMenuItem *zoomMenuItem = [[NSMenuItem alloc] initWithTitle:@"Zoom"
		                                                      action:@selector(performZoom:)
		                                               keyEquivalent:@""];
		[windowMenu addItem:zoomMenuItem];

		[windowMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *bringAllToFrontMenuItem = [[NSMenuItem alloc] initWithTitle:@"Bring All to Front"
		                                                                 action:@selector(arrangeInFront:)
		                                                          keyEquivalent:@""];
		[windowMenu addItem:bringAllToFrontMenuItem];

		NSApp.windowsMenu = windowMenu;
	}

	NSApp.mainMenu = mainMenu;
	[NSApp activate];

	window = [NSWindow windowWithContentViewController:[[MainViewController alloc] init]];
	[window makeKeyAndOrderFront:nil];
	[NSApp activate];
}

@end
