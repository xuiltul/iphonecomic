#import"Global.h"
#define G  34943
#define DATA_DIR @"/private/var/root/Library/iComic/"
#define DATA_PATH "/private/var/root/Library/iComic/ComicData.dat"
#define PREFS_PATH "/private/var/root/Library/iComic/ComicPref.dat"

PreferenceData prefsData;
//char UIText[50][UITEXTLEN];
PageData pageData[200];
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
}


void SavePageData()
{
	NSFileManager *myFile = [NSFileManager defaultManager];
	
	//[myFile changeCurrentDirectoryPath: @"/private/var/root/Library/"];
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

void LoadUIText()
{
/*
	int i = 0;
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *tempstr;
	tempstr = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"uitext" ofType:@""]] encoding:NSUTF8StringEncoding] autorelease];
	NSArray *lines = [tempstr componentsSeparatedByString:@","];
	for(i = 0; i < [lines count]; i++)
	{
		[[lines objectAtIndex: i] getCString: UIText[i] maxLength: UITEXTLEN encoding:NSUTF8StringEncoding];
	}*/
	
	
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
	
	prefsData.IsScroll = YES;
	prefsData.ScrollSpeed = 97;
	prefsData.ToScrollRightTop = YES;
	prefsData.ToKeepScale = YES;
	prefsData.SlideDirection = NO;
	prefsData.HitRange = 48;
	prefsData.HideStatusbar = NO;
	prefsData.ToResizeImage = YES;
	prefsData.Rotation = 0;
	pfile = fopen(PREFS_PATH, "rb");
	if(pfile != 0)
	{
		fread(&prefsData, sizeof(PreferenceData), 1, pfile);
		fclose(pfile);
	}
}




