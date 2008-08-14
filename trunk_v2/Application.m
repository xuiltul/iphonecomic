/* 
	Kokusi App
*/

#import <stdio.h>
#import "Application.h"
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>
#import "Global.h"
#import <GraphicsServices/GraphicsServices.h>

bool imageend;
Application* app = nil;

typedef struct {} *IOHIDEventSystemRef;
typedef struct {} *IOHIDEventRef;
float IOHIDEventGetFloatValue(IOHIDEventRef ref, int param);
NSString* NowFilePath=NULL;
NSString* NowFile=NULL;

void handleHIDEvent(int a, int b, int c, IOHIDEventRef ptr) {
	int type = IOHIDEventGetType(ptr);
	if (type == 12) {
		float x = IOHIDEventGetFloatValue(ptr, 0xc0000);
		float y = IOHIDEventGetFloatValue(ptr, 0xc0001);
		float z = IOHIDEventGetFloatValue(ptr, 0xc0002);
		//changeInXYZ( x, y, z );
		if(app != nil){
			[app gravity: x gy:y gz:z];
		}
	}
}

#define expect(x) if(!x) { printf("failed: %s\n", #x);  return; }

void initialize(int hz) {
	mach_port_t master;
	expect(0 == IOMasterPort(MACH_PORT_NULL, &master));
	int page = 0xff00, usage = 3;

	CFNumberRef nums[2];
	CFStringRef keys[2];
	keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
	keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
	nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
	nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);
	CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	expect(dict);

	IOHIDEventSystemRef sys = (IOHIDEventSystemRef) IOHIDEventSystemCreate(0);
	expect(sys);

	CFArrayRef srvs = (CFArrayRef)IOHIDEventSystemCopyMatchingServices(sys, dict, 0, 0, 0);
	expect(CFArrayGetCount(srvs)==1);

	io_registry_entry_t serv = (io_registry_entry_t)CFArrayGetValueAtIndex(srvs, 0);
	expect(serv);

	CFStringRef cs = CFStringCreateWithCString(0, "ReportInterval", 0);
	int rv = 1000000/hz;
	CFNumberRef cn = CFNumberCreate(0, kCFNumberSInt32Type, &rv);

	int res = IOHIDServiceSetProperty(serv, cs, cn);
	expect(res == 1);

	res = IOHIDEventSystemOpen(sys, handleHIDEvent, 0, 0);
	expect(res != 0);
	imageend = false;
}

///////////////////////////////////////////////////////////
@implementation ExNavBar

/******************************/
/* ナビバーのＰＯＰデリを設定 */
/******************************/
- (void)setPopDelegate : (id)dele
{
	_popDelegate = dele;
}

/******************************/
/* ナビバーのＰＯＰデリゲート */
/******************************/
- (void)popNavigationItem
{
	if([_popDelegate respondsToSelector:@selector(exNavBar:popNavigationItem:)]){
		[_popDelegate exNavBar:self popNavigationItem:self];
	}
	[super popNavigationItem];
}
@end

///////////////////////////////////////////////////////////
@implementation Application

/******************************/
/* 回転イベント               */
/******************************/
- (void)deviceOrientationChanged:(GSEvent *)event
{
//NSLog(@"deviceOrientationChanged");
	int orient;
	if(prefData.Rotation != 0)
		orient = prefData.Rotation;
	else
		orient = [UIHardware deviceOrientation:YES];
	[_imageview setOrientation:orient];
}

/******************************/
/*                            */
/******************************/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	LoadPref();
	LoadStat();
	LoadPage();
	LoadPsys();
	memset( tmpLastFile, 0x00, sizeof(MAXPATHLEN) );
	isShowImage = NO;

	NowFilePath = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
//NSLog(@"statData ReadFile=%d, ShowView=%d", statData.ReadFile, statData.ShowView);

	app = self;
//	[self setStatusBarMode:2 orientation:0 duration:0];

	//Get screen rect
	CGRect screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin = CGPointZero;
	screct.size.height += STSBAR;

	//setup window
//	UIWindow *window;
//	window = [[UIWindow alloc] initWithContentRect:screct];
//	[window orderFront: self];
//	[window makeKey: self];
//	[window _setHidden: NO];
	window = [[UIWindow alloc] initWithFrame:screct];
	[ window makeKeyAndVisible ];

//		[app statusBarWillAnimateToHeight:0.0f duration:0.0 fence:nil];
//		[app setStatusBarMode:2 orientation:0 duration:.5 fenceID:0 animation:0];
//		[UIHardware _setStatusBarHeight:0.0f];
//		[ window makeKeyAndVisible ];

	//Create window & view
	_transition = [[UITransitionView alloc] initWithFrame:screct];
	[_transition setDelegate:self];
	
	//setup mainview
	_mainview = [[UIView alloc] initWithFrame:screct];

	//setup imageview
	_imageview = [[ImageView alloc] initWithFrame:screct];
	[_imageview setImageDelegate: self];

	//setup prefsview
	_prefsview = [[PrefsView alloc] initWithFrame:screct];
	[_prefsview setDelegate: self];

	_titleBar = [[UINavigationBar alloc] initWithFrame:
			CGRectMake(0, 0, screct.size.width, STSBAR)];
	
	//ナビゲーションバー
	_navbar = [[ExNavBar alloc] initWithFrame:
			CGRectMake(0, STSBAR, screct.size.width, NAVBAR)];
	[_navbar setDelegate:self];
	[_navbar hideButtons];
	[_navbar setPopDelegate:self];
//	[_navbar showLeftButton:nil withStyle:2
//				rightButton:NSLocalizedString(@"Back", nil) withStyle:0];	//ボタンを表示
	[_navbar showLeftButton:nil withStyle:0 rightButton:nil withStyle:0];
	UINavigationItem *navItem;													//タイトル表示
	navItem = [[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Select file", nil)];
	[_navbar pushNavigationItem: navItem];

	//setup buttonbar item 1:folder
	NSDictionary*	btnFolderItem;
	btnFolderItem = [NSDictionary dictionaryWithObjectsAndKeys:
			self, kUIButtonBarButtonTarget,
			@"btnFolderAction:", kUIButtonBarButtonAction, 
			@"folder.png", kUIButtonBarButtonInfo,
			[NSNumber numberWithUnsignedInt:1], kUIButtonBarButtonTag, 
			nil];

	//setup buttonbar item 2:history
	NSDictionary*	btnHistoryItem;
	btnHistoryItem = [NSDictionary dictionaryWithObjectsAndKeys:
			self, kUIButtonBarButtonTarget,
			@"btnHistoryAction:", kUIButtonBarButtonAction, 
			@"folderNow.png", kUIButtonBarButtonInfo,
			[NSNumber numberWithUnsignedInt:2], kUIButtonBarButtonTag, 
			nil];

	//setup buttonbar item 3:setup
	NSDictionary*	btnSetupItem;
	btnSetupItem = [NSDictionary dictionaryWithObjectsAndKeys:
			self, kUIButtonBarButtonTarget,
			@"btnSetupAction:", kUIButtonBarButtonAction, 
			@"setup.png", kUIButtonBarButtonInfo,
			[NSNumber numberWithUnsignedInt:3], kUIButtonBarButtonTag, 
			nil];

	NSArray* items;
	items = [NSArray arrayWithObjects:btnFolderItem, btnHistoryItem, btnSetupItem, nil];

	//setup tableview
	_tabletransition = [[UITransitionView alloc] initWithFrame:
			CGRectMake(0, STSBAR+NAVBAR, screct.size.width, screct.size.height-STSBAR-NAVBAR-BTNBAR)];
	[_tabletransition setDelegate:self];
	
	CGRect bwrect = screct;
	bwrect.size.height -= (STSBAR+NAVBAR+BTNBAR);

	//setup browser
	_browser = [[FileBrowser alloc] initWithFrame:bwrect];
	[_browser setDelegate:self];
	
	//setup browser2
	_browser2 = [[FileBrowser alloc] initWithFrame:bwrect];
	[_browser2 setDelegate:self];
	
	//setup zipbrowser
	_zbrowser = [[ZipFileBrowser alloc] initWithFrame:bwrect];
	[_zbrowser setDelegate:self];

	//setup pagebrowser
	_pagebrowser = [[PageBrowser alloc] initWithFrame:bwrect];
	[_pagebrowser setDelegate:self];

	// _transition: _mainview or _imageview or _prefsview
	//              _mainview: _navbar+_tabletransition+_buttonBar
	//                                 _tabletransition: _currentBrowser or _zbrowser or _pagebrowser
	[window setContentView: _transition];
	[_transition transition:0 toView:_mainview];

	[_mainview addSubview:_titleBar];
	[_mainview addSubview:_navbar];
	[_mainview addSubview:_tabletransition];
	_currentBrowser = _browser;

	//setup buttonbar
	_buttonBar = [[[UIButtonBar alloc]
			initInView:_mainview
			withFrame:CGRectMake(0, screct.size.height-BTNBAR, screct.size.width, BTNBAR)
			withItemList:items] autorelease];
	[_buttonBar setDelegate: self];
	[_buttonBar setBarStyle:2];

#if 0
	//show button
	int buttons[3] = { 1, 2, 3 };
	[_buttonBar showButtons:buttons withCount:3 withDuration:0];

	//align button
	[[_buttonBar viewWithTag:1] setFrame:CGRectMake( 0, 0, 64, 48)];
	[[_buttonBar viewWithTag:1] _setButtonBarHitRect:CGRectMake(0, 0, 64, 48)];
	[[_buttonBar viewWithTag:2] setFrame:CGRectMake( 65, 0, 64, 48)];
	[[_buttonBar viewWithTag:2] _setButtonBarHitRect:CGRectMake(0, 0, 64, 48)];
	[[_buttonBar viewWithTag:3] setFrame:CGRectMake( 256, 0, 64, 48)];
	[[_buttonBar viewWithTag:3] _setButtonBarHitRect:CGRectMake(0, 0, 64, 48)];
#endif
	//show button
	int buttons[1] = { 3 };
	[_buttonBar showButtons:buttons withCount:1 withDuration:0];

	//align button
	[[_buttonBar viewWithTag:3] setFrame:CGRectMake( 256, 0, 64, 48)];
	[[_buttonBar viewWithTag:3] _setButtonBarHitRect:CGRectMake(0, 0, 64, 48)];
//######

	initialize(30);
	[self reportAppLaunchFinished];
	[self deviceOrientationChanged: nil];

	//画面表示
	[self viewSelector:statData.ShowView:0];

	//ナビゲーションバーを設定
	//パスを配列に分解して、ナビゲーションバーにプッシュする
	if(strlen(tmpFile) < COMICPATHLEN){
		strcpy(tmpFile, COMICPATH2);
	}
//NSLog(@"tmpFile=%s",tmpFile);
	//ディレクトリ表示の場合は、ファイル名をプッシュしない
	NSString* file = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
	NSArray* arry = [file pathComponents];
	int path_max = [arry count];
	if(  ( statData.ShowView == BWZ_VIEW )
	   ||(( statData.ShowView == IMG_VIEW )&&( statData.BefView == BWZ_VIEW )) ){
		NSString* file = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
		BOOL isDir = NO;
		if(!([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir)){
			path_max--;
		}
	}
	int i;
	NSMutableString *title;
	for(i=[arry indexOfObject:@"Comic"]+1; i<path_max; i++){
		if( [[arry objectAtIndex:i] compare:@"/"] == NSOrderedSame ){
			break;
		}
		title = [NSMutableString stringWithString:[[arry objectAtIndex:i] stringByDeletingPathExtension]];
		CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
		UINavigationItem *navItem;
		navItem = [[UINavigationItem alloc] initWithTitle:title];
		[_navbar pushNavigationItem:navItem];
	}
	//ZIP表示の場合は、さらに一つ追加する
	if(  ( statData.ShowView == ZIP_VIEW )
	   ||(( statData.ShowView == IMG_VIEW )&&( statData.BefView == ZIP_VIEW )) ){
		title = [NSMutableString stringWithString:[[arry objectAtIndex:(i-1)] stringByDeletingPathExtension]];
		CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
		UINavigationItem *navItem;
		navItem = [[UINavigationItem alloc] initWithTitle:title];
		[_navbar pushNavigationItem:navItem];
	}

	if( PagesCnt == 0 ){
		UIAlertSheet* alertSheet = 
			[[[UIAlertSheet alloc] initWithFrame:CGRectMake(0,120,320,340)] autorelease];
		[alertSheet setTitle:COMICVER];
//#ifdef MOBILE
		[alertSheet setBodyText:NSLocalizedString(@"No Comic mobile", nil)];
//#else
//		[alertSheet setBodyText:NSLocalizedString(@"No Comic root", nil)];
//#endif
		[alertSheet addButtonWithTitle: @"OK"];
		[alertSheet setDelegate: self];
		[alertSheet popupAlertAnimated:YES];
	}
}

/******************************/
/* アプリ終了時に実行される   */
/******************************/
-(void) applicationWillSuspend
{
	SavePage();
	SaveStat();
	[super applicationWillSuspend];
}

-(void) gravity: (float)x  gy:(float) y gz:(float)z
{
	[_imageview gravity:x gy:y gz:z];
}

-(void) dealloc
{
	[_mainview release];
	[_navbar release];
	[_browser release];
	[_browser2 release];
	[_zbrowser release];
	[_transition release];
	[_tabletransition release];
	[_prefsview release];
	[_imageview release];
	[_pagebrowser release];
	[super dealloc];
}

/******************************/
/* 設定画面を終了する         */
/******************************/
- (void)prefsView : (PrefsView *)prefs done: (id) unused
{
	[self deviceOrientationChanged: nil];
	[_imageview setScroll:NO decelerationFactor:prefData.ScrollSpeed];
	[_transition transition:5 toView:_mainview];
}

/******************************/
/* 画像表示を終了する         */
/******************************/
- (void)imageView:(ImageView *)scroll fileEnd:(id)hoge
{
//NSLog(@"imageView scroll fileEnd");
	if(imageend) return;
	[self viewSelector:statData.BefView:2];
	imageend = true;
}

/**********************************/
/* ナビゲーションバーのアクション */
/**********************************/
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
//	if(row == -1) return;
//	//設定画面を表示する
//	[_transition transition:4 toView:_prefsview];

//NSLog(@"aaa %s", tmpLastFile);

	if( strlen(tmpLastFile) > 0 ){
		strcpy( tmpFile, tmpLastFile );
		[self viewSelector:IMG_VIEW:1];
	}
	
	return;	
}

/**********************************/
/* ナビゲーションバーの戻るボタン */
/**********************************/
- (void)exNavBar:(ExNavBar *)navbar popNavigationItem:(id)unused
{
	int backView;
//NSLog(@"exNavBar popNavigationItem befView=%d", statData.BefView);
	NSString* file = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
	//パスを１つ戻す
	if( statData.ShowView != ZIP_VIEW ){
		NowFile = [[file lastPathComponent] copy];
		file = [file stringByDeletingLastPathComponent];
		[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	}
	//前の画面を設定する
	switch(statData.ShowView){
	case IMG_VIEW:
		backView = statData.BefView;
		break;
//	case ZIP_VIEW:
//		backView = PAG_VIEW;
//		break;
//	case PAG_VIEW:
	default:
		backView = BWZ_VIEW;
		break;
	}
//	memset( tmpLastFile, 0x00, sizeof(tmpLastFile) );
	[self viewSelector:backView:2];
//NSLog(file);
}

/******************************/
/* イメージ表示               */
/******************************/
- (void)zipFileBrowser: (ZipFileBrowser *)browser fileSelected:(int)row 
{
//NSLog(@"zipFileBrowser");
	if(row == -1) return;

	SetPageData(tmpFile, row);
	[self viewSelector:IMG_VIEW:1];
	return;	
}

- (void)pageBrowser: (PageBrowser *)browser fileSelected:(int)row 
{
	NSString* file = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
//NSLog(@"pageBrowser %d", row);
//NSLog(file);
	if(row == -1){
		return;
	}
	else if(row == 9999){
		[self viewSelector:IMG_VIEW:1];
	}
	else if(row == 9998){
		[self viewSelector:ZIP_VIEW:1];
	}
	else{
		SetPageData(tmpFile, row);
		[self viewSelector:IMG_VIEW:1];
	}
	return;
}

/******************************/
/* フォルダ表示で行を選択した */
/******************************/
- (void)fileBrowser:(FileBrowser *)browser fileSelected:(NSString *)file
{
//debug_log("fileBrowser\n");
//NSLog(file);
//	[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
//	[self viewSelector:IMG_VIEW:1];
	NSString *title;

	[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];

//debug_log(tmpFile);

	//パスがフォルダの場合、フォルダ表示
	BOOL isDir = NO;
	if([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir){
//		statData.ShowView = BWZ_VIEW;
		[self viewSelector:BWZ_VIEW:1];
	}
	else{
	//fileからZIPファイルパスを取得し、アラート表示する
//	[file getCString: NowFilePath maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
		title = [NSMutableString stringWithString:file];
		CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
		UIAlertSheet *sheet = [ [ UIAlertSheet alloc ] initWithFrame: CGRectMake(0, 240, 320, 240) ];
		[ sheet setTitle: title ];
		[ sheet setBodyText: NSLocalizedString(@"Select action", nil) ];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Start with saved position", nil) ];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Start new book", nil) ];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Page List", nil) ];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Cancel", nil) ];
		[ sheet setDelegate: self ];
		[ sheet presentSheetFromAboveView: _currentBrowser ];
	}
}

- (void)zipBrowser:(FileBrowser *)browser fileSelected:(NSString *)file
{
//NSLog(@"zipBrowser");
//NSLog(file);
	[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	[self viewSelector:PAG_VIEW:1];
}

/******************************/
/* ボタンバーを押下した       */
/******************************/
- (void)btnFolderAction:(id)sender
{
}

- (void)btnHistoryAction:(id)sender
{
//	[_navbar popNavigationItem];
}

- (void)btnSetupAction:(id)sender
{
	//設定画面を表示する
	[_transition transition:4 toView:_prefsview];
}

/******************************/
/* 前の画面に戻る             */
/******************************/
- (void)goBackNavigation
{
	[_navbar popNavigationItem];
}

//		//fileからZIPファイルパスを取得し、アラート表示する
//		[file getCString: NowFilePath maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
//		title = [NSMutableString stringWithString:file];
//		CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
//		UIAlertSheet *sheet = [ [ UIAlertSheet alloc ] initWithFrame: CGRectMake(0, 240, 320, 240) ];
//		[ sheet setTitle: title ];
//		[ sheet setBodyText: NSLocalizedString(@"Select action", nil) ];
//		[ sheet addButtonWithTitle: NSLocalizedString(@"Start with saved position", nil) ];
//		[ sheet addButtonWithTitle: NSLocalizedString(@"Start new book", nil) ];
//		[ sheet addButtonWithTitle: NSLocalizedString(@"Page List", nil) ];
//		[ sheet addButtonWithTitle: NSLocalizedString(@"Cancel", nil) ];
//		[ sheet setDelegate: self ];
//		[ sheet presentSheetFromAboveView: _currentBrowser ];

/******************************/
/* アラート表示               */
/******************************/
- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button 
{
	PageData pd;
	UINavigationItem *navItem;

	[ sheet dismiss ];

//	switch(tmpAlertSheetId){
//	case 1:
//		switch(button){
//		case 1:		//Start with saved position
//			if( strlen(tmpFile) > 0 ){
//				pd = GetPageData(tmpFile);
//				[_imageview setFile: [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding]];
//				[_imageview setPage:pd.page];
//				[_imageview reloadFile];
//				[_imageview fitImage];
//				[_transition transition: 1 toView:_imageview];
//				IsViewingComic = 1;
//			}
//			break;
//		case 2:		//Settings
//			//設定画面を表示する
//			[_transition transition: 0 toView: _prefsview];
//			break;
//		default:
//			break;
//		}
//		break;
//	case 2:
		switch(button){
		case 1:		//Start with saved position
//			strcpy(tmpFile, NowFilePath);
//			pd = GetPageData(NowFilePath);
//			[_imageview setFile: [NSString stringWithCString:NowFilePath encoding:NSUTF8StringEncoding]];
//			[_imageview setPage:pd.page];
//			[_imageview reloadFile];
//			[_imageview fitImage];
//			[_transition transition: 1 toView:_imageview];
//			IsViewingComic = 1;

//			[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
			[self viewSelector:IMG_VIEW:1];
			break;
		case 2:		//Start new book
//			strcpy(tmpFile, NowFilePath);
//			[_imageview setFile: [NSString stringWithCString:NowFilePath encoding:NSUTF8StringEncoding]];
//			if([_imageview reloadFile] == 1){
//				[_imageview nextFile];
//			}
//			[_imageview fitImage];
//			[_transition transition: 1 toView:_imageview];
//			IsViewingComic = 1;

			SetPageData(tmpFile, 0);
//			[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
			[self viewSelector:IMG_VIEW:1];
			break;
		case 3:		//Page List
//			{
//				NSMutableString *title;
//				title = [NSMutableString
//							stringWithString:[[NSString stringWithCString:NowFilePath
//															encoding:NSUTF8StringEncoding] lastPathComponent]];
//				CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
////				navItem = [[UINavigationItem alloc] initWithTitle: [[NSString stringWithCString:NowFilePath encoding:NSUTF8StringEncoding] lastPathComponent]];
//				navItem = [[UINavigationItem alloc] initWithTitle:title];
//				[_navbar pushNavigationItem: navItem];
//				
//				[_tabletransition transition:1 toView: _currentBrowser];
//				[_zbrowser setPath: [NSString stringWithCString:NowFilePath encoding:NSUTF8StringEncoding]];
//				[_zbrowser reloadData];
//				[_tabletransition transition: 1 toView: _zbrowser];
//				tmpAlertDispId = 2;

				[self viewSelector:ZIP_VIEW:1];

//			}
			break;
		}
//		break;
//	case 3:
//		switch(button){
//		case 1:		//Settings
//			//設定画面を表示する
//			[_transition transition: 0 toView: _prefsview];
//			break;
//		}
//		break;
//	default:
//		break;
//	}
}

/******************************/
/* 表示移動                   */
/******************************/
-(void) viewSelector:(int)ShowViewTmp:(int)TStyle
{
	PageData pd;
	UINavigationItem *navItem;
//NSLog(@"viewSelector viewtype=%d, befview=%d, tstyle=%d", ShowViewTmp, statData.BefView, TStyle);

	statData.ShowView = ShowViewTmp;
	//パスなしはComicのルートを設定する
	if( strlen(tmpFile) == 0 ){
		strcpy(tmpFile,COMICPATH2);
	}
	NSString* file = [NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding];
	//パスがフォルダの場合、フォルダ表示
	BOOL isDir = NO;
	if([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir){
		statData.ShowView = BWZ_VIEW;
	}
	//イメージ表示指定の場合、表示ページを設定する
	if(  (statData.ShowView == IMG_VIEW)
	   ||(statData.ShowView == ZIP_VIEW) ){
		pd = GetPageData(tmpFile);
	}
	//フォルダ表示の場合、ファイルパスを調整する
	if(statData.ShowView == BWZ_VIEW){
		//ファイルが指定された場合、ファイル名を取り除く
		BOOL isDir = YES;
		if(!([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir)){
			file = [file stringByDeletingLastPathComponent];
		}
		//フォルダが格納パスより上位を指す場合、格納パスを設定する
		if( [file length] <= COMICPATHLEN ){
			file = COMICPATH;
		}
	}
	[file getCString:tmpFile maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
//NSLog(file);
	//イメージ表示とその他表示にビューを切り替える
	if(statData.ShowView == IMG_VIEW){
//		[app setStatusBarMode:2 orientation:0 duration:0];
//		[app setStatusBarMode:2 orientation:0 duration: [UITransitionView defaultDurationForTransition: 1]];
//		[UIHardware _setStatusBarHeight:0.0f];
//		[app statusBarWillAnimateToHeight:0.0f duration:0.0 fence:nil];
//		[app setStatusBarMode:2 orientation:0 duration:.5 fenceID:0 animation:0];
//		[UIHardware _setStatusBarHeight:0.0f];
//		[ window makeKeyAndVisible ];

		[_transition transition:TStyle toView:_imageview];
		strcpy( tmpLastFile, tmpFile );
	}
	else{
		//戻るときのために、表示を保存する
		statData.BefView = statData.ShowView;
		//イメージ表示以外は、前画面を保存し、ナビゲーションバーをプッシュする
		if( TStyle == 1 ){
			NSMutableString *title;
			title = [NSMutableString stringWithString:[[file lastPathComponent] stringByDeletingPathExtension]];
			CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
			UINavigationItem *navItem;
			navItem = [[UINavigationItem alloc] initWithTitle:title];
			[_navbar pushNavigationItem:navItem];
		}
//		[app setStatusBarMode:0 orientation:0 duration:0];
		[_transition transition:TStyle toView:_mainview];
	}
	switch(statData.ShowView){
	case IMG_VIEW:
NSLog(@"Go IMG_VIEW");
		[_imageview setFile:file];
		[_imageview setPage:pd.page];
		[_imageview reloadFile];
		imageend = false;
		break;
	case ZIP_VIEW:
NSLog(@"Go ZIP_VIEW");
		[_zbrowser setPath:file];
		[_tabletransition transition:TStyle toView:_zbrowser];
		[_zbrowser table_scroll];
		break;
	case BWZ_VIEW:
NSLog(@"Go BWZ_VIEW");
		_currentBrowser = (_currentBrowser == _browser) ? _browser2 : _browser;
		[_currentBrowser setPath:file];
		[_currentBrowser setSelectFile:NowFile];
		[_tabletransition transition:TStyle toView:_currentBrowser];
		memset( tmpLastFile, 0x00, sizeof(MAXPATHLEN) );
		[_currentBrowser table_scroll];
//		isShowImage = NO;
		break;
	case PAG_VIEW:
NSLog(@"Go PAG_VIEW");
		[_pagebrowser setPath:file];
		[_tabletransition transition:TStyle toView:_pagebrowser];
		[_pagebrowser table_scroll];
		break;
	default:
		break;
	}
//NSLog(@"  viewSelector end viewtype=%d, befview=%d, tstyle=%d", statData.ShowView, statData.BefView, TStyle);
}

@end
