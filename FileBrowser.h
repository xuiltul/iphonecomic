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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileBrowser : UIView 
{
	NSMutableArray *_extensions;
	NSMutableArray *_files;
	NSMutableArray *_fileview;
	UITable *_table;
	NSString *_path;
	int _rowCount;
	id _delegate;
	UIImage *_folder;
	UIImage *_books, *_booksf, *_bookss;
}

- (id)initWithFrame:(CGRect)rect;
- (NSString *)path;
- (void)setPath: (NSString *)path;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (void)tableRowSelected:(NSNotification *)notification;
- (NSString *)selectedFile;
- (void)setExtensions:(NSArray *)extensions;

@end
