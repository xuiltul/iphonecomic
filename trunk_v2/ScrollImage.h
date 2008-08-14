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
	UIImage*		_currentimage;			//イメージオブジェクト
	CGSize			_imagesize;				//イメージサイズ
	CGSize			_oimagesize;			//イメージサイズ
	UIImageView*	_imageview;				//表示用イメージオブジェクト
	id				_mdelegate;
	CGPoint			_centerpoint;			//中心座標
	bool			_isvert;				//縦か横か
	int				_orient;				//回転角度
	UIImage*		_ileft, *_iright, *_ihome;
	BOOL			_maeFlag;

	bool			_isDragged;				//スクロール、ズームしたか

	CGPoint			_cgpDown;
	CGPoint			_cgpUp;

	int				_tapCount;				//タップ回数（0:タップ無し、1～:タップ回数）
}

- (void) fitRect;
- (void) fitRect:(bool)flag;
- (int) setImage : (NSData*) data;
- (void) setImageFromImage : (UIImage *)image withFlag: (BOOL) flag;
- (void) resizeImage;
- (void) setScrollDelegate: (id) del;
- (void) scrollToTopRight;
- (void) setRotate : (bool) isvertical;
- (void) setOrientation:(int)orientation;
- (void) setOrientZoom;
- (void) goNextPage:(int) next;
- (void) setOffsetFit:(CGPoint)pt;
- (CGSize) calcFitImage:(CGSize) oImage;
- (void) setResize:(float)zoomSet;

@end
