#import "ScrollImage.h"
#import <GraphicsServices/GraphicsServices.h>
#import "Global.h"

#define MIN_SCALE (1.0f)
#define MAX_SCALE (4.0f)
#define ZOOM_RATE (0.005f)

#define NEXT_PAGE 1
#define PREV_PAGE 2
#define EXIT_PAGE 3

struct CGRect screct;		//フルスクリーンの始点とサイズを保持
bool _bGoNext;				//ズームモード


@implementation ScrollImage
- (id)initWithFrame:(struct CGRect)frame
{
	//フルスクリーンの始点とサイズを取得する
	screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin = CGPointZero;

	[super initWithFrame: frame];
	_imagezoom = MIN_SCALE;			//ズーム倍率
	_currentimage = nil;			//イメージなし
	_mdelegate = nil;
	_imageview = [[UIImageView alloc] initWithFrame:frame];
	[self addSubview: _imageview];
	//中心点を画面の中心に設定
	_centerpoint = CGPointMake(screct.size.width / 2, screct.size.height / 2);
	_isVertical = true;				//縦位置で初期化
	_matrixprev =	CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), 0 * M_PI / 180.0f);
	_isvert = true;					//縦
	_orient = 1;					//正面 0°
	_bGoNext = false;

	[super setTapDelegate: self];
	[super setGestureDelegate: self];
//	NSBundle *bundle = [NSBundle mainBundle];
//	_ileft = [UIImage imageAtPath: [bundle pathForResource:@"left" ofType:@"png"]];
//	_iright = [UIImage imageAtPath: [bundle pathForResource:@"right" ofType:@"png"]];
//	_ihome = [UIImage imageAtPath: [bundle pathForResource:@"home" ofType:@"png"]];
	return self;
}


/******************************/
/*                            */
/******************************/
- (void)view:(UIView *)view handleTapWithCount:(int)count event:(GSEvent *)event
{
//	NSLog(@"%d", count);
}

/******************************/
/* イメージを回転させる       */
/******************************/
-(void) setOrientation: (int) orientation animate:(bool)anime
{
	float degree = 0;
	float tscale = 1.0f;
	float movex = 0.0f;
	float movey = 0.0f;
	bool misvert = _isvert;		//現在の角度を保存する

	//回転角度が変わらない場合や、値が不正(1～4以外)は何もせず終了
	if( (_orient == orientation) || (orientation == 0) || (orientation >= 5) ) return;
	//次の角度を設定する
	switch(orientation){
	case 1:		//正面 0°
		_isvert = true;
		degree = 0 * M_PI / 180.0f;
		movex = 0.0;
		movey = 0.0;
		break;
	case 2:		//180°
		_isvert = true;
		degree = 180 * M_PI / 180.0f;
		movex = 0.0;
		movey = 0.0;
		break;
	case 3:		//左 90°
		_isvert = false;
		degree = 90 * M_PI / 180.0f;
		movex = 0.0;
		movey = screct.size.width / 2;
		break;
	case 4:		//右 270°
		_isvert = false;
		degree = -90 * M_PI / 180.0f;
		movex = 0.0;
		movey = screct.size.width / 2;
		break;
	default:
		return;
	}
	//新しい角度を保持
	_orient = orientation;
	//前と縦横が違うなら、切り替える
	if( (misvert != _isvert) && (_isvert == false) ){
		tscale = 1.4375f;
	}
	//アニメーションの設定（アフィン変化マトリックス??）
	CGAffineTransform matrix = CGAffineTransformTranslate(
			CGAffineTransformRotate(CGAffineTransformMakeScale(tscale, tscale), degree), movex, movey );
	UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: _imageview];
	[scaleAnim setStartTransform: _matrixprev];
	[scaleAnim setEndTransform: matrix];
	UIAnimator *anim = [[UIAnimator alloc] init];
	//アニメーション
	if(anime)	//する
		[anim addAnimation:scaleAnim withDuration:0.50f start:YES];
	else		//しない
		[anim addAnimation:scaleAnim withDuration:0.01f start:YES];
	//現在のアニメーション情報を保存する
	_matrixprev = matrix;
	//[self fitRect];
	[NSTimer scheduledTimerWithTimeInterval: 0.51f target: self selector:@selector(add:) userInfo:self repeats:NO];
}

-(void) add: (NSTimer*) timer
{
	ScrollImage * view = [timer userInfo];
	//[view fitRect];
	[self fitRect];
	[self resizeImage];			//リサイズする
	[self scrollToTopRight];	//右上に移動
}

/******************************/
/* 画面サイズに合わせる       */
/******************************/
- (void) fitRect
{
	if( (_imagesize.width == 0) || (_imagesize.height == 0) ) return;

	if( prefData.ToFitScreen == YES){
		_imagesize = [self calcFitImage:_imagesize];
	}
	else{
		float zoomRate, tmpZoomH, tmpZoomW;
		if( _isvert == true ){
			tmpZoomH = screct.size.height / _imagesize.height;
			tmpZoomW = screct.size.width / _imagesize.width;
		}
		else{
			if( _imagesize.height > _imagesize.width ){
				tmpZoomW = tmpZoomH = screct.size.height / _imagesize.width;
			}
			else{
				tmpZoomH = screct.size.height / _imagesize.width;
				tmpZoomW = screct.size.width / _imagesize.height;
			}
		}
		if(tmpZoomH > tmpZoomW)
			zoomRate = tmpZoomW;
		else
			zoomRate = tmpZoomH;
		_imagesize.height *= zoomRate;
		_imagesize.width *= zoomRate;
	}
	//基準の画像サイズを保存
	_oimagesize = _imagesize;
	//拡大率を指定する場合
	if( (prefData.ToKeepScale == YES) && (_imagezoom > 0) ){
		_imagesize.width *= _imagezoom;
		_imagesize.height *= _imagezoom;
	}
}

/******************************/
/*                            */
/******************************/
- (void) dealloc
{
	[_imageview release];
	[_currentimage release];
}

/******************************/
/* 画面のリサイズ             */
/******************************/
- (void) resizeImage
{
	CGSize resizeTmp;

	resizeTmp.width		= (_isvert?	_imagesize.width:	_imagesize.height);
	resizeTmp.height	= (_isvert?	_imagesize.height:	_imagesize.width);

	CGRect frame = CGRectMake(0, 0, resizeTmp.width, resizeTmp.height);
	[_imageview setFrame: frame];			//サイズを変更する
	[self setContentSize: frame.size];		//画面表示用イメージオブジェクトのサイズを保存
}

/******************************/
/*                            */
/******************************/
- (void) setPercent : (float)percent
{
	_imagezoom = percent;
}

/******************************/
/* イメージを設定する         */
/******************************/
- (int) setImage : (NSData*) data
{
	UIImage *image = [[UIImage alloc] initWithData: data cache: true];
	//イメージのサイズを取得する
	CGSize frame = [image size];
	int ret = 0;
	if(frame.width > 1390 || frame.height > 1390){
		ret = 1;
	}
	//
	[self setImageFromImage: image];

	return ret;
}

/******************************/
/* イメージを保存する         */
/******************************/
- (void) setImageFromImage : (UIImage *)image withFlag:(BOOL)flag;
{
	UIImage *maeimage = _currentimage;
	BOOL mflag = _maeFlag;
	_maeFlag = flag;

	//イメージを保存
	_currentimage = image;					//イメージのオブジェクトを保存
	_imagesize = [_currentimage size];		//イメージのサイズを保存
	[image setOrientation: 0];				//イメージの回転方向を0
	[_imageview setImage: _currentimage];	//イメージを表示イメージに設定
	[self setContentSize: _imagesize];		

	if(maeimage != nil){
		if(mflag) CGImageRelease([maeimage imageRef]);
		[maeimage release];
	}
}

/******************************/
/* イメージを右上に移動する   */
/******************************/
- (void) scrollToTopRight
{
	CGPoint moveOffset;

	switch(_orient){
	case 1:		//正面 0°
		moveOffset = CGPointMake(_imagesize.width - screct.size.width, 0);
		break;
	case 2:		//180°
		moveOffset = CGPointMake(0, _imagesize.height - screct.size.height);
		break;
	case 3:		//左 90°
		moveOffset = CGPointMake(_imagesize.height - screct.size.width, _imagesize.width - screct.size.height);
		break;
	case 4:		//右 270°
	default:
		moveOffset = CGPointMake(0, 0);
		break;
	}
// NSLog(@"moveOffset x=%f,y=%f", moveOffset.x, moveOffset.y);
	[super setOffset:moveOffset];
}

/******************************/
/* ズーム倍率を返す           */
/******************************/
- (float) getPercent
{
	return _imagezoom;
}

/******************************/
/* 画面をタッチした時の動作   */
/******************************/
- (void)mouseDown:(GSEventRef)theEvent
{
	// DOWNイベントの座標を取得する
	_cgpDown = GSEventGetLocationInWindow(theEvent);

	// 2本指でタッチ（ 0 = one finger down、1 = two fingers down ）
	if( GSEventIsChordingHandEvent(theEvent) ){
		// タッチしている2つの座標を取得する。pt1、pt2
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);
		_fDistancePrev = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y-pt1.y)*(pt2.y-pt1.y));
		// 2本指の中心点を中心点に設定する
		_centerpoint = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
	}

	[super mouseDown:theEvent];
}

/********************************/
/* 画面のタッチを離した時の動作 */
/********************************/
- (void)mouseUp:(GSEventRef)theEvent
{
	int next=0, lt=0, lb=0, rt=0, rb=0, hit=0;

	//スクロールが有効な場合は、画面移動は無効
	if( _bGoNext == true ){
		_bGoNext = false;
		[super mouseUp:theEvent];
		return;
	}
	_bGoNext = false;

	// 角判定の大きさを取得
	hit = prefData.HitRange;
	// UPイベントの座標を取得する
	_cgpUp = GSEventGetLocationInWindow(theEvent);
	
	// タッチした場所を判定する。lt=左上、lb=左下、rt=右上 rb=右下
	if( (fabs(_cgpDown.x - _cgpUp.x) < (hit/5)) && (fabs(_cgpDown.y - _cgpUp.y) < (hit/5)) ){
		lt = (_cgpUp.x < hit) && (_cgpUp.y < hit);
		lb = (_cgpUp.x < hit) && (_cgpUp.y > (screct.size.height - hit));
		rt = (_cgpUp.x > (screct.size.width - hit)) && (_cgpUp.y < hit);
		rb = (_cgpUp.x > (screct.size.width - hit)) && (_cgpUp.y > (screct.size.height - hit));
	}
	// ボタン判定
	switch(_orient){
	case 1:		//正面 0°
		if( lt )		next = EXIT_PAGE;
		else if( lb )	next = (prefData.LBtnIsNext? NEXT_PAGE: PREV_PAGE);
		else if( rb )	next = (prefData.LBtnIsNext? PREV_PAGE: NEXT_PAGE);
		break;
	case 2:		//180°
		if( rb )		next = EXIT_PAGE;
		else if( rt )	next = (prefData.LBtnIsNext? NEXT_PAGE: PREV_PAGE);
		else if( lt )	next = (prefData.LBtnIsNext? PREV_PAGE: NEXT_PAGE);
		break;
	case 3:		//左 90°
		if( rt )		next = EXIT_PAGE;
		else if( lt )	next = (prefData.LBtnIsNext? NEXT_PAGE: PREV_PAGE);
		else if( lb )	next = (prefData.LBtnIsNext? PREV_PAGE: NEXT_PAGE);
		break;
	case 4:		//右 270°
		if( lb )		next = EXIT_PAGE;
		else if( rb )	next = (prefData.LBtnIsNext? NEXT_PAGE: PREV_PAGE);
		else if( rt )	next = (prefData.LBtnIsNext? PREV_PAGE: NEXT_PAGE);
		break;
	default:
		break;
	}
	//ボタンページめくりは無効
	if( (next!=EXIT_PAGE)&&(prefData.ButtonSlide!=YES) ) next = 0;

	[self goNextPage:next];
	[super mouseUp:theEvent];
}

/******************************/
/*                            */
/******************************/
- (void) setRotate : (bool) isvertical
{
	_isVertical = isvertical;
	[self fitRect];
	[self resizeImage];			//リサイズする
	[self scrollToTopRight];	//右上に移動
	CGRect rc = [self frame];
}

/******************************/
/*                            */
/******************************/
- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated:YES];
}

/******************************/
/* 画面をドラッグした時       */
/******************************/
- (void)mouseDragged:(GSEventRef)theEvent
{
//NSLog(@"mouseDragged");
	_bGoNext = true;

	// 2本指でタッチ（ 0 = one finger down、1 = two fingers down ）
	if ( GSEventIsChordingHandEvent(theEvent) ){
//NSLog(@"mouseDragged 2 touch");

		// タッチしている2つの座標を取得する。pt1、pt2
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);

		//2本指の距離を計算し、前回の距離との増分を出す。
		float fDistance = sqrt( (pt2.x-pt1.x) * (pt2.x-pt1.x) + (pt2.y-pt1.y) * (pt2.y-pt1.y) );
		float fHowFar = fDistance - _fDistancePrev;
		float imagezoomPrev = _imagezoom;

		//現在の2本指の距離を保存する
		_fDistancePrev = fDistance;
		//ズーム倍率を今回の増分だけ増減する
//		_imagezoom += ZOOM_RATE * fHowFar;
		_imagezoom += (ZOOM_RATE * fHowFar * _imagezoom);

		//倍率が範囲を超える場合は、最大・最小値に設定
		if( _imagezoom < MIN_SCALE ){
			_imagezoom = MIN_SCALE;
		}
		else if( MAX_SCALE < _imagezoom ){
			 _imagezoom = MAX_SCALE;
		}
		//倍率が変わった場合リサイズ
		if( imagezoomPrev != _imagezoom ){
			CGSize org = _imagesize;
			CGPoint pt = [self offset];
			
			//リサイズ
			_imagesize.width = _oimagesize.width * _imagezoom;
			_imagesize.height = _oimagesize.height * _imagezoom;
			[self resizeImage];
			
			//オフセット
			if( _isvert == true ){
				pt.x += (_imagesize.width - org.width) * ((pt.x + _centerpoint.x) / _imagesize.width);
				pt.y += (_imagesize.height - org.height) * ((pt.y + _centerpoint.y) / _imagesize.height);
			}
			else{
				pt.x += (_imagesize.height - org.height) * ((pt.x + _centerpoint.x) / _imagesize.height);
				pt.y += (_imagesize.width - org.width) * ((pt.y + _centerpoint.y) / _imagesize.width);
			}
			[self setOffsetFit:pt];
		}
		// ズームする場合はここで終了
		return;
	}
	//スクロールを実施する
	[super mouseDragged:theEvent];
}

/******************************/
/* メソッドを引き継ぐ         */
/******************************/
- (void) setScrollDelegate: (id) del
{
	_mdelegate = del;		//参照元のIDを登録する
}

/******************************/
/* スワイプが有効かを返す     */
/******************************/
- (BOOL)canHandleSwipes
{
	return (prefData.SwipeSlide && !_bGoNext);
}

/******************************/
/* スワイプ操作               */
/******************************/
- (int)swipe: (int)orientation withEvent: (GSEventRef)event
{
	int next=0;
	switch(_orient){
	case 1:		//正面 0°
		if( orientation == 8 )		next = (prefData.SlideRight? NEXT_PAGE: PREV_PAGE);
		else if( orientation == 4 )	next = (prefData.SlideRight? PREV_PAGE: NEXT_PAGE);
		break;
	case 2:		//180°
		if( orientation == 4 )		next = (prefData.SlideRight? NEXT_PAGE: PREV_PAGE);
		else if( orientation == 8 )	next = (prefData.SlideRight? PREV_PAGE: NEXT_PAGE);
		break;
	case 3:		//左 90°
		if( orientation == 2 )		next = (prefData.SlideRight? NEXT_PAGE: PREV_PAGE);
		else if( orientation == 1 )	next = (prefData.SlideRight? PREV_PAGE: NEXT_PAGE);
		break;
	case 4:		//右 270°
		if( orientation == 1 )		next = (prefData.SlideRight? NEXT_PAGE: PREV_PAGE);
		else if( orientation == 2 )	next = (prefData.SlideRight? PREV_PAGE: NEXT_PAGE);
		break;
	default:
		break;
	}
	[self goNextPage:next];
	[super swipe:orientation withEvent:event];
}

/******************************/
/* 次の画面に移動する         */
/******************************/
- (void) goNextPage:(int) next
{
	//クリック音を鳴らす
	if( next != 0 )	SOUND_CLICK;

	switch(next){
	case NEXT_PAGE:
		if([_mdelegate respondsToSelector:@selector(scrollImage:fileNext:)])
			[_mdelegate scrollImage:self fileNext:self];
		break;
	case PREV_PAGE:
		if([_mdelegate respondsToSelector:@selector(scrollImage:filePrev:)])
			[_mdelegate scrollImage:self filePrev:self];
		break;
	case EXIT_PAGE:
		if([_mdelegate respondsToSelector:@selector(scrollImage:fileEnd:)])
			[_mdelegate scrollImage:self fileEnd:self];
		break;
	default:
		break;
	}
}

/**********************************/
/* イメージの基準サイズを作成する */
/**********************************/
- (CGSize) calcFitImage:(CGSize) oImage
{
	CGSize calcImage = CGSizeZero;
	bool isVert = (oImage.width < oImage.height);
	float aspect = oImage.height / oImage.width;

	if( _isvert == true ){
		//イメージが縦長の場合、画面一杯に合わせる
		if(isVert){
			float tmpZoomH = screct.size.height / oImage.height;
			float tmpZoomW = screct.size.width / oImage.width;
			//比率を見て、画面に近い場合は、一杯に引き伸ばす
			if( (float)fabs(tmpZoomH-tmpZoomW) < (float)0.05){
				calcImage.height = screct.size.height;
				calcImage.width = screct.size.width;
			}
			else{
				//ちょっと画面サイズから外れる場合は、長辺を合わせる
				if(tmpZoomW > tmpZoomH){
					calcImage.height = screct.size.height;
					calcImage.width = screct.size.height / aspect;
				}
				else{
					calcImage.height = screct.size.width * aspect;
					calcImage.width = screct.size.width;
				}
			}
		}
		//イメージが横長の場合、イメージの縦を合わせる
		else{
			calcImage.height = screct.size.height;
			calcImage.width = oImage.width * screct.size.height / oImage.height;
		}
	}
	else{
		//イメージが縦長の場合、イメージの横を合わせる
		if(isVert){
			calcImage.height = screct.size.height * aspect;
			calcImage.width = screct.size.height;
		}
		//イメージが横長の場合、イメージの横半分を丁度にする
		else{
			calcImage.height = screct.size.height * aspect * 2;
			calcImage.width = screct.size.height * 2;
		}
	}
	return calcImage;
}

/******************************/
/* オフセット値を設定する     */
/******************************/
- (void) setOffsetFit:(CGPoint)pt
{
//NSLog(@"setOffsetFit");
	CGPoint ret = pt;
	float image_w	= (_isvert?	_imagesize.width:	_imagesize.height);
	float image_h	= (_isvert?	_imagesize.height:	_imagesize.width);

	if( image_w  < screct.size.width ){
		switch(_orient){
		case 1:		//正面 0°
		case 3:		//左 90°
			ret.x = image_w - screct.size.width;
			break;
		case 2:		//180°
		case 4:		//右 270°
		default:
			ret.x = 0;
			break;
		}
	}
	else if(pt.x < 0){
		ret.x = 0;
	}
	else if( (image_w - pt.x) < screct.size.width ){
		ret.x = image_w - screct.size.width;
	}

	if( image_h  < screct.size.height ){
		switch(_orient){
		case 1:		//正面 0°
		case 4:		//右 270°
			ret.y = 0;
			break;
		case 2:		//180°
		case 3:		//左 90°
		default:
			ret.y = image_h - screct.size.height;
			break;
		}
	}
	else if(pt.y < 0){
		ret.y = 0;
	}
	else if( (image_h - pt.y) < screct.size.height ){
		ret.y = image_h - screct.size.height;
	}
	[super setOffset:ret];
}

@end
