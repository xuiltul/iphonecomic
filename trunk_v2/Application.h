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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "Global.h"
#import "FileBrowser.h"
#import "ImageView.h"
#import "PrefsView.h"
#import "ZipFileBrowser.h"
#import "PageBrowser.h"
#import "ButtonBar.h"

/* #define VIEWCOUNT 4 */

@interface ExNavBar : UINavigationBar
{
	id _popDelegate;
}
- (void)setPopDelegate: (id)dele;
@end

@interface Application : UIApplication 
{
	UIWindow			*window;
	UIView*				_mainview;
	ExNavBar*			_navbar;
	FileBrowser*		_browser;
	FileBrowser*		_browser2;
	ZipFileBrowser*		_zbrowser;
	FileBrowser*		_currentBrowser;
	UITransitionView*	_transition;
	UITransitionView*	_tabletransition;
	PrefsView*			_prefsview;
	ImageView*			_imageview;
	PageBrowser*		_pagebrowser;
	UIButtonBar*		_buttonBar;
	UINavigationBar*	_titleBar;
}

-(void) gravity: (float)x  gy:(float) y gz:(float)z;
-(void) viewSelector:(int)ShowViewTmp:(int)TStyle;

@end

