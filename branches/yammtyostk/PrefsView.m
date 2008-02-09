#import"PrefsView.h"
#import"Global.h"

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

	UINavigationItem *title = [[UINavigationItem alloc] 
				    initWithTitle: NSLocalizedString(@"Settings", nil)];
	[_navbar pushNavigationItem:[title autorelease]];

	_prefstable = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, frame.size.height - 48.0f)];	
	[_prefstable setDataSource:self];
	[_prefstable setDelegate:self];
	[_prefstable reloadData];
	[self addSubview:_prefstable];
	
	_scrollcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_scrollcell setTitle:NSLocalizedString(@"Bounce", nil)];
	UISwitchControl *scrollSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scrollSwitch setValue:prefsData.IsScroll];
	[_scrollcell setControl:scrollSwitch];


	_statusbarcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_statusbarcell setTitle:NSLocalizedString(@"Hide status bar", nil)];
	UISwitchControl *statusSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[statusSwitch setValue:prefsData.HideStatusbar];
	[_statusbarcell setControl:statusSwitch];

	 
	_migicell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_migicell setTitle:NSLocalizedString(@"Move to top right", nil)];
	UISwitchControl *migiSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[migiSwitch setValue:prefsData.ToScrollRightTop];
	[_migicell setControl:migiSwitch];
	 
	_scalecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_scalecell setTitle:NSLocalizedString(@"Keep scale", nil)];
	UISwitchControl *scaleSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scaleSwitch setValue:prefsData.ToKeepScale];
	[_scalecell setControl:scaleSwitch];
	 
	 
	_directioncell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_directioncell setTitle:NSLocalizedString(@"Slide to right", nil)];
	UISwitchControl *directionSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[directionSwitch setValue:prefsData.SlideDirection];
	[_directioncell setControl:directionSwitch];


	_errorcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_errorcell setTitle:NSLocalizedString(@"Resize big image", nil)];
	UISwitchControl *errorSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[errorSwitch setValue:prefsData.ToResizeImage];
	[_errorcell setControl:errorSwitch];
	
	_gravitycell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_gravitycell setTitle:NSLocalizedString(@"Gravity page slide", nil)];
	UISwitchControl *gravitySwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[gravitySwitch setValue:prefsData.GravitySlide];
	[_gravitycell setControl:gravitySwitch];
	
	_buttoncell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_buttoncell setTitle:NSLocalizedString(@"Button page slide", nil)];
	UISwitchControl *buttonSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[buttonSwitch setValue:prefsData.ButtonSlide];
	[_buttoncell setControl:buttonSwitch];
	
	_swipecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_swipecell setTitle:NSLocalizedString(@"Swipe page slide", nil)];
	UISwitchControl *swipeSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[swipeSwitch setValue:prefsData.SwipeSlide];
	[_swipecell setControl:swipeSwitch];
			

	//UIPreferencesTextTableCell *_scrollspeedcell;
	//UIPreferencesTextTableCell *_statusbarcell;
	_buttonsizecell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	NSString	*str = [NSString stringWithFormat:@"%d", prefsData.HitRange];
	[_buttonsizecell setValue:str];
	[_buttonsizecell setTitle:NSLocalizedString(@"Button size(48-160)", nil)];

	_scrollspeedcell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	[_scrollspeedcell setValue:[NSString stringWithFormat:@"%d", (int)prefsData.ScrollSpeed]];
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
	[_segCtrl selectSegment: prefsData.Rotation];
	 
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
	[_scrollcell release];
	[_scrollspeedcell release];
	[_statusbarcell release];
	[_migicell release];
	[_scalecell release];
	[_buttonsizecell release];
	[_directioncell release];
	[_errorcell release];

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
		prefsData.IsScroll = [[[_scrollcell control] valueForKey:@"value"] boolValue];
		prefsData.ToScrollRightTop = [[[_migicell control] valueForKey:@"value"] boolValue];
		prefsData.ToKeepScale = [[[_scalecell control] valueForKey:@"value"] boolValue];
		prefsData.SlideDirection = [[[_directioncell control] valueForKey:@"value"] boolValue];
		prefsData.ToResizeImage = [[[_errorcell control] valueForKey:@"value"] boolValue];	
		prefsData.GravitySlide = [[[_gravitycell control] valueForKey:@"value"] boolValue];	
		prefsData.ButtonSlide = [[[_buttoncell control] valueForKey:@"value"] boolValue];	
		prefsData.SwipeSlide = [[[_swipecell control] valueForKey:@"value"] boolValue];

	
		prefsData.HideStatusbar = [[[_statusbarcell control] valueForKey:@"value"] boolValue];	
		int proposedSize = [[_buttonsizecell value] intValue];
		proposedSize = (proposedSize > MAX_RANGE_SIZE) ? MAX_RANGE_SIZE : proposedSize;
		proposedSize = (proposedSize < MIN_RANGE_SIZE) ? MIN_RANGE_SIZE : proposedSize;
		prefsData.HitRange = proposedSize;


		proposedSize = [[_scrollspeedcell value] intValue];
		proposedSize = (proposedSize > MAX_SCROLL_SIZE) ? MAX_RANGE_SIZE : proposedSize;
		proposedSize = (proposedSize < MIN_SCROLL_SIZE) ? MIN_RANGE_SIZE : proposedSize;
		prefsData.ScrollSpeed = proposedSize;

		SavePrefs();
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
	switch (group)
	{
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
	if (group == 0)
	{
		if(row == 0)return _scrollcell;
		if(row == 1)return _migicell;
		if(row == 2)return _scalecell;
		if(row == 3)return _statusbarcell;
		if(row == 4)return _scrollspeedcell;
	} 
	else if(group == 1)
	{
		if(row == 0)return _directioncell;
		if(row == 1)return _errorcell;
		if(row == 2)return _buttonsizecell;
		if(row == 3)return _gravitycell;
		if(row == 4)return _buttoncell;
		if(row == 5)return _swipecell;
	}
	else if(group == 2)
	{
		if(row == 0) return _segCell;
	}
	return nil;
}

- (id)preferencesTable:(id)preferencesTable titleForGroup:(int)group
{
	NSString *title = nil;
	switch (group)
	{
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
	prefsData.Rotation = seg;
}

@end

