#import <GraphicsServices/GraphicsServices.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIKeyboardInput.h>
#import <UIKit/UISegmentedControl.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ScrollImage : UIScroller
{
	float _fDistancePrev;
	float _fDistanceStart;
	bool _bZooming;
	UIImageView* _imageview;
	UIImage *_currentimage;
	float _fCurrentPercent;
	CGSize _imagesize;
	id _mdelegate;
	CGPoint _centerpoint;
	bool _isVertical;
	CGAffineTransform _matrixprev;
	bool _isvert;
	int _orient;
	UIImage* _ileft, *_iright, *_ihome;
	BOOL _maeFlag;
}

- (void) fitRect;
- (int) setImage : (NSData*) data;
- (void) setImageFromImage : (UIImage *)image withFlag: (BOOL) flag;
- (void) setPercent : (float)percent;
- (float) getPercent;
- (void) resizeImage;
- (void) setMouseDelegate: (id) del;
- (void) scrollToTopRight;
- (void) setRotate : (bool) isvertical;
-(void) setOrientation: (int) orientation animate:(bool)anime;
@end


