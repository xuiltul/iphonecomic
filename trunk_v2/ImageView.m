#import "ImageView.h"
#import "Global.h"

#define ERR_SIZE_VIEW @"/Applications/iComic.app/errsize.png"
#define ERR_ZIP_VIEW @"/Applications/iComic.app/errzip.png"
#define ERR_FORMAT_VIEW @"/Applications/iComic.app/errformat.png"

int tap_count;

@implementation ImageView
- (id)initWithFrame:(struct CGRect)frame
{
	CGRect screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin = CGPointZero;
	screct.size.height += STSBAR;

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
	
	[_scroller2 setRubberBand: 50 forEdges:0];
	[_scroller2 setRubberBand: 50 forEdges:1];
	[_scroller2 setRubberBand: 50 forEdges:2];
	[_scroller2 setRubberBand: 50 forEdges:3];
	[_scroller2 setDelegate:self];
	[_scroller2 setScrollDelegate : self];
	
	[self setScroll:NO decelerationFactor:prefData.ScrollSpeed];

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
	tap_count = 0;
	
	return self;
}

float averagex = 0;
int cnt = 0;
bool flag1 = false;
bool flag2 = false;

-(void) gravity: (float)x  gy:(float) y gz:(float)z
{
	if(prefData.GravitySlide == NO) return;
//	if(IsViewingComic == 0) return;
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
//char aaaa[256];
	int dirpos;
	_currentpos = 0;
	//開いてたら閉じる
	if(zipfile != 0) unzClose(zipfile);
//	NSLog(@"hoge");
//debug_log("hoge\n");

	//まずは開いて初めのファイルへ.
	char buf[MAXPATHLEN];
	[fname getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	[fname getCString: _filenamebuf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
//
//debug_log("buf\n");

	zipfile = unzOpen(buf);

//debug_log("buf a\n");

	unzGoToFirstFile(zipfile);

//debug_log("buf b\n");

	//情報リストを作らないと。
	int ret = 0;
	NSArray *extensions = [NSArray arrayWithObjects:@"jpe",@"jpg",@"jpeg",@"tif",@"tiff",@"png",@"gif",@"bmp",@"img",nil];
	unz_global_info ugi;

//debug_log("buf c\n");

	unzGetGlobalInfo(zipfile, &ugi);

//debug_log("buf d\n");

//	NSLog(@"%d", ugi.number_entry);
	if(filenamelist != nil){
		[filenamelist release];
	}
	filenamelist = [[NSMutableArray alloc] initWithCapacity: ugi.number_entry];
	while(ret == 0){
//debug_log("buf d2\n");
		unz_file_info ufi;
		unzGetCurrentFileInfo (zipfile, &ufi, buf, MAXPATHLEN, 0, 0, 0, 0);
		if(ufi.uncompressed_size == 0){
			ret = unzGoToNextFile(zipfile);
//debug_log("buf e\n");
//aaaa
			continue;
		}
//debug_log("buf e2\n");
//		for( dirpos = strlen(buf)-1; dirpos > 0; dirpos-- ){
//sprintf(aaaa, "dirpos %d %c\n", dirpos, buf[dirpos]);
//debug_log(aaaa);
//			if( buf[dirpos] == '/' ){
//debug_log("buf e3\n");
//				break;
//			}
//		}
//sprintf(aaaa, "dirpos %d\n", dirpos);
//debug_log(aaaa);
//sprintf(aaaa, "%s\n", buf);
//debug_log(aaaa);
//		if( (dirpos != 0) && (buf[dirpos+1] == '.') ){
//			ret = unzGoToNextFile(zipfile);
//sprintf(aaaa, "e4 %d\n", ret);
//debug_log(aaaa);
//			if( ret != 0 ){
//				ret = unzGoToNextFile(zipfile);
//sprintf(aaaa, "e42 %d\n", ret);
//debug_log(aaaa);
//			}
//			continue;
//		}

//		if(buf[0] == '.'){
//debug_log("buf f\n");
//			continue;
//		}
//debug_log("buf g\n");
//sprintf(aaaa, "%s\n", buf);
//debug_log(aaaa);

		NSString *temp = [NSString stringWithCString: buf encoding:NSShiftJISStringEncoding];
//NSLog(temp);
		if(temp == nil){
			ret = unzGoToNextFile(zipfile);
//sprintf(aaaa, "g2 %d\n", ret);
//debug_log(aaaa);
			continue;
		}
//debug_log("buf h\n");

		NSString *extension = [[temp pathExtension] lowercaseString];
		if([extensions containsObject:extension]){
//NSLog(@"add");
			[filenamelist addObject:temp];
		}

//debug_log("buf i\n");

		ret = unzGoToNextFile(zipfile);
//sprintf(aaaa, "j %d\n", ret);
//debug_log(aaaa);
	}
//debug_log("buf end\n");
	
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
NSLog(@"nextFile");

//	[_currentscroll addSubview: _progressIndicator];
//	[_progressIndicator startAnimation];

	_currentpos++;
	if(_currentpos >= [filenamelist count]){
NSLog(@"nextFile end");
		SetPageData(_filenamebuf, -1);
		isShowImage = YES;
		[self dofileEnd];
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile:(prefData.ToKeepScale==YES)] == 1){
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
NSLog(@"prevFile %d",_currentpos);

	_currentpos--;
	if(_currentpos < 0){
NSLog(@"prevFile end");
		[self dofileEnd];
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile:(prefData.ToKeepScale==YES)] == 1){
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

	[super dealloc];
}

/******************************/
/* ページデータの読み込み     */
/******************************/
-(int)reloadFile
{
//NSLog(@"reloadFile");

	int ret = [self reloadFile:(prefData.ToKeepScale==YES)];
	if( ret == 0 ){
		if(prefData.ToScrollRightTop)
			[_currentscroll scrollToTopRight];		//右上に移動
		else{
			[_currentscroll setOffsetFit:statData.offset];
		}
	}
	else{
//		NSLog(@"nil image! 2");
		[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reloadFile_end:) userInfo:self repeats:NO];
//		[self dofileEnd];
	}
	return ret;
}

-(void)reloadFile_end:(NSTimer*)timer
{
	[self dofileEnd];
}

-(int)reloadFile:(bool)flag
{
//NSLog(@"image view reloadFile=%d",_orient);
	UIImage* nimage = nil;

	if(1){		//ZIP用
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		if(zipfile == 0)
			return -1;
		if( (_currentpos < 0) || (_currentpos > [filenamelist count]) ){
			_currentpos = 0;
		}
		char namebuf[MAXPATHLEN];
		//現在のファイル名読み込み
		[[filenamelist objectAtIndex: _currentpos] getCString: namebuf maxLength:MAXPATHLEN encoding:NSShiftJISStringEncoding];
		if(unzLocateFile(zipfile, namebuf, 0) != 0){
			//ファイル終端
			return -1;
		}
		if(zipfile == 0){
			return -1;
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		unz_file_info ufi;
		unzGetCurrentFileInfo(zipfile, &ufi, 0, 0, 0, 0, 0, 0);
		//指定サイズ以上はあきらめる
		if(ufi.uncompressed_size < psysData.ZipSkipSize){
			char* buf = (char*)malloc(ufi.uncompressed_size + 128);
			unzOpenCurrentFile(zipfile);
			int read = unzReadCurrentFile(zipfile, buf, ufi.uncompressed_size);
			unzCloseCurrentFile(zipfile);
			nimage = [[UIImage alloc] initWithData:[NSData dataWithBytes:buf length:read] cache: true];
			free(buf);
		}
		else{
			nimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:ERR_SIZE_VIEW] cache: true];
		}
	}
	else{		//File用
		/////////////////////////////////////////////////////////////////////////////////////////////////////
//		ndata = [NSData dataWithContentsOfFile:@"/Applications/ComicViewer.app/errzip.png"];
		nimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:ERR_SIZE_VIEW] cache: true];
	}
	//画像が読めない場合は、エラー表示にすり替え
	if(nimage == nil){
		NSLog(@"nil image!");
		[nimage release];
		nimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:ERR_FORMAT_VIEW] cache: true];
	}
	CGSize loadimage = [nimage size];
	CGSize resize = CGSizeZero;

//NSLog(@"Image(%f,%f)",loadimage.width,loadimage.height);
	//画像サイズオーバーの場合は、エラー表示にすり替え
	if( psysData.ImgSkipSize < (loadimage.width*loadimage.height) ){
		NSLog(@"max image!");
		[nimage release];
		nimage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:ERR_SIZE_VIEW] cache: true];
		loadimage = [nimage size];
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//画面サイズに最適化
	CGSize resizefit = [_currentscroll calcFitImage:loadimage];
	//拡大率を指定する場合
	if( flag && (statData.ZoomRate > 0) ){
		resizefit.width *= statData.ZoomRate;
		resizefit.height *= statData.ZoomRate;
	}
	else{
		statData.ZoomRate = 1;
	}
	resize = [self resizeMaxImage:resizefit];

	//リサイズする
	int Flag = 0;
	if( (resize.width > 0) && (resize.height > 0) ){
		//端数を切り捨てる
		resize.width = (int)resize.width;	
		resize.height = (int)resize.height;	

		unsigned char *bitmap = malloc(resize.width * resize.height * sizeof(unsigned char) * 2);
		CGContextRef bitmapContext;
		bitmapContext = CGBitmapContextCreate(bitmap,	resize.width, resize.height, 5, resize.width * 2,
							CGColorSpaceCreateDeviceRGB(),
							kCGImageAlphaNoneSkipFirst);
		CGContextDrawImage (bitmapContext, CGRectMake(0,0,resize.width,resize.height), [nimage imageRef]);
		[nimage release];
		CGImageRef *cgImage = CGBitmapContextCreateImage(bitmapContext);
		free(bitmap);
		nimage = [[UIImage alloc] initWithImageRef: cgImage];

		CGContextRelease(bitmapContext);
		Flag = 1;
	}

	[_currentscroll setImageFromImage: nimage withFlag:Flag];
	[_currentscroll fitRect:flag];
	[_currentscroll resizeImage];			//リサイズする
//	isShowImage = YES;
	
	return 0;
}

//BOOL isDoing = NO;
/******************************/
/* 前のページに移動           */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll filePrev: (id) hoge
{
	if( tap_count == 0 ){
		tap_count++;
		return;
	}
	if( tap_count > 1 ){
		tap_count = 0;
//		return;
	}

//	if(isDoing){
////NSLog(@"scrollImage");
//		return;
//	}
//	
//	isDoing = YES;
//	CGPoint pt = [_currentscroll offset];
	statData.offset = [_currentscroll offset];

	if(_currentscroll == _scroller1){
		_currentscroll = _scroller2;
	}
	else{
		_currentscroll = _scroller1;
	}

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

	if(prefData.ToScrollRightTop)
		[_currentscroll scrollToTopRight];
	else{
		[_currentscroll setOffsetFit:statData.offset];
	}
//	isDoing = NO;
	tap_count = 0;
	return;
}

/******************************/
/* 次のページに移動           */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll fileNext: (id) hoge
{
	if( tap_count == 0 ){
		tap_count++;
		return;
	}
	if( tap_count > 1 ){
		tap_count = 0;
//		return;
	}

//	if(isDoing){
////NSLog(@"scrollImage");
//		 return;
//	}
//
//	isDoing = YES;
	statData.offset = [_currentscroll offset];

	if(_currentscroll == _scroller1){
		_currentscroll = _scroller2;
	}
	else{
		_currentscroll = _scroller1;
	}

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

	if(prefData.ToScrollRightTop)
		[_currentscroll scrollToTopRight];
	else{
		[_currentscroll setOffsetFit:statData.offset];
	}
//	isDoing = NO;
	tap_count = 0;
	return;
}

/******************************/
/* ページの読み直し           */
/******************************/
- (void)scrollImage: (ScrollImage *)scroll fileNow: (id) hoge
{
//	if(isDoing){
////NSLog(@"scrollImage");
//		 return;
//	}
//	
//	isDoing = YES;
	statData.offset = [_currentscroll offset];

	if(_currentscroll == _scroller1){
		_currentscroll = _scroller2;
	}
	else{
		_currentscroll = _scroller1;
	}

	[_transition transition:0 toView:_currentscroll];

//	[self reloadFile:true];
	[self reloadFile:(prefData.ToKeepScale==YES)];
	[_currentscroll setOffsetFit:statData.offset];

//	isDoing = NO;
	return;
}

/******************************/
/*                            */
/******************************/
-(void) setOrientation:(int)orientation
{
	if( (_orient == orientation) || (orientation == 0) || (orientation >= 5) ) return;

	_orient = orientation;

	[_scroller1 setOrientation:orientation];
	[_scroller2 setOrientation:orientation];
	
	[_currentscroll setOrientZoom];

	if(_currentpos < 0) return;
	
	if( prefData.ReloadScreen ){
		[_currentscroll goNextPage:RELD_PAGE];
	}
	else{
		[_currentscroll fitRect];
		[_currentscroll resizeImage];
	}
	[_currentscroll scrollToTopRight];
}

/******************************/
/*                            */
/******************************/
- (void)dofileEnd
{
//NSLog(@"dofileEnd");
	if([_fileDelegate respondsToSelector:@selector(imageView:fileEnd:)]){
		[_fileDelegate imageView:self fileEnd:self];
		_currentpos = -1;
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
-(CGSize) resizeMaxImage:(CGSize)image
{
	CGSize rImage = CGSizeZero;

	if( (image.width > psysData.ImgSkipLen) || (image.height > psysData.ImgSkipLen) ){
		float aspect = image.width / image.height;
		if(image.width > image.height){
			rImage.width = psysData.ImgResizeLen;
			rImage.height = psysData.ImgResizeLen / aspect;
		}
		else{
			rImage.width = psysData.ImgResizeLen * aspect;
			rImage.height = psysData.ImgResizeLen;
		}
	}
	else{
		rImage = image;
	}
	return rImage;
}

/******************************/
/*                            */
/******************************/
-(void) scrollToTopRightTmp
{
	[_currentscroll scrollToTopRight];
}

@end
