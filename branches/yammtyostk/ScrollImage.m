#import "ScrollImage.h"
#import <GraphicsServices/GraphicsServices.h>
#import "Global.h"

//float kMinScale = (0.1f);
#define MIN_SCALE (1.0f)
#define MAX_SCALE (2.0f)

#define NEXT_PAGE 1
#define PREV_PAGE 2
#define EXIT_PAGE 3

struct CGRect screct;		//フルスクリーンの始点とサイズを保持
int img_width=0, img_height=0;

@implementation ScrollImage
- (id)initWithFrame:(struct CGRect)frame
{
	//フルスクリーンの始点とサイズを取得する
	screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin = CGPointZero;
	//ステータスバーを出す場合
//	if(!prefData.HideStatusbar)	screct.size.height -= SCSTSBAR;

	[super initWithFrame: frame];
	_fCurrentPercent = 1.0f;		//ズーム倍率
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
	_bZooming = false;				//ズームモードを無効

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
	[self scrollToTopRight];		//右上に移動
}

/******************************/
/* 画面サイズに合わせる       */
/******************************/
- (void) fitRect
{
//	CGSize imageRect = _imagesize;

char tmp[256];
//sprintf(tmp,"fitRect img width=%f,height=%f\n",imageRect.width,imageRect.height);
sprintf(tmp,"fitRect img width=%f,height=%f\n",_imagesize.width,_imagesize.height);
debug_log(tmp);

//	if( (imageRect.width == 0) || (imageRect.height == 0) ) return;
	if( (_imagesize.width == 0) || (_imagesize.height == 0) ) return;

	if( prefData.ToFitScreen == YES){
		switch(_orient){
		case 1:		//正面 0°
		case 2:		//180°

sprintf(tmp,"fit 1 or 2\n");
debug_log(tmp);

			//イメージが横長の場合、イメージの縦を合わせる
//			if( imageRect.width > imageRect.height ){
			if( _imagesize.width > _imagesize.height ){

sprintf(tmp,"fit yoko\n");
debug_log(tmp);

//				img_height = screct.size.height;
				_imagesize.height = screct.size.height;
//				img_width = (int)(imageRect.width * screct.size.height / imageRect.height);
				_imagesize.width = (int)(_imagesize.width * screct.size.height / _imagesize.height);
			}
			//イメージが縦長の場合、画面一杯に合わせる
			else{

sprintf(tmp,"fit tate\n");
debug_log(tmp);

				float zoomRate;
//				float tmpZoomH = screct.size.height / imageRect.height;
//				float tmpZoomW = screct.size.width / imageRect.width;
				float tmpZoomH = screct.size.height / _imagesize.height;
				float tmpZoomW = screct.size.width / _imagesize.width;
				//比率を見て、画面に近い場合は、一杯に引き伸ばす
				if( (float)fabs(tmpZoomH-tmpZoomW) < (float)0.05){

sprintf(tmp,"fit fit\n");
debug_log(tmp);

//					img_height = screct.size.height;
//					img_width = screct.size.width;
					_imagesize.height = screct.size.height;
					_imagesize.width = screct.size.width;
				}
				else{

sprintf(tmp,"fit fit out\n");
debug_log(tmp);

					//ちょっと画面サイズから外れる場合は、長辺を合わせる
					if(tmpZoomH > tmpZoomW)
						zoomRate = tmpZoomW;
					else
						zoomRate = tmpZoomH;
//					img_height = (int)(imageRect.height * zoomRate);
//					img_width = (int)(imageRect.width * zoomRate);
					_imagesize.height = _imagesize.height * zoomRate;
					_imagesize.width = _imagesize.width * zoomRate;
				}
			}
			break;
		case 3:		//左 90°
		case 4:		//右 270°

sprintf(tmp,"fit 3 or 4\n");
debug_log(tmp);

			//イメージが横長の場合、イメージの横半分を丁度にする
//			if( imageRect.width > imageRect.height ){
			if( _imagesize.width > _imagesize.height ){

sprintf(tmp,"fit yoko\n");
debug_log(tmp);

//				img_width = screct.size.height*2;
				_imagesize.width = screct.size.height*2;
//				img_height = (int)((imageRect.height * screct.size.height * 2) / imageRect.width);
				_imagesize.height = (_imagesize.height * screct.size.height * 2) / _imagesize.width;
			}
			//イメージが縦長の場合、イメージの横を合わせる
			else{

sprintf(tmp,"fit tate\n");
debug_log(tmp);

//				img_width = screct.size.height;
//				img_height = (int)((imageRect.height * screct.size.height) / imageRect.width);
				_imagesize.height = (_imagesize.height * screct.size.height) / _imagesize.width;
				_imagesize.width = screct.size.height;
			}
			break;
		}
	}
	else{
		float zoomRate, tmpZoomH, tmpZoomW;
		switch(_orient){
		case 1:		//正面 0°
		case 2:		//180°

sprintf(tmp,"fit 1 or 2\n");
debug_log(tmp);

//			tmpZoomH = screct.size.height / imageRect.height;
//			tmpZoomW = screct.size.width / imageRect.width;
			tmpZoomH = screct.size.height / _imagesize.height;
			tmpZoomW = screct.size.width / _imagesize.width;
			break;
		case 3:		//左 90°
		case 4:		//右 270°

sprintf(tmp,"fit 3 or 4\n");
debug_log(tmp);

//			if( imageRect.height > imageRect.width ){
//				tmpZoomW = tmpZoomH = screct.size.height / imageRect.width;
			if( _imagesize.height > _imagesize.width ){
				tmpZoomW = tmpZoomH = screct.size.height / _imagesize.width;
			}
			else{
//				tmpZoomH = screct.size.height / imageRect.width;
//				tmpZoomW = screct.size.width / imageRect.height;
				tmpZoomH = screct.size.height / _imagesize.width;
				tmpZoomW = screct.size.width / _imagesize.height;
			}
			break;
		}
		if(tmpZoomH > tmpZoomW)
			zoomRate = tmpZoomW;
		else
			zoomRate = tmpZoomH;
//		img_height = (int)(imageRect.height * zoomRate);
//		img_width = (int)(imageRect.width * zoomRate);
		_imagesize.height = _imagesize.height * zoomRate;
		_imagesize.width = _imagesize.width * zoomRate;
	}
	_oimagesize = _imagesize;
//	kMinScale = _imagesize.width;
	//拡大率を指定する場合
	if( (prefData.ToKeepScale == YES) && (_fCurrentPercent > 0) ){
//		img_width *= _fCurrentPercent;
//		img_height *= _fCurrentPercent;
		_imagesize.width *= _fCurrentPercent;
		_imagesize.height *= _fCurrentPercent;
	}
//	kMinScale = screct.size.height/_imagesize.height;

//sprintf(tmp,"fitRect end img_width=%d,height=%d,kMinScale=%f\n",img_width,img_height,kMinScale);
sprintf(tmp,"fitRect end img_width=%f,height=%f,_fCurrentPercent=%f\n",_imagesize.width,_imagesize.height,_fCurrentPercent);
debug_log(tmp);
}

#if 0
/******************************/
/* 画面サイズに合わせる       */
/******************************/
- (void) fitRect
{
	CGSize imageRect = _imagesize;
	// イメージ表示の矩形を画面の大きさに設定する
	//	CGRect imageViewRect = CGRectMake(0, 0, screct.size.width, screct.size.height);

	if((imageRect.width == 0)||(imageRect.height == 0))		return;

	//画面サイズに合わせズーム倍率を設定する
	//縦の場合
	if(_isvert){
		//イメージが横長の場合、イメージの縦を合わせる
		if( imageRect.width > imageRect.height ){
			_fCurrentPercent = screct.size.height / imageRect.height;
		}
		//イメージが縦長の場合、画面一杯に合わせる
		else{
			float tmpPerH = screct.size.height / imageRect.height;
			float tmpPerW = screct.size.width / imageRect.width;
			if(tmpPerH > tmpPerW)
				_fCurrentPercent = tmpPerW;
			else
				_fCurrentPercent = tmpPerH;
		}
	}
	//横の場合
	else{
		//イメージが横長の場合、イメージの横半分位を丁度にする
		if( imageRect.width > imageRect.height ){
			_fCurrentPercent = (screct.size.height / imageRect.width) * 2.0;
		}
		//イメージが縦長の場合、イメージの横を合わせる
		else{
			_fCurrentPercent = screct.size.height / imageRect.width;
		}
	}

	kMinScale = _fCurrentPercent;
//	[self resizeImage];			//リサイズする
//	[self scrollToTopRight];	//右上に移動
}
#endif

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
//char tmp[256];
////sprintf(tmp,"resizeImage img_width=%d,img_height=%d\n",img_width,img_height);
//sprintf(tmp,"resizeImage width=%f,height=%f,_fCurrentPercent=%f\n",_imagesize.width,_imagesize.height,_fCurrentPercent);
//debug_log(tmp);
//
//	float isw = (_isvert?	img_width:	img_height);
//	float ish = (_isvert?	img_height:	img_width);
	CGSize resizeTmp;
	resizeTmp.width		= (_isvert?	_imagesize.width:	_imagesize.height);
	resizeTmp.height	= (_isvert?	_imagesize.height:	_imagesize.width);

//	CGRect frame = CGRectMake(0, 0, isw, ish);
	CGRect frame = CGRectMake(0, 0, resizeTmp.width, resizeTmp.height);
	[_imageview setFrame: frame];			//サイズを変更する
	[self setContentSize: frame.size];		//画面表示用イメージオブジェクトのサイズを保存
}
#if 0
/******************************/
/* 画面のリサイズ             */
/******************************/
- (void) resizeImage
{
	float isw, ish;

	//縦の場合は、イメージの縦横をそのまま設定
	if(_isvert){
		isw = _imagesize.width;
		ish = _imagesize.height;
	}
	//横の場合は、縦横を変換する
	else{
		isw = _imagesize.height;
		ish = _imagesize.width;
	}
	//画面表示用イメージオブジェクトのサイズをイメージ×ズーム倍率で設定する
	CGRect frame = CGRectMake(0, 0, isw * _fCurrentPercent, ish * _fCurrentPercent);
	[_imageview setFrame: frame];			//サイズを変更する
	[self setContentSize: frame.size];		//画面表示用イメージオブジェクトのサイズを保存

/*	if(_isvert == true){
		[self setOffset: CGPointMake(frame.size.width * _centerpoint.x / screct.size.width - _centerpoint.x,
			frame.size.height * _centerpoint.y / screct.size.height - _centerpoint.y + 11)];
	}*/
}
#endif

/******************************/
/*                            */
/******************************/
- (void) setPercent : (float)percent
{
char tmp[256];
sprintf(tmp,"setPercent img_width=%f,img_height=%f,_fCurrentPercent=%f,_orient=%d\n"
						,_imagesize.width,_imagesize.height,_fCurrentPercent,_orient);
debug_log(tmp);

	_fCurrentPercent = percent;
//	[self resizeImage];
	//[self setOffset: CGPointMake(0,0)];
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
char tmp[256];

	UIImage *maeimage = _currentimage;
	BOOL mflag = _maeFlag;
	_maeFlag = flag;

	//イメージを保存
	_currentimage = image;					//イメージのオブジェクトを保存
	_imagesize = [_currentimage size];		//イメージのサイズを保存
	[image setOrientation: 0];				//イメージの回転方向を0
	[_imageview setImage: _currentimage];	//イメージを表示イメージに設定
	[self setContentSize: _imagesize];		

sprintf(tmp,"setImageFromImage _imagesize w=%f,h=%f,_fCurrentPercent=%f,_orient=%d\n"
,_imagesize.width,_imagesize.height,_fCurrentPercent,_orient);
debug_log(tmp);

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
char tmp[256];
sprintf(tmp,"scrollToTopRight img_width=%f,img_height=%f,_fCurrentPercent=%f,_orient=%d\n"
,_imagesize.width,_imagesize.height,_fCurrentPercent,_orient);
//sprintf(tmp,"scrollToTopRight img_width=%d,img_height=%d,_fCurrentPercent=%f,_orient=%d\n"
//,img_width,img_height,_fCurrentPercent,_orient);
debug_log(tmp);

	//イメージのサイズにズーム倍率をかけて、イメージをスクロールする
	switch(_orient){
	case 1:		//正面 0°
//		isw = img_width;
//		ish = img_height;

		[self scrollRectToVisible: CGRectMake( _imagesize.width, 0, 1, 1)];
//		[self scrollRectToVisible: CGRectMake( img_width * _fCurrentPercent, 0, 1, 1)];
//		[self scrollRectToVisible: CGRectMake( _imagesize.width * _fCurrentPercent, 0, 1, 1)];
		break;
	case 2:		//180°
		[self setOffset: CGPointMake(0,0)];
		break;
	case 3:		//左 90°
		[self scrollRectToVisible: CGRectMake( _imagesize.height
												, _imagesize.width, 1, 1)];
//		[self scrollRectToVisible: CGRectMake( img_height * _fCurrentPercent
//												, img_width * _fCurrentPercent, 1, 1)];
//		[self scrollRectToVisible: CGRectMake( _imagesize.height * _fCurrentPercent
//												, _imagesize.width * _fCurrentPercent, 1, 1)];
		break;
	case 4:		//右 270°
	default:
		[self setOffset: CGPointMake(0,0)];
		break;
	}
}

/******************************/
/* ズーム倍率を返す           */
/******************************/
- (float) getPercent
{
char tmp[256];
sprintf(tmp,"getPercent img_width=%f,img_height=%f,_fCurrentPercent=%f,_orient=%d\n"
						,_imagesize.width,_imagesize.height,_fCurrentPercent,_orient);
debug_log(tmp);
	return _fCurrentPercent;
//	return _imagesize.width/kMinScale;
}

//******************************
//* 画面をタッチした時の動作   *
//******************************
- (void)mouseDown:(GSEventRef)theEvent
{
	// DOWNイベントの座標を取得する
	_cgpDown = GSEventGetLocationInWindow(theEvent);

//	int count = GSEventGetClickCount(theEvent);
	// 2本指でタッチ（ 0 = one finger down、1 = two fingers down ）
	if( GSEventIsChordingHandEvent(theEvent) ){
		// タッチしている2つの座標を取得する。pt1、pt2
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);
		_fDistancePrev = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt1.y));
		// 2本指の中心点を中心点に設定する
		_centerpoint = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
		_bZooming = true;
	}

	[super mouseDown:theEvent];
}

//********************************
//* 画面のタッチを離した時の動作 *
//********************************
- (void)mouseUp:(GSEventRef)theEvent
{
	int next=0, lt=0, lb=0, rt=0, rb=0, hit=0;

char tmp[256];
sprintf(tmp,"mouseUp w=%f,h=%f,_fCP=%f\n",_imagesize.width,_imagesize.height,_fCurrentPercent);
debug_log(tmp);

	//ズームモードが有効な場合は、画面移動は無効
	if( _bZooming == true ){
		_bZooming = false;
		return;
	}
	// 角判定の大きさを取得
	hit = prefData.HitRange;
	// UPイベントの座標を取得する
	_cgpUp = GSEventGetLocationInWindow(theEvent);
	
	// タッチした場所を判定する。lt=左上、lb=左下、rt=右上 rb=右下
	if( (fabs(_cgpDown.x - _cgpUp.x) < (hit/5))&&(fabs(_cgpDown.y - _cgpUp.y) < (hit/5)) ){
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
	[self scrollToTopRight];		//右上に移動
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
//char tmp[256];
//sprintf(tmp,"mouseDragged width=%f,height=%f\n",_imagesize.width,_imagesize.height);
//debug_log(tmp);

	// 2本指でタッチ（ 0 = one finger down、1 = two fingers down ）
	if ( GSEventIsChordingHandEvent(theEvent) ){
		// タッチしている2つの座標を取得する。pt1、pt2
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);

		//2本指の距離を計算し、前回の距離との増分を出す。
		float fDistance = sqrt( (pt2.x-pt1.x) * (pt2.x-pt1.x) + (pt2.y-pt1.y) * (pt2.y-pt1.y) );
		float fHowFar = fDistance - _fDistancePrev;
//		_centerpoint = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
		//前回の距離との増分（絶対値）が3より大きい場合
		if(fabs(fHowFar) > 3){
			//ズーム倍率を今回の増分だけ増減する
			_fCurrentPercent = _fCurrentPercent + (.004 * fHowFar); // パーセンテージをかける
			//ズームモードを有効にする
			_bZooming = true;
//			
//			//画面サイズ以下になった場合は、画面サイズに設定する
//			if(_fCurrentPercent <= kMinScale){
//				_fCurrentPercent = kMinScale;
//			}
//
//			//ズーム倍率が範囲内の場合、リサイズを実行する
//			if( (_fCurrentPercent >= kMinScale) && (_fCurrentPercent <= MAX_SCALE) ){
//				//リサイズする
//				img_width *= _fCurrentPercent;
//				img_height *= _fCurrentPercent;

//				float aspect = _imagesize.width / _imagesize.height;
//				if( (_imagesize.width + (fHowFar*aspect)) < kMinScale ){
//					_imagesize.width = kMinScale;
//					_imagesize.height = kMinScale/aspect;
//				}
//				else if( kMinScale*2 < (_imagesize.width + (fHowFar*aspect)) ){
//					_imagesize.width = kMinScale*2;
//					_imagesize.height = kMinScale*2/aspect;
//				}
//				else{
//					_imagesize.width += fHowFar*aspect ;
//					_imagesize.height += fHowFar/aspect;
//				}
//				_fCurrentPercent = _imagesize.width / kMinScale;

				if( _fCurrentPercent < MIN_SCALE ) _fCurrentPercent = MIN_SCALE;
				else if( MAX_SCALE < _fCurrentPercent ) _fCurrentPercent = MAX_SCALE;

				_imagesize.width = _oimagesize.width * _fCurrentPercent;
				_imagesize.height = _oimagesize.height * _fCurrentPercent;

				[self resizeImage];
//			}
			//現在の2本指の距離を保存する
			_fDistancePrev = fDistance;
		}
		// ズームする場合はここで終了
		if(_bZooming) return;
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
	return prefData.SwipeSlide;
}

/******************************/
/* スワイプ操作               */
/******************************/
- (int)swipe: (int)orientation withEvent: (GSEventRef)event
{
	int next=0;
	switch(_orient){
	case 1:		//正面 0°
		if( orientation == 8 )		next = NEXT_PAGE;
		else if( orientation == 4 )	next = PREV_PAGE;
		break;
	case 2:		//180°
		if( orientation == 4 )		next = NEXT_PAGE;
		else if( orientation == 8 )	next = PREV_PAGE;
		break;
	case 3:		//左 90°
		if( orientation == 2 )		next = NEXT_PAGE;
		else if( orientation == 1 )	next = PREV_PAGE;
		break;
	case 4:		//右 270°
		if( orientation == 1 )		next = NEXT_PAGE;
		else if( orientation == 2 )	next = PREV_PAGE;
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

/************************************/
/* オリジナルの画像サイズを保存する */
/************************************/
- (void) setOrgImageSize: (CGSize) imagesize
{
	_oimagesize = imagesize;
}

@end
