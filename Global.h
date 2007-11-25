#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#define UITEXTLEN 1000
#define COMICPATH @"/var/root/Media/Comic/"
#define MAXPATHLEN 512
//#define MAKEUITEXT(a) [NSString stringWithCString: UIText[a] encoding:NSUTF8StringEncoding]
typedef struct PageDataS
{
	int crc;
	
	// -2 ... 読んでない
	// -1 ... 読んだ
	// 0,1,2,3,4,...　読んでる
	int page;
} PageData;

typedef struct PreferenceDataS
{
	int Version;
	BOOL IsScroll;
	int ScrollSpeed;
	BOOL ToScrollRightTop;
	BOOL ToKeepScale;
	BOOL SlideDirection;
	int HitRange;
	BOOL ToResizeImage;
	BOOL HideStatusbar;
	int Rotation;
	BOOL GravitySlide;
	BOOL ButtonSlide;
	BOOL SwipeSlide;
} PreferenceData;

extern PreferenceData prefsData;

extern void LoadUIText();
//extern char UIText[][UITEXTLEN];

extern int IsViewingComic;
extern PageData GetPageData(char* fname);
extern void SetPageData(char* fname, int page);
//extern void RemovePageData(char* fname);
extern void SavePrefs();
extern void SavePageData();
extern void RefreshPageData();
extern void AddPageData(char *fname);
extern void LoadPageData();
void FindFileRecursively(NSString* _path);





