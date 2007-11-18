#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#define UITEXTLEN 1000
//#define MAKEUITEXT(a) [NSString stringWithCString: UIText[a] encoding:NSUTF8StringEncoding]
typedef struct PageDataS
{
	int crc;
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
} PreferenceData;

extern PreferenceData prefsData;

extern void LoadUIText();
//extern char UIText[][UITEXTLEN];


extern PageData GetPageData(char* fname);
extern void SetPageData(char* fname, int page);
extern void RemovePageData(char* fname);
extern void SavePrefs();
extern void SavePageData();


