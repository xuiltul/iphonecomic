#import "PopupView.h"
#import <GraphicsServices/GraphicsServices.h>

@implementation PopupView
- (id)initWithFrame:(struct CGRect)frame
{
	NSBundle *bundle = [NSBundle mainBundle];
	_ileft = [UIImage imageAtPath: [bundle pathForResource:@"left" ofType:@"png"]];
	_iright = [UIImage imageAtPath: [bundle pathForResource:@"right" ofType:@"png"]];
	_ihome = [UIImage imageAtPath: [bundle pathForResource:@"home" ofType:@"png"]];
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



