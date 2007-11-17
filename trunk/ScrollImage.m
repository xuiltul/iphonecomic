#import "ScrollImage.h"
#import <GraphicsServices/GraphicsServices.h>
#import "Global.h"

float kMinScale = (0.1f);
#define kMaxScale (1.0f)
int SCHEIGHT = 460;
struct CGRect screct;

@implementation ScrollImage
- (id)initWithFrame:(struct CGRect)frame{
	screct = [UIHardware fullScreenApplicationContentRect];

	screct.origin.x = screct.origin.y = 0;
	SCHEIGHT = screct.size.height;
	
	[super initWithFrame: frame];
	_fCurrentPercent = 1.0f;
	_currentimage = nil;
	_mdelegate = nil;
	_imageview = [[UIImageView alloc] initWithFrame:frame];
	[self addSubview: _imageview];
	[super setTapDelegate: self];
	_centerpoint = CGPointMake(320 / 2, SCHEIGHT / 2);
	_isVertical = true;
	_matrixprev =	CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), 0  * M_PI / 180.0f);
	_isvert = true;
	
//	NSBundle *bundle = [NSBundle mainBundle];
//	_ileft = [UIImage imageAtPath: [bundle pathForResource:@"left" ofType:@"png"]];
//	_iright = [UIImage imageAtPath: [bundle pathForResource:@"right" ofType:@"png"]];
//	_ihome = [UIImage imageAtPath: [bundle pathForResource:@"home" ofType:@"png"]];
	return self;
}


- (void)view:(UIView *)view handleTapWithCount:(int)count event:(GSEvent *)event
{
	//NSLog(@"%d", count);
}

-(void) setOrientation: (int) orientation animate:(bool)anime
{
	if(_orient == orientation) return;
	if(orientation == 0 || orientation >= 5) return;
	int degree = 0;
	float tscale = 1.5f;
	bool misvert = _isvert;
	bool tochange = false;
	switch(orientation)
	{
		case 1:
			_isvert = true;
			degree = 0;
			break;
		case 2:
			_isvert = true;
			degree = 180;
			break;
		case 3:
			_isvert = false;
			degree = 90;
			break;
		case 4:
			_isvert = false;
			degree = -90;
			break;
//		* 0 - Phone is flat (on a table?) with screen upwards
//		* 1 - Phone is in normal position
//		* 2 - Phone is rotated upside-down
//		* 3 - Phone is rotated to the left
//		* 4 - Phone is rotated to the right
//		* 5 - Phone is changing orientation ?
//		* 6 - Phone is flat, with screen downwards - very useful! 
		default:
			return;
	}
	_orient = orientation;

	//前と縦横が違うなら、切り替える
	tochange = (misvert != _isvert);

	CGAffineTransform matrix;
	 
	if(tochange)
	{
		//前が横向き、今は縦
		if(_isvert == true)
		{
			matrix = CGAffineTransformTranslate(
			CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), degree  * M_PI / 180.0f), 0, 0);
		}
		else
		{
			matrix = CGAffineTransformTranslate(
			CGAffineTransformRotate(CGAffineTransformMakeScale(1.4375f, 1.4375f), degree  * M_PI / 180.0f), 0, 0);
		}
	}
	else
	{
		matrix = CGAffineTransformTranslate(
		CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), degree  * M_PI / 180.0f), 0, 0);
	}
	//CGAffineTransformRotate(CGAffineTransformTranslation(0, 0), degree  * M_PI / 180.0f);
	UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: _imageview];
	[scaleAnim setStartTransform: _matrixprev];
	[scaleAnim setEndTransform: matrix];
	UIAnimator *anim = [[UIAnimator alloc] init];
	
	if(anime)
	{
		[anim addAnimation:scaleAnim withDuration:0.50f start:YES]; 
	}
	else
	{
		[anim addAnimation:scaleAnim withDuration:0.01f start:YES]; 
	}
	_matrixprev = matrix;
	//[self fitRect];
	[NSTimer scheduledTimerWithTimeInterval: 0.51f target: self selector:@selector(add:) userInfo:self repeats:NO];

}

-(void) add: (NSTimer*) timer
{
	ScrollImage * view = [timer userInfo];
	//[view fitRect];
	[self fitRect];
}

- (void) fitRect
{
	float w = 320, h = SCHEIGHT;// if(_isvert == false){w = 480;h = 320;}
	CGSize imageRect = _imagesize;
	CGRect imageViewRect = CGRectMake(0, 0, w, h);
	if(_isvert)
	{
		//	NSLog(@"%f %f, %f", _fCurrentPercent, imageRect.width, imageRect.height);
		//Create viewing rectangle for image that centers the image, and contracts it if needed
		if (imageRect.width > imageViewRect.size.width || imageRect.height > imageViewRect.size.height)
		{
			float imageAspect = imageRect.width / imageRect.height;

			imageViewRect.size.height = h;
			imageViewRect.size.width = imageViewRect.size.height * imageAspect;
			_fCurrentPercent = (imageViewRect.size.width / imageRect.width);
		
			if (imageRect.width > imageViewRect.size.width)
			{
				imageViewRect.size.width = w;
				imageViewRect.size.height = imageViewRect.size.width / imageAspect;
				_fCurrentPercent = (imageViewRect.size.height / imageRect.height);					
			}
		}
		[_imageview setFrame: CGRectMake(0, 0, imageRect.width, imageRect.height)];
	}
	else
	{
		_fCurrentPercent = (SCHEIGHT / imageRect.width);
		//_fCurrentPercent = (320 / imageRect.height);
	}
	kMinScale = _fCurrentPercent;

	_fCurrentPercent *= 1.001f;
	
	/*imageRect.origin.x = imageViewRect.origin.x + 
	imageViewRect.size.width * 0.5f - imageRect.size.width * 0.5f;
	imageRect.origin.y = imageViewRect.origin.y + 
	imageViewRect.size.height * 0.5f - imageRect.size.height * 0.5f;*/
	
	//Set the image viewing frame
	[self resizeImage];
	[self scrollToTopRight];
}


- (void) resizeImage
{
	float w = 320, h = SCHEIGHT; //if(_isvert == false){w = 480;h = 320;}
	CGRect mframe = [_imageview frame];
	float isw = _imagesize.width, ish = _imagesize.height;
	if(_isvert == false) {  isw = _imagesize.height; ish = _imagesize.width; }
	CGRect frame = CGRectMake(0, 0, isw * _fCurrentPercent, ish * _fCurrentPercent);
/*	CGRect imageViewRect = CGRectMake(0, 0, 320, 480 - 48 * 1.5);
	frame.origin.x = imageViewRect.origin.x + 
	imageViewRect.size.width * 0.5f - frame.size.width * 0.5f;
	frame.origin.y = imageViewRect.origin.y + 
	imageViewRect.size.height * 0.5f - frame.size.height * 0.5f;*/
	
	[_imageview setFrame: frame];
	[self setContentSize: frame.size];
	
	if(_isvert == true)
	{
		[self setOffset: CGPointMake(frame.size.width * _centerpoint.x / w - _centerpoint.x,
		frame.size.height * _centerpoint.y / h - _centerpoint.y + 11)];
	}
	
	//NSLog(@"%f %f", frame.size.width * _centerpoint.x / w - _centerpoint.x, frame.size.height * _centerpoint.y / 480.0f - _centerpoint.y);
	//[self scrollRectToVisible: CGRectMake(frame.size.width * _centerpoint.x / 320.0f - _centerpoint.x,
	// frame.size.height * _centerpoint.y / 480.0f - _centerpoint.y, 320, 480) animated:NO];
	//[self scrollByDelta: CGSizeMake(frame.size.width - mframe.size.width, frame.size.height - mframe.size.height)];
}

- (void) setMouseDelegate: (id) del
{
	_mdelegate = del;
}

- (void) setPercent : (float)percent
{
	_fCurrentPercent = percent;
	[self resizeImage];
	//[self setOffset: CGPointMake(0,0)];
}


- (int) setImage : (NSData*) data
{
	UIImage *image = [[UIImage alloc] initWithData: data cache: true];
	CGSize frame = [image size];
	int ret = 0;
	if(frame.width > 1390 || frame.height > 1390)
	{
		ret = 1;
	}
	[self setImageFromImage: image];
	return ret;
}

- (void) setImageFromImage : (UIImage *)image withFlag:(BOOL)flag;
{
	UIImage *maeimage = _currentimage;
	BOOL mflag = _maeFlag;
	_maeFlag = flag;
	
	
	//imageviewを作り直してみる
	/*[_imageview removeFromSuperview];
	[_imageview release];
	_imageview = [[UIImageView alloc] initWithFrame:screct];
	
	UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: _imageview];
	[scaleAnim setStartTransform: CGAffineTransformMakeScale(1, 1)];
	[scaleAnim setEndTransform: _matrixprev];
	UIAnimator *anim = [[UIAnimator alloc] init];
	[anim addAnimation:scaleAnim withDuration:0 start:YES]; */
	[self addSubview: _imageview];

	//イメージを保存
	_currentimage = image;
	_imagesize = [_currentimage size];
	[image setOrientation: 0];
	[_imageview setImage: _currentimage];

	[self setContentSize: _imagesize];

	if(maeimage != nil)
	{
		if(mflag) CGImageRelease([maeimage imageRef]);
		[maeimage release];
	}
}

- (void) scrollToTopRight
{	
	CGRect frame = CGRectMake(0, 0, _imagesize.width * _fCurrentPercent, _imagesize.height * _fCurrentPercent);
	if(_orient == 1 || _orient == 2)
	{
		[self scrollRectToVisible: CGRectMake(frame.size.width - 1, 0, 1, 1)];
	}
	else
	{
		if(_orient == 3)
			[self scrollRectToVisible: CGRectMake(frame.size.height - 2, 0, 2, 2)];
		else
			[self setOffset: CGPointMake(0,0)];
			
	}
}


- (float) getPercent
{
	return _fCurrentPercent;
}

- (void)mouseDown:(GSEventRef)theEvent
{
	float hit = prefsData.HitRange;
	int w = 320, h = SCHEIGHT;// if(_isVertical == false){w = 480;h = 320;}

	CGPoint r = GSEventGetLocationInWindow(theEvent);
	
	int lt = r.x < hit && r.y < hit;
	int lb = r.x < hit && r.y > h - hit;
	int rt = r.x > w - hit && r.y < hit;
	int rb = r.x > w - hit && r.y > h - hit;
	
	int hlt, hlb, hrt, hrb;
	switch(_orient)
	{
		case 1:
			hlt = lt;
			hlb = lb;
			hrt = rt;
			hrb = rb;
			break;
		case 2:
			hlt = rb;
			hlb = rt;
			hrt = lb;
			hrb = lt;
			break;
		case 3:
			hlt = rt;
			hlb = lt;
			hrt = rb;
			hrb = lb;
			break;
		case 4:
			hlt = lb;
			hlb = rb;
			hrt = lt;
			hrb = rt;
			break;
	}
	
	if(!prefsData.SlideDirection)
	{
//		int temp = hlt;
//		hlt = hrt;
//		hrt = temp;
		int temp = hlb;
		hlb = hrb;
		hrb = temp;
	}
	
	//左上
	if(hlt) 
	{
		if([_mdelegate respondsToSelector:@selector(scrollImage:fileEnd:)])
		{
			[_mdelegate scrollImage:self fileEnd:self];
			return;
		}	
	}
	
	//左下
	if(hlb)
	{
		if([_mdelegate respondsToSelector:@selector(scrollImage:filePrev:)])
		{
			[_mdelegate scrollImage:self filePrev:self];
			return;
		}
	}
	
	//右下
	if(hrb)
	{
		if([_mdelegate respondsToSelector:@selector(scrollImage:fileNext:)])
		{
			[_mdelegate scrollImage:self fileNext:self];
			return;
		}
	}




	bool isChording = GSEventIsChordingHandEvent(theEvent);	
	int count = GSEventGetClickCount(theEvent);
	if (isChording)
	{	
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);
		_fDistanceStart = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt1.y));
		_fDistancePrev = _fDistanceStart;
		_centerpoint = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
		if(_isvert == false && 0)
		{
			float t = _centerpoint.x;
			_centerpoint.x = _centerpoint.y;
			_centerpoint.y = t;
		}
		///_bZooming = true;
	}

	[super mouseDown:theEvent];
}

- (void)mouseUp:(GSEventRef)theEvent
{
	_bZooming = false;
	[super mouseUp:theEvent];
}

- (void) setRotate : (bool) isvertical
{
	_isVertical = isvertical;
	//通常
	if(_isVertical)
	{
		//_centerpoint = CGPointMake(320 / 2, 480 / 2);
		//[self setFrame: CGRectMake(0, 0, 320, 480)];
	}
	else
	{
		//_centerpoint = CGPointMake(480 / 2, 320 / 2);
		//[self setFrame: CGRectMake(0, 0, 480, 320)];	
	}
	[self fitRect];
	
	CGRect rc = [self frame];
/*	UIAlertSheet* alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0,240,320,240)];
	[alertSheet setTitle: @"test"];
	[alertSheet setBodyText:[NSString stringWithFormat: @"%f, %f  %f, %f", rc.origin.x, rc.origin.y, rc.size.width, rc.size.height]];
	[alertSheet addButtonWithTitle: @"hoge"];
	[alertSheet setDelegate: self];
	[alertSheet popupAlertAnimated:YES];*/
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button {
	[sheet dismissAnimated:YES];
}

- (void)mouseDragged:(GSEventRef)theEvent
{

//_ileft
	if(!_bZooming)
	{	
//		[super mouseDragged:theEvent];
//		 return;
	}
	CGPoint pt = [self offset];
	bool isChording = GSEventIsChordingHandEvent(theEvent);	
	if (isChording)
	{
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent), pt2 = GSEventGetOuterMostPathPosition(theEvent);
		float fDistance = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt1.y));
		float fHowFar = fDistance - _fDistancePrev;
//		_centerpoint = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
		if(fabs(fHowFar) > 3)//( _bZooming ? 3 : 20))
		{
			_fCurrentPercent = _fCurrentPercent + (.004 * fHowFar); // パーセンテージをかける
			
			_bZooming = true;
			
			if(_fCurrentPercent <= kMinScale) _fCurrentPercent = kMinScale;
			if(_fCurrentPercent >= kMinScale && _fCurrentPercent <= kMaxScale)
			{
				[self resizeImage];
			}
			_fDistancePrev = fDistance;
		}
		
		if(_bZooming) return;

	} 

	[super mouseDragged:theEvent];
}

@end



