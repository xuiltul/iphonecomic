#import "Global.h"
#import "ZipFileBrowser.h"
#import "zlib/unzip.h"
#import <UIKit/UISimpleTableCell.h>

#define PAGE_LIST_MAX 1000

PageData pd;
bool Existlist;
int pageList[PAGE_LIST_MAX];

@implementation ZipFileBrowser 
- (id)initWithFrame:(struct CGRect)frame
{
	if ((self == [super initWithFrame: frame]) != nil) {
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
	_imageNowSet = [UIImage imageAtPath: [bundle pathForResource:@"imageNowSet" ofType:@"png"]];
	_imageSet = [UIImage imageAtPath: [bundle pathForResource:@"imageSet" ofType:@"png"]];
	
	Existlist = false;
	
	return self;
}

/******************************/
/*                            */
/******************************/
- (void)dealloc {
	[_path release];
	[_listpath release];
	[_files release];
	[_image release];
	[_imageNow release];
	[_imageNowSet release];
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
- (void)setPath:(NSString *)path
{
//NSLog(@"setPath");

	[_path release];
	_path = [path copy];

	[_listpath release];
	_listpath = [[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"lst"] copy];
	Existlist = false;
	NSFileManager *myFile = [NSFileManager defaultManager];
	if( [myFile fileExistsAtPath:_listpath] == YES ){
		Existlist = true;
	}
	[self reloadData];
}

/******************************/
/* ZIP内のファイル一覧を作成  */
/******************************/
- (void)reloadData
{
//NSLog(@"reloadData");

	//まずは開いて初めのファイルへ.
	char buf[MAXPATHLEN];
	[_path getCString:buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	unzFile zipfile = unzOpen(buf);
	unzGoToFirstFile(zipfile);

	pd = GetPageData(buf);

	//情報リストを作らないと。
	int ret = 0;
	NSArray *extensions = [NSArray arrayWithObjects:@"jpe",@"jpg",@"jpeg",@"tif",@"tiff",@"png",@"gif",@"bmp",@"img",nil];
	unz_global_info ugi;
	unzGetGlobalInfo(zipfile, &ugi);

//	NSLog(@"%d", ugi.number_entry);
	if(_files != nil){
		[_files release];
	}
	_files = [[NSMutableArray alloc] initWithCapacity: ugi.number_entry];
	while(ret == 0){
		unz_file_info ufi;
		unzGetCurrentFileInfo (zipfile, &ufi, buf, MAXPATHLEN, 0, 0, 0, 0);
		if(ufi.uncompressed_size == 0){
			ret = unzGoToNextFile(zipfile);
			 continue;
		}
		NSString *temp = [NSString stringWithCString: buf encoding:NSShiftJISStringEncoding];
//		NSLog(temp);
		if(temp == nil){
			ret = unzGoToNextFile(zipfile);
			continue;
		}
		NSString *extension = [[temp pathExtension] lowercaseString];
		if([extensions containsObject:extension]){
//NSLog(@"add");
			[_files addObject:temp];
		}
		ret = unzGoToNextFile(zipfile);
	}
	if(zipfile != 0) unzClose(zipfile);
	
	[_files sortUsingSelector: @selector (compare:)];
 	_rowCount = [_files count];

	//ページリストを読み込む
	pageList[0]=-1;
	if( Existlist == true ){
//NSLog(@"lst Hit!!");
		NSArray* _Arr = [NSArray arrayWithContentsOfFile:_listpath];
		int i, j=0;
		for(i=0; i<[_Arr count]; i++){
			int rowTemp;
			NSString* tmpString = [_Arr objectAtIndex:i];
//NSLog(tmpString);
			if( [tmpString length] < 4 ){
				pageList[j++] = [tmpString intValue];
			}
			else{
				pageList[j++] = [[tmpString substringToIndex:4] intValue];
			}
			if( j>(PAGE_LIST_MAX-2) ) break;
		}
		pageList[j]=-1;
	}
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
	[cell setTitle:[[_files objectAtIndex:row] lastPathComponent]];
//NSLog(@"table cellForRow:%d Okini:%d",row,pd.page);

	int i=0;
	while( pageList[i] != -1 ){
		if( pageList[i] == row ){
			break;
		}
		i++;
	}
	if( pageList[i] != -1 ){
		if( pd.page == row ){
			[cell setImage:_imageNowSet];
		}
		else{
			[cell setImage:_imageSet];
		}
	}
	else{
		if( pd.page == row ){
			[cell setImage:_imageNow];
		}
		else{
			[cell setImage:_image];
		}
	}
	[[cell iconImageView] setFrame:CGRectMake(-10,0,32,32)];
	[cell setDisclosureStyle:1];

	return cell;
}

/******************************/
/*                            */
/******************************/
- (void)tableRowSelected:(NSNotification *)notification {
	if( [_delegate respondsToSelector:@selector( zipFileBrowser:fileSelected: )] )
		[_delegate zipFileBrowser:self fileSelected: [_table selectedRow]];
}

/******************************/
/*                            */
/******************************/
- (void)table:(UITable *)table disclosureClickedForRow:(int)row
{
	NSMutableArray* wArr = [[[NSMutableArray alloc] init] autorelease];
//NSLog(@"disclosureClickedForRow:%d", row);

	if( Existlist == true ){
		wArr = [NSMutableArray arrayWithContentsOfFile:_listpath];
//NSLog(@"count:%d", [wArr count]);
		int i;
		for(i=0; i<[wArr count]; i++){
			int rowTemp;
			NSString* tmpString = [wArr objectAtIndex:i];
//NSLog(tmpString);
			if( [tmpString length] < 4 ){
				rowTemp = [tmpString intValue];
			}
			else{
				rowTemp = [[tmpString substringToIndex:4] intValue];
			}
			if( rowTemp == row ){
				break;
			}
		}
		if( i!=[wArr count] ){
//NSLog(@"removeObjectAtIndex");
			[wArr removeObjectAtIndex:i];
		}
		else{
//NSLog(@"addObject 1");
			[wArr addObject:[NSString stringWithFormat:@"%4d", row]];
		}
	}
	else{
//NSLog(@"addObject 2");
		[wArr addObject:[NSString stringWithFormat:@"%4d", row]];
	}
	[wArr sortUsingSelector: @selector (compare:)];

	if([wArr writeToFile:[_listpath stringByExpandingTildeInPath] atomically:YES]){
		Existlist = true;
//NSLog(@"write complete");
	}
//	[wArr release];
	[self reloadData];
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
//NSLog(@"table_scroll %d",pd.page);
	[_table scrollRowToVisible:(pd.page>0 ? pd.page : 0)];
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

///******************************/
///*                            */
///******************************/
//- (BOOL)table:(UITable *)table showDisclosureForRow:(int)row
//{
//	return YES;
//}
//
///******************************/
///*                            */
///******************************/
//- (BOOL)table:(UITable *)table setDisclosureClickable:(int)row
//{
//	return YES;
//}
//
///******************************/
///*                            */
///******************************/
//- (BOOL)table:(UITable *)table disclosureClickableForRow:(int)row
//{
//	return YES;
//}

@end

