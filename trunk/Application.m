/* 
	Kokusi App
*/

#import <stdio.h>
#import "Application.h"
#import "Global.h"
#import <GraphicsServices/GraphicsServices.h>

#define MAXPATHLEN 512
#define NAVBARHEIGHT 48
#define COMICPATH @"/var/root/Media/Comic/"


char tmpfilename[MAXPATHLEN];

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
	[_imageview setOrientation: [UIHardware deviceOrientation:YES]];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	LoadUIText();

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
	[_navbar showLeftButton:nil withStyle:2 rightButton:[NSString stringWithCString: UIText[5] encoding:NSUTF8StringEncoding] withStyle:0];

	//put string
	UINavigationItem *navItem;
	navItem = [[UINavigationItem alloc] initWithTitle: [NSString stringWithCString: UIText[4] encoding:NSUTF8StringEncoding]];
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
	
	[self reportAppLaunchFinished];
}


- (void)prefsView : (PrefsView *)prefs done: (id) unused
{
	[_imageview setScroll: prefsData.IsScroll decelerationFactor: prefsData.ScrollSpeed];
	[_transition transition: 5 toView:_mainview];	
}

- (void)imageView: (ImageView *)scroll fileEnd: (id) hoge
{
	[_transition transition: 2 toView:_mainview];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[_transition transition: 8 toView: _prefsview];
}

- (void)exNavBar : (ExNavBar *)navbar popNavigationItem: (id) unused
{
	if(_currentBrowser == _browser) _currentBrowser = _browser2;
	else _currentBrowser = _browser;
	
//	NSString* file = [[NSString stringWithCString: tmpfilename encoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent];
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
		[ sheet setBodyText:[NSString stringWithCString: UIText[0] encoding:NSUTF8StringEncoding]];
		[ sheet addButtonWithTitle:[NSString stringWithCString: UIText[1] encoding:NSUTF8StringEncoding]];
		[ sheet addButtonWithTitle:[NSString stringWithCString: UIText[2] encoding:NSUTF8StringEncoding]];
		[ sheet addButtonWithTitle:[NSString stringWithCString: UIText[3] encoding:NSUTF8StringEncoding]];
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
		[_imageview setFile: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
		if([_imageview reloadFile] == 1 && prefsData.ShowErrorImage == NO) [_imageview nextFile];
		[_imageview fitImage];
		[_transition transition: 1 toView:_imageview];
		return;
	}
	else if(button == 2)
	{
		PageData pd = GetPageData(tmpfilename);
		[_imageview setFile: [NSString stringWithCString:tmpfilename encoding:NSUTF8StringEncoding]];
		[_imageview setPage:pd.page];
		[_imageview reloadFile];
		[_imageview fitImage];
		[_transition transition: 1 toView:_imageview];
		return;
	}
	else if(button == 3)
	{
	}
}

@end


