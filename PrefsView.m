#import"PrefsView.h"
#import"Global.h"

//[表示]
//　バウンズ
//　次ページで右上に行く
//　拡大率を維持
//　画面サイズに最適化
//　スクロールの早さ
//[操作]
//　右にスライド
//　判定の大きさ
//　重力ページ送り
//　ボタンページ送り
//　スワイプページ送り
//[回転]
//　回転

//廃止
//　ステータスバーを消す
//　大きい画像をリサイズ

@implementation PrefsView 
- (id)initWithFrame:(struct CGRect)frame
{
	[super initWithFrame:frame];
	
	_navbar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)] autorelease];
	[_navbar showLeftButton:NSLocalizedString(@"help", nil) withStyle:0 rightButton:NSLocalizedString(@"done", nil) withStyle:3]; // Blue Done button
	[_navbar setBarStyle:0];
	[_navbar setDelegate:self];
	[self addSubview:_navbar];

//		title = NSLocalizedString(@"View", nil);//,  [lines objectAtIndex:4];
	//Title Settings
	UINavigationItem *title = [[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Settings", nil)];
	[_navbar pushNavigationItem:[title autorelease]];

	//
	_prefstable = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, frame.size.height - 48.0f)];	
	[_prefstable setDataSource:self];
	[_prefstable setDelegate:self];
	[_prefstable reloadData];
	[self addSubview:_prefstable];
	
	//Bounce
	_bouncecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_bouncecell setTitle:NSLocalizedString(@"Bounce", nil)];
	UISwitchControl *scrollSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scrollSwitch setValue:prefData.IsScroll];
	[_bouncecell setControl:scrollSwitch];

	//Hide status bar
	_statusbarcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_statusbarcell setTitle:NSLocalizedString(@"Hide status bar", nil)];
	UISwitchControl *statusSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[statusSwitch setValue:prefData.HideStatusbar];
	[_statusbarcell setControl:statusSwitch];

	//Move to top right
	_migicell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_migicell setTitle:NSLocalizedString(@"Move to top right", nil)];
	UISwitchControl *migiSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[migiSwitch setValue:prefData.ToScrollRightTop];
	[_migicell setControl:migiSwitch];
	
	//Keep scale
	_scalecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_scalecell setTitle:NSLocalizedString(@"Keep scale", nil)];
	UISwitchControl *scaleSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scaleSwitch setValue:prefData.ToKeepScale];
	[_scalecell setControl:scaleSwitch];
	 
	//Left button is next
	_leftbtncell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_leftbtncell setTitle:NSLocalizedString(@"Left button is next", nil)];
	UISwitchControl *directionSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[directionSwitch setValue:prefData.LBtnIsNext];
	[_leftbtncell setControl:directionSwitch];

//	//Resize big image
//	_errorcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
//	[_errorcell setTitle:NSLocalizedString(@"Resize big image", nil)];
//	UISwitchControl *errorSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
//	[errorSwitch setValue:prefData.ToResizeImage];
//	[_errorcell setControl:errorSwitch];

	//Fit Screen
	_fitscrcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_fitscrcell setTitle:NSLocalizedString(@"Fit Screen", nil)];
	UISwitchControl *errorSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[errorSwitch setValue:prefData.ToFitScreen];
	[_fitscrcell setControl:errorSwitch];
	
	//Gravity page slide
	_gravitycell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_gravitycell setTitle:NSLocalizedString(@"Gravity page slide", nil)];
	UISwitchControl *gravitySwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[gravitySwitch setValue:prefData.GravitySlide];
	[_gravitycell setControl:gravitySwitch];
	
	//Button page slide
	_buttoncell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_buttoncell setTitle:NSLocalizedString(@"Button page slide", nil)];
	UISwitchControl *buttonSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[buttonSwitch setValue:prefData.ButtonSlide];
	[_buttoncell setControl:buttonSwitch];
	
	//Swipe page slide
	_swipecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_swipecell setTitle:NSLocalizedString(@"Swipe page slide", nil)];
	UISwitchControl *swipeSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[swipeSwitch setValue:prefData.SwipeSlide];
	[_swipecell setControl:swipeSwitch];

			//UIPreferencesTextTableCell *_scrollspeedcell;
			//UIPreferencesTextTableCell *_statusbarcell;
	//Button size
	_buttonsizecell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	NSString	*str = [NSString stringWithFormat:@"%d", prefData.HitRange];
	[_buttonsizecell setValue:str];
	[_buttonsizecell setTitle:NSLocalizedString(@"Button size(48-160)", nil)];

	//Scroll speed
	_scrollspeedcell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	[_scrollspeedcell setValue:[NSString stringWithFormat:@"%d", (int)prefData.ScrollSpeed]];
	[_scrollspeedcell setTitle:NSLocalizedString(@"Scroll speed(1-100)", nil)];
//	UIPreferencesTextTableCell *_buttonsizecell;
	 
 	_segCtrl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 280.0f, 55.0f)];
	[_segCtrl insertSegment:0 withTitle:@"G" animated:NO];
	[_segCtrl insertSegment:1 withTitle:@"1" animated:NO];
	[_segCtrl insertSegment:2 withTitle:@"2" animated:NO];
	[_segCtrl insertSegment:3 withTitle:@"3" animated:NO];
	[_segCtrl insertSegment:4 withTitle:@"4" animated:NO];
	[_segCtrl setDelegate: self];
	_segCell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 48.0f)];
	[_segCell setDrawsBackground:NO];
	[_segCell addSubview: _segCtrl];
	[_segCtrl selectSegment: prefData.Rotation];
	 
	return self;
}

- (void)setDelegate : (id) dele
{
	_delegate = dele;
//	[super setDelegate: dele];
}

- (void) dealloc
{
	
	[_prefstable release];
	[_navbar release];
	[_bouncecell release];
	[_scrollspeedcell release];
	[_statusbarcell release];
	[_migicell release];
	[_scalecell release];
	[_buttonsizecell release];
	[_leftbtncell release];
//	[_errorcell release];
	[_fitscrcell release];

	[_gravitycell release];
	[_buttoncell release];
	[_swipecell release];
	
	[_segCtrl release];
	[_segCell release];
}


#define MAX_RANGE_SIZE 160
#define MIN_RANGE_SIZE 48
#define MAX_SCROLL_SIZE 100
#define MIN_SCROLL_SIZE 1

//------------------------delegate
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if(button == 1)
	{
		UIAlertSheet* alertSheet = 
		[[[UIAlertSheet alloc] initWithFrame:CGRectMake(0,120,320,340)] autorelease];
		
		[alertSheet setTitle: NSLocalizedString(@"help", nil)];

		NSBundle *bundle = [NSBundle mainBundle];
		NSString *tempstr;
		tempstr = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"ReadMe" ofType:@""]] encoding:NSUTF8StringEncoding] autorelease];

		[alertSheet setBodyText: tempstr];
		[alertSheet addButtonWithTitle: @"OK"];
		[alertSheet setDelegate: self];
		[alertSheet popupAlertAnimated:YES];
	}
	else
	{
		prefData.IsScroll = [[[_bouncecell control] valueForKey:@"value"] boolValue];
		prefData.ToScrollRightTop = [[[_migicell control] valueForKey:@"value"] boolValue];
		prefData.ToKeepScale = [[[_scalecell control] valueForKey:@"value"] boolValue];
		prefData.LBtnIsNext = [[[_leftbtncell control] valueForKey:@"value"] boolValue];
//		prefData.ToResizeImage = [[[_errorcell control] valueForKey:@"value"] boolValue];	
		prefData.ToFitScreen = [[[_fitscrcell control] valueForKey:@"value"] boolValue];	
		prefData.GravitySlide = [[[_gravitycell control] valueForKey:@"value"] boolValue];	
		prefData.ButtonSlide = [[[_buttoncell control] valueForKey:@"value"] boolValue];	
		prefData.SwipeSlide = [[[_swipecell control] valueForKey:@"value"] boolValue];

	
		prefData.HideStatusbar = [[[_statusbarcell control] valueForKey:@"value"] boolValue];	
		int proposedSize = [[_buttonsizecell value] intValue];
		proposedSize = (proposedSize > MAX_RANGE_SIZE) ? MAX_RANGE_SIZE : proposedSize;
		proposedSize = (proposedSize < MIN_RANGE_SIZE) ? MIN_RANGE_SIZE : proposedSize;
		prefData.HitRange = proposedSize;


		proposedSize = [[_scrollspeedcell value] intValue];
		proposedSize = (proposedSize > MAX_SCROLL_SIZE) ? MAX_RANGE_SIZE : proposedSize;
		proposedSize = (proposedSize < MIN_SCROLL_SIZE) ? MIN_RANGE_SIZE : proposedSize;
		prefData.ScrollSpeed = proposedSize;

		SavePref();
		if( [_delegate respondsToSelector:@selector( prefsView:done: )] )
			[_delegate prefsView:self done:nil];
	}
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button {
	[sheet dismissAnimated:YES];
}

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)table
{
	return 3;
}

- (int)preferencesTable:(UIPreferencesTable *)table numberOfRowsInGroup:(int)group
{
	switch (group){
	case 0: 
		return 5;
	case 1:
		return 6;
	case 2: 
		return 1;
	}
}


- (float)preferencesTable:(id)table heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposedHeight;
{
	return 48.0f;
}

- (void)tableRowSelected:(NSNotification *)notification 
{
	int i = [_prefstable selectedRow];
  	switch (i)
	{
		default:
		[[_prefstable cellAtRow:i column:0] setSelected:NO];
		break;
	}
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)table cellForRow:(int)row inGroup:(int)group
{
	if (group == 0){
		if(row == 0)return _bouncecell;
		if(row == 1)return _migicell;
		if(row == 2)return _scalecell;
		if(row == 3)return _statusbarcell;
		if(row == 4)return _scrollspeedcell;
	} 
	else if(group == 1){
		if(row == 0)return _leftbtncell;
//		if(row == 1)return _errorcell;
		if(row == 1)return _fitscrcell;
		if(row == 2)return _buttonsizecell;
		if(row == 3)return _gravitycell;
		if(row == 4)return _buttoncell;
		if(row == 5)return _swipecell;
	}
	else if(group == 2){
		if(row == 0) return _segCell;
	}
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
	case 2:
		title = NSLocalizedString(@"Rotation", nil);
		break;
	}
	return title;
}

- (void) segmentedControl: (UISegmentedControl *)segment selectedSegmentChanged: (int)seg
{
	prefData.Rotation = seg;
}

@end

