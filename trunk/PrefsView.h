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
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UIPreferencesDeleteTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UINavigationItem.h>
#import <UIKit/UITextField.h>
#import <UIKit/UISegmentedControl.h>
//#import <UIKit/UIWebView.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UINavigationItem.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "ImageView.h"

@interface PrefsView : UIView
{
	UIPreferencesTable *_prefstable;
	UINavigationBar *_navbar;
	UIPreferencesControlTableCell *_scrollcell;
	UIPreferencesTextTableCell *_scrollspeedcell;
	UIPreferencesControlTableCell *_statusbarcell;
	UIPreferencesControlTableCell *_migicell;
	UIPreferencesControlTableCell *_scalecell;
//	UIPreferencesControlTableCell *_slidecell;
	UIPreferencesTextTableCell *_buttonsizecell;
	UIPreferencesControlTableCell *_directioncell;
	UIPreferencesControlTableCell *_errorcell;
	
	UISegmentedControl *_segCtrl;
	UIPreferencesTextTableCell *_segCell;
	
	id _delegate;
}
	
-(id)initWithFrame:(struct CGRect)frame;
- (void) setTrans : (UITransitionView*)tr;
- (void)setDelegate : (id) dele;

@end

