@import AVFoundation;
@import AppKit;
@import UniformTypeIdentifiers;

const NSNotificationName LibraryURLDidChangeNotificationName = @"org.xoria.Modal.LibraryURLDidChangeNotificationName";

#include "AppDelegate.h"
#include "OnboardingWindowController.h"
#include "LibraryAlbumsWindowController.h"

#include "AppDelegate.m"
#include "OnboardingWindowController.m"
#include "LibraryAlbumsWindowController.m"

int main(void) {
	[NSApplication sharedApplication];
	AppDelegate *appDelegate = [[AppDelegate alloc] init];
	NSApp.delegate = appDelegate;
	[NSApp run];
}
