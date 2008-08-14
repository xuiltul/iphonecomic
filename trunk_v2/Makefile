CC=arm-apple-darwin9-gcc
LD=$(CC)
CFLAGS=-DMOBILE -DVer2 -I/var/include
#CFLAGS=-O
LDFLAGS=-lobjc \
	-framework CoreFoundation \
	-framework Foundation \
	-framework UIKit \
	-framework CoreGraphics \
	-framework GraphicsServices \
	-framework CoreSurface \
	-framework CoreAudio \
	-framework IOKit \
	-framework AudioToolbox \
	-L"/usr/lib" \
	-F"/System/Library/Frameworks" \
	-F"/System/Library/PrivateFrameworks" \
	-bind_at_load 

APPNAME=iComic
FILES=mainapp.o Application.o FileBrowser.o \
ImageView.o ScrollImage.o Global.o PrefsView.o \
ZipFileBrowser.o PageBrowser.o \
zlib/ioapi.o zlib/unzip.o zlib/libz.a

all:    $(APPNAME) package

$(APPNAME):  $(FILES)

	$(LD) $(LDFLAGS) -v -o $@ $^
	/usr/bin/ldid -S $(APPNAME)

%.o:    %.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o *~ $(APPNAME) $(APPNAME).app

package: $(APPNAME)
	rm -fr $(APPNAME).app
	mkdir -p $(APPNAME).app
	mkdir -p $(APPNAME).app/Japanese.lproj
	mv $(APPNAME) $(APPNAME).app/$(APPNAME)
	cp Info.plist $(APPNAME).app/Info.plist
	cp *.png $(APPNAME).app/
	cp *.dat $(APPNAME).app/
	cp Japanese.lproj/*.strings $(APPNAME).app/Japanese.lproj/

debug: $(APPNAME) package

