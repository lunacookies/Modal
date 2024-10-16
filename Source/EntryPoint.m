@import AppKit;

const NSNotificationName LibraryURLDidChangeNotificationName = @"org.xoria.Modal.LibraryURLDidChangeNotificationName";

#include "AppDelegate.h"
#include "MainViewController.h"
#include "OnboardingViewController.h"
#include "LibraryViewController.h"

#include "AppDelegate.m"
#include "MainViewController.m"
#include "OnboardingViewController.m"
#include "LibraryViewController.m"

int main(void) {
	[NSApplication sharedApplication];
	AppDelegate *appDelegate = [[AppDelegate alloc] init];
	NSApp.delegate = appDelegate;
	[NSApp run];
}
