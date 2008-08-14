#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PageBrowser:UIView
{
	NSMutableArray*	_files;
	UITable*		_table;
	NSString*		_path;
	int				_rowCount;
	id				_delegate;
	UIImage			*_imageSet, *_imageNow, *_image;
}

- (id)initWithFrame:(CGRect)rect;
- (NSString *)path;
- (void)setPath: (NSString *)path;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (void)tableRowSelected:(NSNotification *)notification;
- (void)table_scroll;

@end
