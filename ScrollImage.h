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
	float			_fDistancePrev;			//前回の2本指の距離
	bool			_bZooming;				//ズームモード
	float			_imagezoom;				//ズーム倍率
	UIImage*		_currentimage;			//イメージオブジェクト
	CGSize			_imagesize;				//イメージサイズ
	CGSize			_oimagesize;			//イメージサイズ
	UIImageView*	_imageview;				//表示用イメージオブジェクト
	id				_mdelegate;
	CGPoint			_centerpoint;			//中心座標
	bool			_isVertical;
	CGAffineTransform	_matrixprev;
	bool			_isvert;				//縦か横か
	int				_orient;				//回転角度
	UIImage*		_ileft, *_iright, *_ihome;
	BOOL			_maeFlag;
	
	CGPoint			_cgpDown;
	CGPoint			_cgpUp;
}

- (void) fitRect;
- (int) setImage : (NSData*) data;
- (void) setImageFromImage : (UIImage *)image withFlag: (BOOL) flag;
- (void) setPercent : (float)percent;
- (float) getPercent;
- (void) resizeImage;
- (void) setScrollDelegate: (id) del;
- (void) scrollToTopRight;
- (void) setRotate : (bool) isvertical;
- (void) setOrientation: (int) orientation animate:(bool)anime;
- (void) goNextPage:(int) next;
- (CGSize) calcFitImage:(CGSize) oImage;

@end
