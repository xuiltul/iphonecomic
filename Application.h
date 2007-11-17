#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UINavigationItem.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "FileBrowser.h"
#import "ImageView.h"
#import "PrefsView.h"

#define VIEWCOUNT 4

@interface ExNavBar : UINavigationBar
{
	id _popDelegate;
}
- (void)setPopDelegate: (id)dele;
@end

@interface Application : UIApplication 
{
	UIView* _mainview;
	ExNavBar* _navbar;
	FileBrowser* _browser;
	FileBrowser* _browser2;
	FileBrowser* _currentBrowser;
	UITransitionView* _transition;
	UITransitionView* _tabletransition;
	PrefsView *_prefsview;
	
	ImageView* _imageview;
	NSString* _filename;
}
@end

