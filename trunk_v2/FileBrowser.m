/*

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#import "FileBrowser.h"
#import "zlib/unzip.h"
#import "Global.h"
#import <UIKit/UISimpleTableCell.h>

int HitRow;

@implementation FileBrowser 
- (id)initWithFrame:(struct CGRect)frame{
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
		_fileview = [[NSMutableArray alloc] init];
		_rowCount = 0;

		_delegate = nil;

		[self addSubview: _table];
	}
	_nowfile = NULL;

	NSBundle *bundle = [NSBundle mainBundle];
	_folder = [UIImage imageAtPath: [bundle pathForResource:@"folder" ofType:@"png"]];
	_books = [UIImage imageAtPath: [bundle pathForResource:@"folderZip" ofType:@"png"]];
	_bookss = [UIImage imageAtPath: [bundle pathForResource:@"folderNow" ofType:@"png"]];
	_booksf = [UIImage imageAtPath: [bundle pathForResource:@"folderEnd" ofType:@"png"]];
	return self;
}

/******************************/
/*                            */
/******************************/
- (void)dealloc {
	[_path release];
	[_files release];
	[_fileview release];
	[_table release];
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
	BOOL isDir;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *tempArray = [[NSArray alloc] initWithArray:[fileManager directoryContentsAtPath:_path]];

	if ([fileManager fileExistsAtPath:_path] == NO){
		return;
	}
//NSLog(@"**** reloadData ****");
//NSLog(_nowfile);
//NSLog(@"tmpFile=%s",tmpFile);
//NSLog(@"tmpLastFile=%s",tmpLastFile);

	NSString *file;
	NSMutableString *title;
	NSArray *extensions = [NSArray arrayWithObjects:@"cbz", @"zip", @"", nil];
	NSString* filetmpFile = [[NSString stringWithCString:tmpLastFile encoding:NSUTF8StringEncoding]lastPathComponent];

//NSLog(filetmpFile);

	[_files removeAllObjects];
	[_fileview removeAllObjects];

	int countRow=0;
	HitRow=0;
	NSEnumerator *dirEnum = [tempArray objectEnumerator];
	while (file = [dirEnum nextObject]) {
		NSString *extension = [[file pathExtension] lowercaseString];
		if ([extensions containsObject:extension]) {
			[_files addObject: file];
			NSLog(file);
			if( [file isEqualToString:filetmpFile] ){
				HitRow = countRow;
				NSLog(@"Hit!=%d",HitRow);
			}
			title = [NSMutableString stringWithString:file];
			CFStringNormalize((CFMutableStringRef)title, kCFStringNormalizationFormC);
			[_fileview addObject:title];
			countRow++;
		}
 	}
	_rowCount = [_files count];
	[_table reloadData];
	[tempArray release];
	
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
/* ZIPファイルの一覧を作成    */
/******************************/
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	BOOL isDir = NO;
	char buf0[MAXPATHLEN];
	
	UIImageAndTextTableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	[cell setTitle: [[_fileview objectAtIndex: row] stringByDeletingPathExtension]];
	NSString* path0 = [_path copy];
	if([_path characterAtIndex: [_path length] - 1] != '/'){
		[path0 release];
		path0 = [_path stringByAppendingString: @"/"];
	}
	NSString *file = [path0 stringByAppendingString:[_files objectAtIndex:row]];
//NSLog(file);

	//ディレクトリの場合
	if ([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] && isDir){
		[cell setShowDisclosure:YES];
		[cell setImage: _folder];
		[[cell iconImageView] setFrame:CGRectMake(-10,0,32,32)];
	}
//	else if(0){
//		//zipから表紙？をとってくる
//		[file getCString: buf0 maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
//		unzFile zipfile = unzOpen(buf0);	
//		if(zipfile == 0) return cell;
//		unzGoToFirstFile(zipfile);
//		
//		unz_file_info ufi;
//		unzGetCurrentFileInfo(zipfile, &ufi, 0, 0, 0, 0, 0, 0);
//		//2MB以上はあきらめる
//		if(ufi.uncompressed_size > 1024 * 1024 * 2) return;
//
//		char *buf = (char*)malloc(ufi.uncompressed_size + 128);
//		unzOpenCurrentFile(zipfile);
//		int read = unzReadCurrentFile(zipfile, buf, ufi.uncompressed_size);
//		unzCloseCurrentFile(zipfile);
//		unzClose(zipfile);
//		UIImage *image = [[UIImage alloc] initWithData: [NSData dataWithBytes:buf length:read] cache: true];
//		free(buf);
//		struct CGImage *coverRef = [image imageRef];
//		int height = CGImageGetHeight(coverRef);
//		int width = CGImageGetWidth(coverRef);
//		if (height >= width)
//		{
//			float frac = (float)width / height;
//			width = (int)(46*frac);
//			height = 46;
//		}
//		else
//		{
//			float frac = (float)height / width;
//			height = (int)(46*frac);
//			width = 46;
//		}
//		 [cell setImage:image];
//		 [[cell iconImageView] setFrame:CGRectMake(-10,0,width,height)];
//
//		//[cell setImage: ];
//	}
	//ZIPファイルの場合
	else{
		[file getCString:buf0 maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
		int t = GetPageData(buf0).page;
		if(t == -1)
			[cell setImage: _booksf];
		else if(t == -2){
			[cell setImage: _books];
		}
		else
			[cell setImage: _bookss];
			
		[[cell iconImageView] setFrame:CGRectMake(-10,0,32,32)];
		[cell setDisclosureStyle:1];
	}

	return cell;
}

/******************************/
/*                            */
/******************************/
- (void)tableRowSelected:(NSNotification *)notification {
	if( [_delegate respondsToSelector:@selector( fileBrowser:fileSelected: )] )
		[_delegate fileBrowser:self fileSelected:[self selectedFile]];
}

/******************************/
/*                            */
/******************************/
- (NSString *)selectedFile
{
//NSLog(@"selectedFile");
	if ([_table selectedRow] == -1)
		return nil;
	return [_path stringByAppendingPathComponent: [_files objectAtIndex: [_table selectedRow]]];
}

- (NSString *)selectedFileNext
{
//NSLog(@"selectedFileNext");
	if ((HitRow+1) >= [_files count]){
//NSLog(@"nil! %d %d", HitRow, [_files count]);
		return nil;
	}
//	NSLog(@"here!");
	return [_path stringByAppendingPathComponent: [_files objectAtIndex: (HitRow+1)]];
}

/******************************/
/*                            */
/******************************/
- (void)setSelectFile:(NSString *)file
{
//NSLog(@"FileBrowser setSelectFile");
	_nowfile = [file copy];
//NSLog(_nowfile);
}

/******************************/
/*                            */
/******************************/
- (void)table_scroll
{
//NSLog(@"table_scroll");
	[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(table_scroll_end:) userInfo:self repeats:NO];
}

- (void)table_scroll_end:(NSTimer*)timer
{
//NSLog(@"table_scroll_end");
	[_table scrollRowToVisible:0];
	if( isShowImage == YES ){
		[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(table_scroll_goImage:) userInfo:self repeats:NO];
	}
}

- (void)table_scroll_goImage:(NSTimer*)timer
{
	isShowImage = NO;
//NSLog(@"table_scroll_goImage");
	if( ((HitRow+1) >= [_files count]) || !prefData.IsNextZip ){
//NSLog(@"nil!2 %d %d", HitRow, [_files count]);
		return;
	}
	if( [_delegate respondsToSelector:@selector( fileBrowser:fileSelected: )] )
		[_delegate fileBrowser:self fileSelected:[self selectedFileNext]];
}


@end


