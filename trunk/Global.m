#import"Global.h"
#define G  34943
#define DATA_DIR @"/private/var/root/Library/iComic/"
#define DATA_PATH "/private/var/root/Library/iComic/ComicData.dat"
#define PREFS_PATH "/private/var/root/Library/iComic/ComicPref.dat"

PreferenceData prefsData;
//char UIText[50][UITEXTLEN];
#define MAXBOOKS 1000
PageData pageData[MAXBOOKS];
char pageDataAccess[MAXBOOKS];

int PageDataCount = 0;

unsigned crc_code(int len, char *data)
{
    int i;
    unsigned d;
    unsigned bit;
    unsigned crc;
    d = 0;
    while (len-- > 0) d = ((d << 8) + *data++) % G;
    crc = 0;
    if ((d = (d << 16) % G) > 0) {
        for (i = 0, bit = 1; i < 16; i++, bit <<= 1) {
            if (((d + crc) ^ G) & bit) crc |= bit;
        }
    }
    return crc;
}

PageData GetPageData(char* fname)
{
	int i = 0;
	int crc = crc_code(strlen(fname), fname);
	for(i = 0; i < PageDataCount; i++)
	{
		if(pageData[i].crc == crc) return pageData[i];
	}
	PageData dummy;
	dummy.page = dummy.crc = 0;
	return dummy;
}

#define MAXPATHLEN 512

void InitPageData()
{
	LoadPageData();
	FindFileRecursively(COMICPATH);
	RefreshPageData();
}

void FindFileRecursively(NSString* _path)
{
        BOOL isDir;
        char buf[MAXPATHLEN];

	if([_path characterAtIndex: [_path length] - 1] != '/')
	{
		_path = [_path stringByAppendingString: @"/"];
	}
        
        
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *tempArray = [[NSArray alloc] 
	initWithArray:[fileManager directoryContentsAtPath:_path]];
	if ([fileManager fileExistsAtPath: _path] == NO) {
		return;
	}

        NSString *file;
        NSEnumerator *dirEnum = [tempArray objectEnumerator];
	while (file = [dirEnum nextObject]) 
	{
		file = [_path stringByAppendingString: file];
		NSLog(file);
		if ([fileManager fileExistsAtPath:file isDirectory:&isDir] && isDir)
		{
			FindFileRecursively(file);
		}
		else
		{
			[file getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
			AddPageData(buf);
		}
 	}
	[tempArray release];
}

void RefreshPageData()
{
	int i = 0 , j = 0;
	for(i = PageDataCount - 1; i >= 0; i--)
	{
		//削除された
		if(pageDataAccess[i] == 0)
		{
			for(j = i; i < PageDataCount; i++)
			{
				pageData[j] = pageData[j + 1];
				if(pageData[j].crc == 0) break;
			}
			pageData[PageDataCount - 1].crc = pageData[PageDataCount - 1].page = 0;
			PageDataCount --;
		}
	}
}

//ここでページデータを追加する。
//あったら、アクセスをオン、なかったら追加する。
void AddPageData(char *fname)
{
	int i = 0;
	int crc = crc_code(strlen(fname), fname);
	if(crc == 0) return;
	for(i = 0; i < PageDataCount; i++)
	{
		if(pageData[i].crc == crc)
		{
			pageDataAccess[i] = 1;
			return;
		}
	}
	if(PageDataCount == MAXBOOKS) return;
	
	//追加
	pageData[PageDataCount].crc = crc;
	pageData[PageDataCount].page = -2;
	pageDataAccess[PageDataCount] = 1;
	PageDataCount++;
	return;
}


void SetPageData(char* fname, int page)
{
	int i = 0;
	int crc = crc_code(strlen(fname), fname);
	for(i = 0; i < PageDataCount; i++)
	{
		if(pageData[i].crc == crc)
		{
			pageData[i].page = page;
			SavePageData();
			return;
		}
	}
	if(crc == 0) return;
	pageData[PageDataCount].crc = crc;
	pageData[PageDataCount].page = page;
	PageDataCount++;
	SavePageData();
	return;
}

/*
void RemovePageData(char* fname)
{
	int i = 0, j = 0;
	int crc = crc_code(strlen(fname), fname);
	for(i = 0; i < PageDataCount; i++)
	{
		if(pageData[i].crc == crc)
		{
			for(j = i; i < PageDataCount; i++)
			{
				pageData[j] = pageData[j + 1];
				if(pageData[j].crc == 0) break;
			}
			pageData[PageDataCount - 1].crc = pageData[PageDataCount - 1].page = 0;
			SavePageData();
			return;
		}
	}
	if(crc == 0) return;
	return;
}*/


void SavePageData()
{
	NSFileManager *myFile = [NSFileManager defaultManager];
	
	if(![myFile fileExistsAtPath: DATA_DIR])
		[myFile createDirectoryAtPath: DATA_DIR attributes:nil];

	int i = 0;
	FILE *pfile = fopen(DATA_PATH, "wb");
	if(pfile == 0) return;
	for(i = 0; i < PageDataCount; i++)
	{
		if(pageData[i].crc == 0) continue;
		fwrite(&pageData[i], 8, 1, pfile);
	}
	fclose(pfile);
}

void SavePrefs()
{
	FILE* pfile = fopen(PREFS_PATH, "wb");
	if(pfile != 0)
	{
		fwrite(&prefsData, sizeof(PreferenceData), 1, pfile);
		fclose(pfile);
	}
}

void LoadPageData()
{
	FILE *pfile = fopen(DATA_PATH, "rb");
	PageDataCount = 0;
	if(pfile != 0) 
	{
		while(feof(pfile) == 0)
		{
			fread(&pageData[PageDataCount], sizeof(PageData), 1, pfile);
			if(feof(pfile) != 0)break;
			PageDataCount++;
		}
		fclose(pfile);
	}
}

void LoadUIText()
{
	InitPageData();
	
	prefsData.IsScroll = YES;
	prefsData.ScrollSpeed = 97;
	prefsData.ToScrollRightTop = YES;
	prefsData.ToKeepScale = YES;
	prefsData.SlideDirection = NO;
	prefsData.HitRange = 48;
	prefsData.HideStatusbar = NO;
	prefsData.ToResizeImage = YES;
	prefsData.Rotation = 0;
	FILE *pfile = fopen(PREFS_PATH, "rb");
	if(pfile != 0)
	{
		fread(&prefsData, sizeof(PreferenceData), 1, pfile);
		fclose(pfile);
	}
}




