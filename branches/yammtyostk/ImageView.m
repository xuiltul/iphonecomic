#import "ImageView.h"
#import "Global.h"

#define MAX_IMAGE  (1390.0f)
#define MAX_RESIZE (1000.0f)

@implementation ImageView
- (id)initWithFrame:(struct CGRect)frame
{
	CGRect screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin = CGPointZero;

	[super initWithFrame: frame];
	_scroller1 = [[ScrollImage alloc] initWithFrame: frame];
	[_scroller1 setScrollingEnabled:YES];
	[_scroller1 setShowScrollerIndicators:YES];
	[_scroller1 displayScrollerIndicators];
	[_scroller1 setAdjustForContentSizeChange:YES];
	
	[_scroller1 setRubberBand: 50 forEdges:0];
	[_scroller1 setRubberBand: 50 forEdges:1];
	[_scroller1 setRubberBand: 50 forEdges:2];
	[_scroller1 setRubberBand: 50 forEdges:3];
	[_scroller1 setDelegate:self];
	[_scroller1 setScrollDelegate : self];

	_scroller2 = [[ScrollImage alloc] initWithFrame: frame];
	[_scroller2 setScrollingEnabled:YES];
	[_scroller2 setShowScrollerIndicators:YES];
	[_scroller2 displayScrollerIndicators];
	[_scroller2 setAdjustForContentSizeChange:YES];
	
	[_scroller2 setRubberBand: 10 forEdges:0];
	[_scroller2 setRubberBand: 10 forEdges:1];
	[_scroller2 setRubberBand: 10 forEdges:2];
	[_scroller2 setRubberBand: 10 forEdges:3];
	[_scroller2 setDelegate:self];
	[_scroller2 setScrollDelegate : self];
	
	[self setScroll: prefData.IsScroll decelerationFactor: prefData.ScrollSpeed];

/*
	struct CGSize progsize = [UIProgressIndicator defaultSizeForStyle:0];
	_progressIndicator = [[UIProgressIndicator alloc] 
			  initWithFrame:CGRectMake((320-progsize.width)/2,
						   (460-progsize.height)/2,
						   progsize.width, 
						   progsize.height)];
	[_progressIndicator setStyle:0];
*/
	_transition = [[UITransitionView alloc] initWithFrame:screct];
	[_transition setDelegate:self];

	_currentscroll = _scroller1;
	[self addSubview: _transition];
	[_transition transition:0 toView:_currentscroll];
	zipfile = 0;
	_orient = 1;
	_currentsize = 0;

	return self;
}

float averagex = 0;
int cnt = 0;
bool flag1 = false;
bool flag2 = false;

-(void) gravity: (float)x  gy:(float) y gz:(float)z
{
	if(prefData.GravitySlide == NO) return;
	if(IsViewingComic == 0) return;
	float threshold1 = 0.1f;
	float threshold2 = 0.05f;
	float hogaa = 20;
	averagex = averagex * (hogaa - 1) / hogaa + x / hogaa;
//	NSLog(@"%f, %f", averagex, x);
	cnt++;
	if(cnt < 20) return;
	float dist = averagex - x;
	
	if(dist < -threshold1 && flag1 == false && flag2 == false){
		flag1 = true;
		NSLog(@"next");
	}
	if(dist > threshold1 && flag2 == false && flag1 == false){
		flag2 = true;
		NSLog(@"prev");
	}
	if(flag1 == true && fabs(dist) < threshold2){
		NSLog(@"next2");
		[self scrollImage: nil fileNext: nil];
		flag1 = false;
	}
	if(flag2 == true && fabs(dist) < threshold2){
		NSLog(@"prev2");
		[self scrollImage: nil filePrev: nil];		
		flag2 = false;
	}

//	NSLog(@"%f %f %f", x, y, z);
//	[_currentscroll scrollByDelta: CGSizeMake(-x * 10, -y * 10) animated:NO];
//	[_currentscroll scrollByDelta: CGSizeMake(1, 1) animated:NO];
}

-(void) setScroll:(BOOL) flag decelerationFactor:(float)dec
{
	[_scroller1 setAllowsRubberBanding:flag];
	[_scroller1 setAllowsFourWayRubberBanding:flag];
	[_scroller2 setAllowsRubberBanding:flag];
	[_scroller2 setAllowsFourWayRubberBanding:flag];
		
	float t = 1 - ((101 - dec) / 2000);

	[_scroller1 setScrollDecelerationFactor: t];
	[_scroller2 setScrollDecelerationFactor: t];
}

/******************************/
/*                            */
/******************************/
-(void)setFile: (NSString*) fname
{
	_currentpos = 0;
	//開いてたら閉じる
	if(zipfile != 0) unzClose(zipfile);
//	NSLog(@"hoge");
	//まずは開いて初めのファイルへ.
	char buf[MAXPATHLEN];
	[fname getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	[fname getCString: _filenamebuf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	zipfile = unzOpen(buf);
	unzGoToFirstFile(zipfile);

	//情報リストを作らないと。
	int ret = 0;
	unz_global_info ugi;
	unzGetGlobalInfo(zipfile, &ugi);

//	NSLog(@"%d", ugi.number_entry);
	if(filenamelist != nil){
		[filenamelist release];
	}
	filenamelist = [[NSMutableArray alloc] initWithCapacity: ugi.number_entry];
	while(ret == 0){
		unz_file_info ufi;
		unzGetCurrentFileInfo (zipfile, &ufi, buf, MAXPATHLEN, 0, 0, 0, 0);
		if(ufi.uncompressed_size == 0){
			ret = unzGoToNextFile(zipfile);
			 continue;
		}
		NSString *temp = [NSString stringWithCString: buf encoding:NSShiftJISStringEncoding];
//	NSLog(temp);
		if(temp != nil){
			[filenamelist addObject:temp];
		}
		ret = unzGoToNextFile(zipfile);
	}
	
	[filenamelist sortUsingSelector: @selector (compare:)];
}

/******************************/
/*                            */
/******************************/
-(void) setPage : (int) page
{
	if(page < 0) page = 0;
	_currentpos = page;
}

/******************************/
/*                            */
/******************************/
-(void)nextFile
{
//	[_currentscroll addSubview: _progressIndicator];
//	[_progressIndicator startAnimation];

	_currentpos++;
	if(_currentpos >= [filenamelist count]){
		[self dofileEnd];
		SetPageData(_filenamebuf, -1);
		//RemovePageData(_filenamebuf);
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile] == 1){
		[self nextFile];
	}
//	[_progressIndicator stopAnimation];
//	[_progressIndicator removeFromSuperview];
}

/******************************/
/*                            */
/******************************/
-(void)prevFile
{
	_currentpos--;
	if(_currentpos < 0){
		[self dofileEnd];
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile] == 1){
		[self prevFile];
	}
}

/******************************/
/*                            */
/******************************/
-(void) dealloc
{
	[_scroller1 release];
	[_scroller2 release];
	[filenamelist release];
	[_transition release];
}

/******************************/
/* ページデータの読み込み     */
/******************************/
-(int)reloadFile
{
	if(zipfile == 0) return -1;
	if( (_currentpos < 0) || (_currentpos > [filenamelist count]) ){
		[self dofileEnd];
		return -1;
	}
	char namebuf[MAXPATHLEN];
	//現在のファイル名読み込み
	[[filenamelist objectAtIndex: _currentpos] getCString: namebuf maxLength:MAXPATHLEN encoding:NSShiftJISStringEncoding];
	if(unzLocateFile(zipfile, namebuf, 0) != 0){
		[self dofileEnd];
		//ファイル終端
		return -1;
	}

	if(zipfile == 0) return;
	unz_file_info ufi;
	unzGetCurrentFileInfo(zipfile, &ufi, 0, 0, 0, 0, 0, 0);
	//2MB以上はあきらめる
	if(ufi.uncompressed_size > 1024 * 1024 * 2) return;

	char* buf = (char*)malloc(ufi.uncompressed_size + 128);
	unzOpenCurrentFile(zipfile);
	int read = unzReadCurrentFile(zipfile, buf, ufi.uncompressed_size);
	unzCloseCurrentFile(zipfile);

	int Flag = 0;
	///ファイルの解凍までは完全にできてるっぽい
	UIImage* nimage = [[UIImage alloc] initWithData: [NSData dataWithBytes:buf length:read] cache: true];
	if(nimage == nil){
		NSLog(@"nil image!");
		return 1;
	}

	CGSize loadimage = [nimage size];
	CGSize resize = CGSizeZero;

	//画面サイズに最適化
	if( prefData.ToFitScreen ){
		CGSize resizefit = [_currentscroll calcFitImage:loadimage];

		//拡大率を指定する場合
		if( (prefData.ToKeepScale == YES) && (_currentsize > 0) ){
			resizefit.width *= _currentsize;
			resizefit.height *= _currentsize;
		}
		else{
			_currentsize = 1;
		}
		resize = [self resizeMaxImage: resizefit: true];
	}
	else{
		//画像が大きすぎる場合
		resize = [self resizeMaxImage: loadimage: false];
	}

	//リサイズする
	if( (resize.width > 0) && (resize.height > 0) ){
		//端数を切り捨てる
		resize.width = (int)resize.width;	
		resize.height = (int)resize.height;	

		unsigned char *bitmap = malloc(resize.width * resize.height * sizeof(unsigned char) * 4);
		CGContextRef bitmapContext;
		bitmapContext = CGBitmapContextCreate(bitmap,	resize.width, resize.height, 8, resize.width * 4,
							CGColorSpaceCreateDeviceRGB(),
							kCGImageAlphaPremultipliedFirst);
		CGContextDrawImage (bitmapContext, CGRectMake(0,0,resize.width,resize.height), [nimage imageRef]);
		CGImageRef *cgImage = CGBitmapContextCreateImage(bitmapContext);
	
		[nimage release];
		nimage = [[UIImage alloc] initWithImageRef: cgImage];
	
		free(bitmap);
		CGContextRelease(bitmapContext);
		Flag = 1;
	}

	[_currentscroll setImageFromImage: nimage withFlag:Flag];
	free(buf);

	return 0;
}

/******************************/
/* 画面に合わせる             */
/******************************/
- (void) fitImage
{
	[_currentscroll fitRect];
	[_currentscroll resizeImage];			//リサイズする
	[_currentscroll scrollToTopRight];		//右上に移動
}

BOOL isDoing = NO;

/******************************/
/* 前のページに移動           */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll filePrev: (id) hoge
{
	if(isDoing) return;

	isDoing = YES;
	CGPoint pt = [_currentscroll offset];
	_currentsize = [_currentscroll getPercent];

	if(_currentscroll == _scroller1)
		_currentscroll = _scroller2;
	else
		_currentscroll = _scroller1;

	int trans = 0;
	switch(_orient){
	case 1:		//正面 0°
		trans = (prefData.SlideRight? 1: 2);
		break;
	case 2:		//180°
		trans = (prefData.SlideRight? 2: 1);
		break;
	case 3:		//左 90°
		trans = (prefData.SlideRight? 3: 7);
		break;
	case 4:		//右 270°
		trans = (prefData.SlideRight? 7: 3);
		break;
	}
	[_transition transition:trans toView:_currentscroll];

	[self prevFile];	//前のページを読み込む

	if(prefData.ToKeepScale)
		 [_currentscroll setPercent: _currentsize];

	[_currentscroll fitRect];
	[_currentscroll resizeImage];

	if(prefData.ToScrollRightTop)
		[_currentscroll scrollToTopRight];
	else{
		[_currentscroll setOffset:pt];
	}
	isDoing = NO;
	return;
}

/******************************/
/* 次のページに移動           */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll fileNext: (id) hoge
{
	if(isDoing) return;

	isDoing = YES;
	CGPoint pt = [_currentscroll offset];
	_currentsize = [_currentscroll getPercent];

	if(_currentscroll == _scroller1)
		_currentscroll = _scroller2;
	else
		_currentscroll = _scroller1;

	int trans = 0;
	switch(_orient){
	case 1:		//正面 0°
		trans = (prefData.SlideRight? 2: 1);
		break;
	case 2:		//180°
		trans = (prefData.SlideRight? 1: 2);
		break;
	case 3:		//左 90°
		trans = (prefData.SlideRight? 7: 3);
		break;
	case 4:		//右 270°
		trans = (prefData.SlideRight? 3: 7);
		break;
	}
	[_transition transition:trans toView:_currentscroll];

	[self nextFile];	//次のページを読み込む

	if(prefData.ToKeepScale)
		[_currentscroll setPercent: _currentsize];

	[_currentscroll fitRect];
	[_currentscroll resizeImage];

	if(prefData.ToScrollRightTop)
		[_currentscroll scrollToTopRight];
	else{
		[_currentscroll setOffset:pt];
	}
	isDoing = NO;
	return;
}

/******************************/
/*                            */
/******************************/
-(void) setOrientation: (int) orientation
{
	if( (1 <= orientation) && (orientation <= 4) )
		_orient = orientation;
	if(_currentscroll == _scroller1){
		[_scroller1 setOrientation: orientation animate:true];
		[_scroller2 setOrientation: orientation animate:false];
	}
	else{
		[_scroller1 setOrientation: orientation animate:false];
		[_scroller2 setOrientation: orientation animate:true];
	}
}

/******************************/
/*                            */
/******************************/
- (void)dofileEnd
{
	if([_fileDelegate respondsToSelector:@selector(imageView:fileEnd:)]){
		[_fileDelegate imageView:self fileEnd:self];
		return;
	}
}

/******************************/
/* 終了動作                   */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll fileEnd: (id) hoge
{
	[self dofileEnd];	
}

/******************************/
/* メソッドを引き継ぐ         */
/******************************/
-(void) setImageDelegate: (id) dele
{
	_fileDelegate = dele;
}

/******************************/
/*                            */
/******************************/
-(CGSize) resizeMaxImage: (CGSize) image: (bool) flag
{
	CGSize rImage = CGSizeZero;

	if( (image.width > MAX_IMAGE) || (image.height > MAX_IMAGE) ){
		float aspect = image.width / image.height;
		if(image.width > image.height){
			rImage.width = MAX_RESIZE;
			rImage.height = MAX_RESIZE / aspect;
		}
		else{
			rImage.width = MAX_RESIZE * aspect;
			rImage.height = MAX_RESIZE;
		}
	}
	else if(flag){
		rImage = image;
	}
	return rImage;
}

@end
