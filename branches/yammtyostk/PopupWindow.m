#import "PopupView.h"
#import <GraphicsServices/GraphicsServices.h>

@implementation PopupWindow
- (id)initWithFrame:(CGRect)frame fOrientation:(float)fOrientation
{
	if ([super initWithFrame:frame])
	{
		_view = [[PopupView alloc] initWithFrame: [self bounds]];
		[_view setBackgroundColor:GSColorCreateColorWithDeviceRGBA(0.0, 0.0, 0.0, .0)];
		CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), fOrientation  * M_PI / 180.0f);
		[self setContentView:_view]; 
		[_view setTransform: matrix];
		[self orderFront:nil]; 
		[self makeKey:nil];
		[self _setHidden: NO];
	}
	return self;
}


- (void)Draw
{
	CGContextRef context = UICurrentContext();
	CGContextSaveGState(context);
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGContextDrawImage (context, CGRectMake(0,0,48,48), [_ileft imageRef]);
	CGContextRestoreGState(context);
}

@end



