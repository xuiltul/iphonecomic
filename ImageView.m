#import "ImageView.h"
#define MAXPATHLEN 512
#import "Global.h"

@implementation ImageView
- (id)initWithFrame:(struct CGRect)frame
{
	struct CGRect screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin.x = screct.origin.y = 0;
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
	[_scroller1 setMouseDelegate : self];
	[_scroller1 setDelegate:self];
	[_scroller1 setMouseDelegate:self];
	

	
	_scroller2 = [[ScrollImage alloc] initWithFrame: frame];
	[_scroller2 setScrollingEnabled:YES];
	[_scroller2 setShowScrollerIndicators:YES];
	[_scroller2 setAdjustForContentSizeChange:YES];
	[_scroller2 displayScrollerIndicators];
	[_scroller2 setAdjustForContentSizeChange:YES];
	
	[_scroller2 setRubberBand: 10 forEdges:0];
	[_scroller2 setRubberBand: 10 forEdges:1];
	[_scroller2 setRubberBand: 10 forEdges:2];
	[_scroller2 setRubberBand: 10 forEdges:3];
	[_scroller2 setMouseDelegate : self];
	[_scroller2 setDelegate:self];
	[_scroller2 setMouseDelegate:self];
	
	[self setScroll: prefsData.IsScroll decelerationFactor: prefsData.ScrollSpeed];


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
	return self;
}

-(void) gravity: (int)x  gy:(int) y gz:(int)z
{
//	NSLog(@"%f %f %f", x, y, z);
	[_currentscroll scrollByDelta: CGSizeMake(-x * 100, -y * 100) animated:NO];
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
	
	if(filenamelist != nil)
	{
		[filenamelist release];
	}
	filenamelist = [[NSMutableArray alloc] initWithCapacity: ugi.number_entry];
	while(ret == 0)
	{
		unz_file_info ufi;
		unzGetCurrentFileInfo (zipfile, &ufi, buf, MAXPATHLEN, 0, 0, 0, 0);
		if(ufi.uncompressed_size == 0)
		{
			ret = unzGoToNextFile(zipfile);
			 continue;
		}
		NSString *temp = [NSString stringWithCString: buf encoding:NSShiftJISStringEncoding];
	//	NSLog(temp);
		if(temp != nil) 
		{
			[filenamelist addObject:temp];
		}
		ret = unzGoToNextFile(zipfile);
	}
	
	[filenamelist sortUsingSelector: @selector (compare:)];
}

-(void) setPage : (int) page
{
	if(page < 0) page = 0;
	_currentpos = page;
}

-(void)nextFile
{
//	[_currentscroll addSubview: _progressIndicator];
//	[_progressIndicator startAnimation];

	_currentpos++;
	if(_currentpos >= [filenamelist count])
	{
		[self dofileEnd];
		SetPageData(_filenamebuf, -1);
		//RemovePageData(_filenamebuf);
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile] == 1)
	{
		[self nextFile];
	}
//	[_progressIndicator stopAnimation];
//	[_progressIndicator removeFromSuperview];
}

-(void)prevFile
{
	_currentpos--;
	if(_currentpos < 0)
	{
		[self dofileEnd];
		return;
	}
	SetPageData(_filenamebuf, _currentpos);
	if([self reloadFile] == 1)
	{
		[self prevFile];
	}
}

-(void) dealloc
{
	[_scroller1 release];
	[_scroller2 release];
	[filenamelist release];
	[_transition release];
}

-(int)reloadFile
{
	if(_currentpos < 0 || _currentpos > [filenamelist count]) 
	{
		[self dofileEnd];
		return -1;
	}
	char namebuf[MAXPATHLEN];
	//現在のファイル名読み込み
	[[filenamelist objectAtIndex: _currentpos] getCString: namebuf maxLength:MAXPATHLEN encoding:NSShiftJISStringEncoding];
	if(unzLocateFile(zipfile, namebuf, 0) != 0)
	{
		[self dofileEnd];
		//ファイル終端
		return -1;
	}
	
	if(zipfile == 0) return;
	unz_file_info ufi;
	unzGetCurrentFileInfo(zipfile, &ufi, 0, 0, 0, 0, 0, 0);
	//2MB以上はあきらめる
	if(ufi.uncompressed_size > 1024 * 1024 * 2) return;

	char *buf = (char*)malloc(ufi.uncompressed_size + 128);
	unzOpenCurrentFile(zipfile);
	int read = unzReadCurrentFile(zipfile, buf, ufi.uncompressed_size);
	unzCloseCurrentFile(zipfile);

	int Flag = 0;
	///ファイルの解凍までは完全にできてるっぽい
	UIImage * nimage = [[UIImage alloc] initWithData: [NSData dataWithBytes:buf length:read] cache: true];
	if(nimage == nil)
	{
		return 1;
	}
	//resizeする？
	toResize = false;
	CGSize frame = [nimage size];
	NSLog(@"%x  %f,%f", nimage, frame.width, frame.height);

	float aspectr = (frame.width / frame.height) / (_imagesize.width / _imagesize.height);
	float wr = frame.width / _imagesize.width;
	float hr = frame.height / _imagesize.height;
	if(aspectr < 0.95 || aspectr > 1.05 || 
	wr < 0.95 || wr > 1.05 || 
	hr < 0.95 || hr > 1.05) toResize = true;
	_imagesize = frame;
	
	//画像が大きすぎるときの処理
	int ret = 0;
	if((frame.width > 1390.0f || frame.height > 1390.0f) && prefsData.ToResizeImage == YES)
	{
		int width = frame.width, height = frame.height;
		float aspect = (float)width / (float)height;
		if(width > height)
		{
			width = 1000;
			height = width / aspect;
		}
		else
		{
			height = 1000;
			width = height * aspect;
		}
	
		unsigned char *bitmap = malloc(width * height * sizeof(unsigned char) * 4);
		CGContextRef bitmapContext;
		bitmapContext = CGBitmapContextCreate(bitmap,	width, height, 8, width * 4,
							CGColorSpaceCreateDeviceRGB(),
							kCGImageAlphaPremultipliedFirst);
		CGContextDrawImage (bitmapContext, CGRectMake(0,0,width,height), [nimage imageRef]);
		CGImageRef *cgImage = CGBitmapContextCreateImage(bitmapContext);
		//CIImage *aCIImage =  [CIImage imageWithCGImage:cgImage];

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

- (void) fitImage
{
	[_currentscroll fitRect];
}

BOOL isDoing = NO;


- (void)scrollImage: (ScrollImage *)scroll filePrev: (id) hoge
{
	if(isDoing) return;
	isDoing = YES;
	_currentsize = [_currentscroll getPercent];
	if(_currentscroll == _scroller1) _currentscroll = _scroller2; else _currentscroll = _scroller1;
	int trans = 0;
	switch(_orient)
	{
		//ふつう
		case 1:
			if(prefsData.SlideDirection) trans = 2;
			else trans = 1;
			break;
		//逆
		case 2:
			if(prefsData.SlideDirection) trans = 1;
			else trans = 2;
			break;
		//左
		case 3:
			if(prefsData.SlideDirection) trans = 7;
			else trans = 3;
			break;
		//右
		case 4:
			if(prefsData.SlideDirection) trans = 3;
			else trans = 7;
			break;
	}
	[_transition transition:trans toView:_currentscroll];


	[self prevFile]; 
	if(prefsData.ToKeepScale  && toResize == false) [_currentscroll setPercent: _currentsize];
	else [_currentscroll fitRect];
	if(prefsData.ToScrollRightTop)[_currentscroll scrollToTopRight];
	isDoing = NO;
	return;
}

- (void)scrollImage: (ScrollImage *)scroll fileNext: (id) hoge
{
	if(isDoing) return;
	isDoing = YES;

	_currentsize = [_currentscroll getPercent];
	if(_currentscroll == _scroller1) _currentscroll = _scroller2; else _currentscroll = _scroller1;
	int trans = 0;
	switch(_orient)
	{
		//ふつう
		case 1:
			if(prefsData.SlideDirection) trans = 1;
			else trans = 2;
			break;
		//逆
		case 2:
			if(prefsData.SlideDirection) trans = 2;
			else trans = 1;
			break;
		//左
		case 3:
			if(prefsData.SlideDirection) trans = 3;
			else trans = 7;
			break;
		//右
		case 4:
			if(prefsData.SlideDirection) trans = 7;
			else trans = 3;
			break;
	}
	[_transition transition:trans toView:_currentscroll];

	
	[self nextFile];
	if(prefsData.ToKeepScale && toResize == false)
	{
		[_currentscroll setPercent: _currentsize];
	}
	else
	{
		[_currentscroll fitRect];
	}
	if(prefsData.ToScrollRightTop)[_currentscroll scrollToTopRight];
	isDoing = NO;
	return;
}


-(void) setOrientation: (int) orientation
{
	if(orientation >= 1 && orientation <= 4) _orient = orientation;
	if(_currentscroll == _scroller1)
	{
		[_scroller1 setOrientation: orientation animate:true];
		[_scroller2 setOrientation: orientation animate:false];
	}
	else
	{
		[_scroller1 setOrientation: orientation animate:false];
		[_scroller2 setOrientation: orientation animate:true];
	}
}

- (void)dofileEnd
{
	if([_fileDelegate respondsToSelector:@selector(imageView:fileEnd:)])
	{
		[_fileDelegate imageView:self fileEnd:self];
		return;
	}
}

- (void)scrollImage: (ScrollImage *)scroll fileEnd: (id) hoge
{
	[self dofileEnd];	
}


-(void) setFileDelegate: (id) dele
{
	_fileDelegate = dele;
}


@end




