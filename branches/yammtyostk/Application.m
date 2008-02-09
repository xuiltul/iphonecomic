/* 
	Kokusi App
*/

#import <stdio.h>
#import "Application.h"
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>
#import "Global.h"
#import <GraphicsServices/GraphicsServices.h>

#define NAVBARHEIGHT 48


char tmpfilename[MAXPATHLEN];

Application* app = nil;


typedef struct {} *IOHIDEventSystemRef;
typedef struct {} *IOHIDEventRef;
float IOHIDEventGetFloatValue(IOHIDEventRef ref, int param);

void handleHIDEvent(int a, int b, int c, IOHIDEventRef ptr) {
	int type = IOHIDEventGetType(ptr);
	if (type == 12) {
		float x = IOHIDEventGetFloatValue(ptr, 0xc0000);
		float y = IOHIDEventGetFloatValue(ptr, 0xc0001);
		float z = IOHIDEventGetFloatValue(ptr, 0xc0002);
		//changeInXYZ( x, y, z );
		if(app != nil)
		{
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
}

@implementation ExNavBar
- (void)setPopDelegate : (id)dele
{
	_popDelegate = dele;
}

- (void)popNavigationItem
{
	if([_popDelegate respondsToSelector:@selector(exNavBar:popNavigationItem:)])
	{
		[_popDelegate exNavBar:self popNavigationItem:self];
	}	
	[super popNavigationItem];
}
@end


@implementation Application
- (void)deviceOrientationChanged:(GSEvent *)event {
/*	UITextView* textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, 245.0f - 40.0f)];
	[_mainview addSubview:textView];
	[textView setText: [NSString stringWithFormat:@"%d", [UIHardware deviceOrientation:YES]]];*/
	int orient = [UIHardware deviceOrientation:YES];
	if(prefsData.Rotation != 0) orient = prefsData.Rotation;
	[_imageview setOrientation: orient];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	LoadUIText();
	app = self;
	if(prefsData.HideStatusbar == YES)
	{
		[self setStatusBarMode:2 orientation:0 duration:0];
		[UIHardware _setStatusBarHeight: 0];
	}
	struct CGRect screct = [UIHardware fullScreenApplicationContentRect];
	screct.origin.x = screct.origin.y = 0.0f;
	//screct.origin.y = -20;

	

	//setup window
	UIWindow *window;
	window = [[UIWindow alloc] initWithContentRect: screct];
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];
	
	//setup mainview
        _mainview = [[UIView alloc] initWithFrame: screct];
        

        //setup navigationbar
	_navbar = [[ExNavBar alloc] initWithFrame:
	CGRectMake(0, 0, screct.size.width, NAVBARHEIGHT)];
	[_navbar setDelegate:self];
	[_navbar hideButtons];
	[_navbar setPopDelegate:self];
	[_navbar showLeftButton:nil withStyle:2 rightButton:NSLocalizedString(@"Settings", nil) withStyle:0];

	//put string
	UINavigationItem *navItem;
	navItem = [[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Select file", nil)];
	[_navbar pushNavigationItem: navItem];

	
	//setup transitonview
	_transition = [[UITransitionView alloc] initWithFrame:
	CGRectMake(0, 0, screct.size.width, screct.size.height)];
	[_transition setDelegate:self];
	
	//setup transitonview
	_tabletransition = [[UITransitionView alloc] initWithFrame:
	CGRectMake(0, NAVBARHEIGHT, screct.size.width, screct.size.height - NAVBARHEIGHT)];
	[_tabletransition setDelegate:self];
	
	//setup browser
	_browser = [[FileBrowser alloc] initWithFrame:CGRectMake(0, 0, screct.size.width, screct.size.height - NAVBARHEIGHT)];
	[_browser setExtensions:[NSArray arrayWithObjects:@"zip", @"", nil]];
	[_browser setPath:COMICPATH];
	[_browser setDelegate:self];
	_currentBrowser = _browser;
	
	//setup browser
	_browser2 = [[FileBrowser alloc] initWithFrame:CGRectMake(0, 0, screct.size.width, screct.size.height - NAVBARHEIGHT)];
	[_browser2 setExtensions:[NSArray arrayWithObjects:@"zip", @"", nil]];
	[_browser2 setPath:COMICPATH];
	[_browser2 setDelegate:self];
	
	_zbrowser = [[ZipFileBrowser alloc]  initWithFrame:CGRectMake(0, 0, screct.size.width, screct.size.height - NAVBARHEIGHT)];
	[_zbrowser setPath:COMICPATH];
	[_zbrowser setDelegate:self];
	
	
	//setup ImageView
	_imageview = [[ImageView alloc] initWithFrame:screct];
	[_imageview setFileDelegate: self];
	

	//
	// window　→　transition→ navBar
	//                    　→ _tabletransition→_browser
	//
	[window setContentView: _transition];
	[_transition transition:0 toView:_mainview];

	[_mainview addSubview:_navbar];
	[_mainview addSubview:_tabletransition];
	[_tabletransition transition: 0 toView:_browser];


	//setup prefsview
	_prefsview = [[PrefsView alloc] initWithFrame:CGRectMake(0, 0, screct.size.width, screct.size.height)];
	[_prefsview setDelegate: self];
	
	initialize(30);
	[self reportAppLaunchFinished];
	[self deviceOrientationChanged: nil];
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
	[super dealloc];
}

- (void)prefsView : (PrefsView *)prefs done: (id) unused
{
	[self deviceOrientationChanged: nil];
	[_imageview setScroll: prefsData.IsScroll decelerationFactor: prefsData.ScrollSpeed];
	[_transition transition: 5 toView:_mainview];	
}

- (void)imageView: (ImageView *)scroll fileEnd: (id) hoge
{
	[_transition transition: 2 toView:_mainview];
	IsViewingComic = 0;
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[_transition transition: 8 toView: _prefsview];
}

- (void)exNavBar : (ExNavBar *)navbar popNavigationItem: (id) unused
{
	if([_tabletransition containsView: _zbrowser])
	{
		[_currentBrowser reloadData];
		[_tabletransition transition:2 toView: _currentBrowser];	
		return;	
	}
	else
	{
		if(_currentBrowser == _browser) _currentBrowser = _browser2;
		else _currentBrowser = _browser;
	}
	
//	NSString* file = [[NSString stringWithCString: tmpfilename encoding:NSUTF8StringEncoding] stringByDeleting PathComponent];
	NSString* file = [NSString stringWithCString: tmpfilename encoding:NSUTF8StringEncoding];

	BOOL isDir = NO;
	
	//tmpfilenameがファイル名の時がある
	if([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir)
	{
		file = [file stringByDeletingLastPathComponent];
	}
	else
	{
		file = [[file stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	}

	[file getCString: tmpfilename maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	[_currentBrowser setPath:file];
	[_currentBrowser reloadData];
	
	[_tabletransition transition:2 toView: _currentBrowser];
}

- (void)zipFileBrowser: (ZipFileBrowser *)browser fileSelected:(int)row 
{
	if(row == -1) return;
	[_imageview setFile: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
	[_imageview setPage: row];
	[_imageview reloadFile];
	[_imageview fitImage];
	[_transition transition: 1 toView:_imageview];
	IsViewingComic = 1;
	return;	
}

- (void)fileBrowser: (FileBrowser *)browser fileSelected:(NSString *)file 
{
	BOOL isDir = NO;
	//ディレクトリの時
	if ([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir)
	{
//		NSLog(@"directory");
		if(_currentBrowser == _browser) _currentBrowser = _browser2;
		else _currentBrowser = _browser;
		
		[_currentBrowser setPath:file];
		[_currentBrowser reloadData];

		[file getCString: tmpfilename maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
		
		//put string
		UINavigationItem *navItem;
		navItem = [[UINavigationItem alloc] initWithTitle: [file lastPathComponent]];
		[_navbar pushNavigationItem: navItem];
		
		[_tabletransition transition:1 toView: _currentBrowser];
	}
	else
	{
//		NSLog(@"file");
		[file getCString: tmpfilename maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
		UIAlertSheet *sheet = [ [ UIAlertSheet alloc ] initWithFrame: 
		    CGRectMake(0, 240, 320, 240) ];
		[ sheet setTitle: file ];
		[ sheet setBodyText: NSLocalizedString(@"Select action", nil)];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Start with saved position", nil)];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Start new book", nil)];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Page List", nil)];
		[ sheet addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];

		[ sheet setDelegate: self ];
		[ sheet presentSheetFromAboveView: _currentBrowser ];
        }
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button 
{
	[ sheet dismiss ];
	char buf[MAXPATHLEN];
	if(button == 1)
	{
		PageData pd = GetPageData(tmpfilename);
		[_imageview setFile: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
		[_imageview setPage:pd.page];
		[_imageview reloadFile];
		[_imageview fitImage];
		[_transition transition: 1 toView:_imageview];
		IsViewingComic = 1;
		return;	
	}
	else if(button == 2)
	{
		[_imageview setFile: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
		if([_imageview reloadFile] == 1)
		{
			[_imageview nextFile];
		}
		[_imageview fitImage];
		[_transition transition: 1 toView:_imageview];
		IsViewingComic = 1;
		return;
	}
	else if(button == 3)
	{

		UINavigationItem *navItem;
		navItem = [[UINavigationItem alloc] initWithTitle: [[NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding] lastPathComponent]];
		[_navbar pushNavigationItem: navItem];
		
		[_tabletransition transition:1 toView: _currentBrowser];
		[_zbrowser setPath: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
		[_zbrowser reloadData];
		[_tabletransition transition: 1 toView: _zbrowser];
	}
}

@end


