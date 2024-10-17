@import AVFoundation;
@import AppKit;
@import UniformTypeIdentifiers;

const NSNotificationName LibraryURLDidChangeNotificationName = @"org.xoria.Modal.LibraryURLDidChangeNotificationName";

#include "AppDelegate.h"
#include "Model.h"
#include "OnboardingWindowController.h"
#include "LibraryAlbumsWindowController.h"
#include "AlbumWindowController.h"

#include "AppDelegate.m"
#include "Model.m"
#include "OnboardingWindowController.m"
#include "LibraryAlbumsWindowController.m"
#include "AlbumWindowController.m"

int main(void) {
	[NSApplication sharedApplication];
	AppDelegate *appDelegate = [[AppDelegate alloc] init];
	NSApp.delegate = appDelegate;
	[NSApp run];
}
