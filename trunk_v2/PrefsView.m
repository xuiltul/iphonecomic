#import"PrefsView.h"
#import"Global.h"

//[表示]
//　次ページで右上に行く
//　拡大率を維持
//　右にスライド
//　画面再読込み
//　スクロールの早さ
//　最大倍率
//[操作]
//　左ボタンで次のページ
//　ボタンの大きさ
//　次のZIPを表示
//　重力ページ送り
//　ボタンページ送り
//　スワイプページ送り
//　サウンド
//[回転]
//　回転

//廃止
//　ステータスバーを消す
//　バウンズ
//　大きい画像をリサイズ
//　画面サイズに最適化
//　ボタンの誤差

@implementation PrefsView 
- (id)initWithFrame:(struct CGRect)frame
{
	[super initWithFrame:frame];
	
	_navbar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, STSBAR, frame.size.width, NAVBAR)] autorelease];
//	[_navbar showLeftButton:NSLocalizedString(@"help", nil) withStyle:0 rightButton:NSLocalizedString(@"done", nil) withStyle:3]; // Blue Done button
	[_navbar showLeftButton:nil withStyle:0 rightButton:NSLocalizedString(@"done", nil) withStyle:3]; // Blue Done button
	[_navbar setBarStyle:0];
	[_navbar setDelegate:self];
	[self addSubview:_navbar];

	//Title Settings
//	UINavigationItem *title = [[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Settings", nil)];
	UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:@__DATE__];
	[_navbar pushNavigationItem:[title autorelease]];

	//表示サイズ
	CGRect switchCellRect = CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f);
	CGRect switchCtrlRect = CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f);
	CGRect numberCellRect = CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f);

	//
	_prefstable = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0, STSBAR+NAVBAR, frame.size.width, frame.size.height-NAVBAR-STSBAR)];	
	[_prefstable setDataSource:self];
	[_prefstable setDelegate:self];
	[_prefstable reloadData];
	[self addSubview:_prefstable];
	
	//Move to top right
	_migicell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_migicell setTitle:NSLocalizedString(@"Move to top right", nil)];
	UISwitchControl *migiSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[migiSwitch setValue:prefData.ToScrollRightTop];
	[_migicell setControl:migiSwitch];
	
	//Keep scale
	_scalecell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_scalecell setTitle:NSLocalizedString(@"Keep scale", nil)];
	UISwitchControl *scaleSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[scaleSwitch setValue:prefData.ToKeepScale];
	[_scalecell setControl:scaleSwitch];

	//Slide to right
	_sliderigntcell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_sliderigntcell setTitle:NSLocalizedString(@"Slide to right", nil)];
	UISwitchControl *sliderightSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[sliderightSwitch setValue:prefData.SlideRight];
	[_sliderigntcell setControl:sliderightSwitch];

	//Reload Screen
	_reloadscreencell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_reloadscreencell setTitle:NSLocalizedString(@"Reload Screen", nil)];
	UISwitchControl *reloadscreenSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[reloadscreenSwitch setValue:prefData.ReloadScreen];
	[_reloadscreencell setControl:reloadscreenSwitch];

	//Scroll speed
	_scrollspeedcell = [[UIPreferencesTextTableCell alloc] initWithFrame:numberCellRect];
	[_scrollspeedcell setValue:[NSString stringWithFormat:@"%d", prefData.ScrollSpeed]];
	[_scrollspeedcell setTitle:NSLocalizedString(@"Scroll speed(1-100)", nil)];

	//Max Scale
	_maxscalecell = [[UIPreferencesTextTableCell alloc] initWithFrame:numberCellRect];
	[_maxscalecell setValue:[NSString stringWithFormat:@"%d", prefData.MaxScale]];
	[_maxscalecell setTitle:NSLocalizedString(@"Max Scale(1-6)", nil)];

	//Left button is next
	_leftbtncell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_leftbtncell setTitle:NSLocalizedString(@"Left button is next", nil)];
	UISwitchControl *directionSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[directionSwitch setValue:prefData.LBtnIsNext];
	[_leftbtncell setControl:directionSwitch];

	//Button size
	_buttonsizecell = [[UIPreferencesTextTableCell alloc] initWithFrame:numberCellRect];
	[_buttonsizecell setValue:[NSString stringWithFormat:@"%d", prefData.HitRange]];
	[_buttonsizecell setTitle:NSLocalizedString(@"Button size(48-160)", nil)];

	//Next Zip
	_isnextzip = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_isnextzip setTitle:NSLocalizedString(@"Next Zip", nil)];
	UISwitchControl *isnextzipswitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[isnextzipswitch setValue:prefData.IsNextZip];
	[_isnextzip setControl:isnextzipswitch];
	
	//Gravity page slide
	_gravitycell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_gravitycell setTitle:NSLocalizedString(@"Gravity page slide", nil)];
	UISwitchControl *gravitySwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[gravitySwitch setValue:prefData.GravitySlide];
	[_gravitycell setControl:gravitySwitch];
	
	//Button page slide
	_buttoncell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_buttoncell setTitle:NSLocalizedString(@"Button page slide", nil)];
	UISwitchControl *buttonSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[buttonSwitch setValue:prefData.ButtonSlide];
	[_buttoncell setControl:buttonSwitch];
	
	//Swipe page slide
	_swipecell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_swipecell setTitle:NSLocalizedString(@"Swipe page slide", nil)];
	UISwitchControl *swipeSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[swipeSwitch setValue:prefData.SwipeSlide];
	[_swipecell setControl:swipeSwitch];

	//Sound On
	_soundcell = [[UIPreferencesControlTableCell alloc] initWithFrame:switchCellRect];
	[_soundcell setTitle:NSLocalizedString(@"Sound On", nil)];
	UISwitchControl *soundSwitch = [[[UISwitchControl alloc] initWithFrame:switchCtrlRect] autorelease];
	[soundSwitch setValue:prefData.SoundOn];
	[_soundcell setControl:soundSwitch];

	//Rotation
	_rotationcell = [[UIPreferencesTextTableCell alloc] initWithFrame:numberCellRect];
	[_rotationcell setValue:[NSString stringWithFormat:@"%d", prefData.Rotation]];
	[_rotationcell setTitle:NSLocalizedString(@"Rotation(0-4)", nil)];

// 	_segCtrl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 280.0f, 55.0f)];
//	[_segCtrl insertSegment:0 withTitle:@"G" animated:NO];
//	[_segCtrl insertSegment:1 withTitle:@"1" animated:NO];
//	[_segCtrl insertSegment:2 withTitle:@"2" animated:NO];
//	[_segCtrl insertSegment:3 withTitle:@"3" animated:NO];
//	[_segCtrl insertSegment:4 withTitle:@"4" animated:NO];
//	[_segCtrl setDelegate: self];
//	_segCell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 48.0f)];
//	[_segCell setDrawsBackground:NO];
//	[_segCell addSubview: _segCtrl];
//	[_segCtrl selectSegment: prefData.Rotation];
	 
	return self;
}

- (void)setDelegate : (id) dele
{
	_delegate = dele;
}

- (void) dealloc
{
	[_migicell release];
	[_scalecell release];
	[_sliderigntcell release];
	[_reloadscreencell release];
	[_scrollspeedcell release];
	[_maxscalecell release];

	[_leftbtncell release];
	[_buttonsizecell release];
	[_isnextzip release];
	[_gravitycell release];
	[_buttoncell release];
	[_swipecell release];
	[_soundcell release];

	[_rotationcell release];

//	[_segCtrl release];
//	[_segCell release];

	[_prefstable release];
	[_navbar release];

	[super dealloc];
}

#define MAX_RANGE_SIZE 160
#define MIN_RANGE_SIZE 48
#define MAX_SCROLL_SIZE 100
#define MIN_SCROLL_SIZE 1
#define MAX_SCALE_SIZE 6
#define MIN_SCALE_SIZE 1
#define MAX_ROTATION_SIZE 4
#define MIN_ROTATION_SIZE 0

//------------------------delegate
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
//	if(button == 1){
//		UIAlertSheet* alertSheet = 
//			[[[UIAlertSheet alloc] initWithFrame:CGRectMake(0,120,320,340)] autorelease];
//		
//		[alertSheet setTitle: NSLocalizedString(@"help", nil)];
//
//		NSBundle *bundle = [NSBundle mainBundle];
//		NSString *tempstr;
//		tempstr = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"ReadMe" ofType:@""]] encoding:NSUTF8StringEncoding] autorelease];
//
//		[alertSheet setBodyText: tempstr];
//		[alertSheet addButtonWithTitle: @"OK"];
//		[alertSheet setDelegate: self];
//		[alertSheet popupAlertAnimated:YES];
//	}
//	else{
		prefData.ToScrollRightTop	= [[[_migicell control] valueForKey:@"value"] boolValue];
		prefData.ToKeepScale		= [[[_scalecell control] valueForKey:@"value"] boolValue];
		prefData.SlideRight			= [[[_sliderigntcell control] valueForKey:@"value"] boolValue];
		prefData.ReloadScreen		= [[[_reloadscreencell control] valueForKey:@"value"] boolValue];

		prefData.LBtnIsNext			= [[[_leftbtncell control] valueForKey:@"value"] boolValue];
		prefData.IsNextZip			= [[[_isnextzip control] valueForKey:@"value"] boolValue];
		prefData.GravitySlide		= [[[_gravitycell control] valueForKey:@"value"] boolValue];
		prefData.ButtonSlide		= [[[_buttoncell control] valueForKey:@"value"] boolValue];
		prefData.SwipeSlide			= [[[_swipecell control] valueForKey:@"value"] boolValue];
		prefData.SoundOn			= [[[_soundcell control] valueForKey:@"value"] boolValue];

		int worknum;
		worknum = [[_buttonsizecell value] intValue];
		worknum = (worknum > MAX_RANGE_SIZE) ? MAX_RANGE_SIZE : worknum;
		worknum = (worknum < MIN_RANGE_SIZE) ? MIN_RANGE_SIZE : worknum;
		prefData.HitRange = worknum;

		worknum = [[_scrollspeedcell value] intValue];
		worknum = (worknum > MAX_SCROLL_SIZE) ? MAX_RANGE_SIZE : worknum;
		worknum = (worknum < MIN_SCROLL_SIZE) ? MIN_RANGE_SIZE : worknum;
		prefData.ScrollSpeed = worknum;

		worknum = [[_maxscalecell value] intValue];
		worknum = (worknum > MAX_SCALE_SIZE) ? MAX_SCALE_SIZE : worknum;
		worknum = (worknum < MIN_SCALE_SIZE) ? MIN_SCALE_SIZE : worknum;
		prefData.MaxScale = worknum;

		worknum = [[_rotationcell value] intValue];
		worknum = (worknum > MAX_ROTATION_SIZE) ? MAX_ROTATION_SIZE : worknum;
		worknum = (worknum < MIN_ROTATION_SIZE) ? MIN_ROTATION_SIZE : worknum;
		prefData.Rotation = worknum;

		SavePref();
		if( [_delegate respondsToSelector:@selector( prefsView:done: )] )
			[_delegate prefsView:self done:nil];
//	}
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button {
	[sheet dismissAnimated:YES];
}

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)table
{
//	return 3;
	return 2;
}

- (int)preferencesTable:(UIPreferencesTable *)table numberOfRowsInGroup:(int)group
{
	switch (group){
	case 0:	//View
		return 6;
	case 1:	//Input
//		return 7;
		return 8;
//	case 2:	//Rotation
//		return 1;
	}
}

- (float)preferencesTable:(id)table heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposedHeight;
{
	return 48.0f;
}

- (void)tableRowSelected:(NSNotification *)notification 
{
	int i = [_prefstable selectedRow];
  	switch (i){
		default:
		[[_prefstable cellAtRow:i column:0] setSelected:NO];
		break;
	}
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)table cellForRow:(int)row inGroup:(int)group
{
	if (group == 0){
		if(row == 0)return _migicell;
		if(row == 1)return _scalecell;
		if(row == 2)return _sliderigntcell;
		if(row == 3)return _reloadscreencell;
		if(row == 4)return _scrollspeedcell;
		if(row == 5)return _maxscalecell;
	}
	else if(group == 1){
		if(row == 0)return _leftbtncell;
		if(row == 1)return _buttonsizecell;
		if(row == 2)return _isnextzip;
		if(row == 3)return _gravitycell;
		if(row == 4)return _buttoncell;
		if(row == 5)return _swipecell;
		if(row == 6)return _soundcell;
		if(row == 7)return _rotationcell;
	}
//	else if(group == 2){
//		if(row == 0) return _segCell;
//	}
	return nil;
}

- (id)preferencesTable:(id)preferencesTable titleForGroup:(int)group
{
	NSString *title = nil;
	switch (group){
	case 0:
		title = NSLocalizedString(@"View", nil);//,  [lines objectAtIndex:4];
		break;
	case 1:
		title = NSLocalizedString(@"Input", nil);//,  [lines objectAtIndex:4];
		break;
//	case 2:
//		title = NSLocalizedString(@"Rotation", nil);
//		break;
	}
	return title;
}

//- (void) segmentedControl: (UISegmentedControl *)segment selectedSegmentChanged: (int)seg
////- (void) segmentedControl: (UISegmentedControl *)segment delegateSelectedSegmentChanged: (int)seg
//{
//	prefData.Rotation = seg;
//}
//
//- (void) segmentedControl: (UISegmentedControl *)segment delegateSelectedSegmentChanged: (int)seg
//{
//	prefData.Rotation = seg;
//}
//

@end
