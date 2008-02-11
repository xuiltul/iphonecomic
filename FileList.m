#import "FileList.h"
#import "zlib/unzip.h"
#import <UIKit/UISimpleTableCell.h>
#define MAXPATHLEN 512

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

	return self;
}

- (void)dealloc {
	[_path release];
	[_files release];
	_delegate = nil;
	[super dealloc];
}

- (NSString *)path {
	return [[_path retain] autorelease];
}

- (void)setPath: (NSString *)path {
	[_path release];
	_path = [path copy];

	[self reloadData];
}

/******************************/
/* ZIP内のファイル一覧を作成  */
/******************************/
- (void)reloadData {
	BOOL isDir;

	//まずは開いて初めのファイルへ.
	char buf[MAXPATHLEN];
	[_path getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
	unzFile zipfile = unzOpen(buf);
	unzGoToFirstFile(zipfile);

	//情報リストを作らないと。
	int ret = 0;
	unz_global_info ugi;
	unzGetGlobalInfo(zipfile, &ugi);

//	NSLog(@"%d", ugi.number_entry);
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
		if(temp != nil){
			[_files addObject:temp];
		}
		ret = unzGoToNextFile(zipfile);
	}
	
	[_files sortUsingSelector: @selector (compare:)];

 	_rowCount = [_files count];
	[_table reloadData];
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
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	BOOL isDir = NO;

	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];
	[cell setTitle: [[_files objectAtIndex:row] lastPathComponent]];
	return cell;
}

/******************************/
/*                            */
/******************************/
- (void)tableRowSelected:(NSNotification *)notification {
//	NSLog([self selectedFile]);
	if( [_delegate respondsToSelector:@selector( zipFileBrowser:fileSelected: )] )
		[_delegate zipFileBrowser:self fileSelected: [_table selectedRow]];
}

@end


