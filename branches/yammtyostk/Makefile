CC=arm-apple-darwin-gcc
LD=$(CC)
#CFLAGS=-O
LDFLAGS=-lobjc \
	-framework CoreFoundation \
	-framework Foundation \
	-framework UIKit \
	-framework LayerKit \
	-framework CoreGraphics \
	-framework GraphicsServices \
	-framework CoreSurface \
	-framework CoreAudio \
	-framework IOKit \
	-framework AudioToolbox \
	-larmfp 

APPNAME=iComic
FILES=mainapp.o Application.o FileBrowser.o \
ImageView.o ScrollImage.o Global.o PrefsView.o \
FileList.o \
zlib/ioapi.o zlib/unzip.o zlib/libz.a 

all:    $(APPNAME) package

$(APPNAME):  $(FILES)

	$(LD) $(LDFLAGS) -v -o $@ $^

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
	cp Japanese.lproj/*.strings $(APPNAME).app/Japanese.lproj/
	cp ReadMe $(APPNAME).app/ReadMe

debug: $(APPNAME) package

