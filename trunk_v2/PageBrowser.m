#import "Global.h"
#import "PageBrowser.h"
#import <UIKit/UISimpleTableCell.h>

@implementation PageBrowser
- (id)initWithFrame:(struct CGRect)frame
{
	if((self == [super initWithFrame: frame]) != nil){
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"FileName"
			identifier:@"filename"
			width: frame.size.width
		];

		_table = [[UITable alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[_table addTableColumn: col];
		[_table setSeparatorStyle: 1];
		[_table setDelegate: self];
		[_table setDataSource: self];

		_files = [[NSMutableArray alloc] init];
		_rowCount = 0;

		_delegate = nil;

		[self addSubview: _table];
	}

	NSBundle *bundle = [[NSBundle mainBundle] autorelease];
	_image = [UIImage imageAtPath: [bundle pathForResource:@"image" ofType:@"png"]];
	_imageNow = [UIImage imageAtPath: [bundle pathForResource:@"imageNow" ofType:@"png"]];
	_imageSet = [UIImage imageAtPath: [bundle pathForResource:@"imageSet" ofType:@"png"]];

	return self;
}

/******************************/
/*                            */
/******************************/
- (void)dealloc {
	[_path release];
	[_files release];
	[_image release];
	[_imageNow release];
	[_imageSet release];
	_delegate = nil;

	[super dealloc];
}

/******************************/
/*                            */
/******************************/
- (NSString *)path {
	return [[_path retain] autorelease];
}

/******************************/
/*                            */
/******************************/
- (void)setPath: (NSString *)path {
	[_path release];
	_path = [path copy];

	[self reloadData];
}

/******************************/
/*                            */
/******************************/
- (void)reloadData
{
	[_files removeAllObjects];
	[_files addObject:NSLocalizedString(@"Start with saved position last", nil)];
	[_files addObject:NSLocalizedString(@"Page List", nil)];

	NSString* tmplist = [[[NSString stringWithCString:tmpFile encoding:NSUTF8StringEncoding]
								stringByDeletingPathExtension] stringByAppendingPathExtension:@"lst"];
//NSLog(@"pageBrowser reload");
//NSLog(tmplist);
	
	NSFileManager *myFile = [NSFileManager defaultManager];
	if([myFile fileExistsAtPath:tmplist]){
//NSLog(@"lst Hit!!");
		[_files addObjectsFromArray:[NSMutableArray arrayWithContentsOfFile:tmplist]];
	}
	_rowCount = [_files count];
	[_table reloadData];
	[[_table cellAtRow:[_table selectedRow]column:0] setSelected:FALSE withFade:FALSE];
}

/******************************/
/*                            */
/******************************/
- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

/******************************/
/*                            */
/******************************/
- (int)numberOfRowsInTable:(UITable *)table {
	return _rowCount;
}

/******************************/
/*                            */
/******************************/
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col
{
	UIImageAndTextTableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	[cell setTitle:[_files objectAtIndex:row]];

	switch(row){
	case 0:
		[cell setImage: _imageNow];
		break;
	case 1:
		[cell setImage: _image];
		break;
	default:
		[cell setImage: _imageSet];
		break;
	}
	[[cell iconImageView] setFrame:CGRectMake(-10,0,32,32)];

	return cell;
}

/******************************/
/*                            */
/******************************/
- (void)tableRowSelected:(NSNotification *)notification
{
	int rowTemp =  [_table selectedRow];
	if( rowTemp == 0 ){
		rowTemp = 9999;
	}
	else if( rowTemp == 1 ){
		rowTemp = 9998;
	}
	else{
		NSString* tmpString = [_files objectAtIndex:[_table selectedRow]];
//NSLog(tmpString);
		if( [tmpString length] < 4 ){
			rowTemp = [tmpString intValue];
		}
		else{
			rowTemp = [[tmpString substringToIndex:4] intValue];
		}
	}
	if( [_delegate respondsToSelector:@selector( pageBrowser:fileSelected: )] )
		[_delegate pageBrowser:self fileSelected:rowTemp];
}

/******************************/
/*                            */
/******************************/
- (void)table_scroll
{
	[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(table_scroll_end:) userInfo:self repeats:NO];
}

- (void)table_scroll_end:(NSTimer*)timer
{
//NSLog(@"table_scroll 0");
	[_table scrollRowToVisible:0];
	if( isShowImage == YES ){
		[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(table_scroll_goBack:) userInfo:self repeats:NO];
	}
}

- (void)table_scroll_goBack:(NSTimer*)timer
{
//NSLog(@"table_scroll_goBack");
	if( [_delegate respondsToSelector:@selector( goBackNavigation )] )
		[_delegate goBackNavigation];
}

@end
