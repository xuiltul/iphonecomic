#import"PrefsView.h"
#import"Global.h"

@implementation PrefsView 
- (id)initWithFrame:(struct CGRect)frame
{
	[super initWithFrame:frame];
	
	_navbar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)] autorelease];
	[_navbar showLeftButton:nil withStyle:0 rightButton:MAKEUITEXT(6) withStyle:3]; // Blue Done button
	[_navbar setBarStyle:0];
	[_navbar setDelegate:self]; 
	[self addSubview:_navbar];

	UINavigationItem *title = [[UINavigationItem alloc] 
				    initWithTitle:[NSString stringWithCString: UIText[5] encoding:NSUTF8StringEncoding]];
	[_navbar pushNavigationItem:[title autorelease]];

	_prefstable = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, frame.size.height - 48.0f)];	
	[_prefstable setDataSource:self];
	[_prefstable setDelegate:self];
	[_prefstable reloadData];
	[self addSubview:_prefstable];
	
	_scrollcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_scrollcell setTitle:MAKEUITEXT(8)];
	UISwitchControl *scrollSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scrollSwitch setValue:prefsData.IsScroll];
	[_scrollcell setControl:scrollSwitch];


	_statusbarcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_statusbarcell setTitle:MAKEUITEXT(15)];
	UISwitchControl *statusSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[statusSwitch setValue:prefsData.HideStatusbar];
	[_statusbarcell setControl:statusSwitch];

	 
	_migicell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_migicell setTitle:MAKEUITEXT(9)];
	UISwitchControl *migiSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[migiSwitch setValue:prefsData.ToScrollRightTop];
	[_migicell setControl:migiSwitch];
	 
	_scalecell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_scalecell setTitle:MAKEUITEXT(10)];
	UISwitchControl *scaleSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[scaleSwitch setValue:prefsData.ToKeepScale];
	[_scalecell setControl:scaleSwitch];
	 
	 
	_directioncell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_directioncell setTitle:MAKEUITEXT(13)];
	UISwitchControl *directionSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[directionSwitch setValue:prefsData.SlideDirection];
	[_directioncell setControl:directionSwitch];


	_errorcell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 48.0f)];
	[_errorcell setTitle:MAKEUITEXT(14)];
	UISwitchControl *errorSwitch = [[[UISwitchControl alloc] initWithFrame:CGRectMake(frame.size.width - 114.0, 11.0f, 114.0f, 48.0f)] autorelease];
	[errorSwitch setValue:prefsData.ToResizeImage];
	[_errorcell setControl:errorSwitch];
	
	

	//UIPreferencesTextTableCell *_scrollspeedcell;
	//UIPreferencesTextTableCell *_statusbarcell;
	_buttonsizecell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	NSString	*str = [NSString stringWithFormat:@"%d", prefsData.HitRange];
	[_buttonsizecell setValue:str];
	[_buttonsizecell setTitle:MAKEUITEXT(12)];

	_scrollspeedcell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, frame.size.width, 48.0f)];
	[_scrollspeedcell setValue:[NSString stringWithFormat:@"%d", (int)prefsData.ScrollSpeed]];
	[_scrollspeedcell setTitle:MAKEUITEXT(16)];
//	UIPreferencesTextTableCell *_buttonsizecell;
	 
	return self;
}

- (void)setDelegate : (id) dele
{
	_delegate = dele;
//	[super setDelegate: dele];
}
#define MAX_RANGE_SIZE 160
#define MIN_RANGE_SIZE 48
#define MAX_SCROLL_SIZE 100
#define MIN_SCROLL_SIZE 1

//------------------------delegate
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	prefsData.IsScroll = [[[_scrollcell control] valueForKey:@"value"] boolValue];
	prefsData.ToScrollRightTop = [[[_migicell control] valueForKey:@"value"] boolValue];
	prefsData.ToKeepScale = [[[_scalecell control] valueForKey:@"value"] boolValue];
	prefsData.SlideDirection = [[[_directioncell control] valueForKey:@"value"] boolValue];
	prefsData.ToResizeImage = [[[_errorcell control] valueForKey:@"value"] boolValue];	
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

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)table
{
	return 2;
}

- (int)preferencesTable:(UIPreferencesTable *)table numberOfRowsInGroup:(int)group
{
	switch (group)
	{
		case 0: 
			return 5;	
		case 1:
			return 3;
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
	}
	return nil;
}

- (id)preferencesTable:(id)preferencesTable titleForGroup:(int)group
{
	NSString *title = nil;
	switch (group)
	{
	case 0:
		title = MAKEUITEXT(7);//,  [lines objectAtIndex:4];
		break;
	case 1:
		title = MAKEUITEXT(11);
	}
	return title;
}

@end

