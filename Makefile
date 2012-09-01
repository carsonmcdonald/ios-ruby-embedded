MRUBYLIB := mruby/lib/libmruby_core.a
IOSLIB := tmp/lib/mruby-ios.a
IOSSIMLIB := tmp/lib/mruby-iosi386.a
IOSDEVLIB := tmp/lib/mruby-iosarm7.a
XCODEROOT := `xcode-select -print-path`
SIMSDKPATH := "$(XCODEROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.1.sdk/"
IOSSDKPATH := "$(XCODEROOT)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk/"
IOSSIMCC := xcrun -sdk iphoneos llvm-gcc-4.2 -arch i386 -isysroot $(SIMSDKPATH)
IOSDEVCC := xcrun -sdk iphoneos llvm-gcc-4.2 -arch armv7 -isysroot $(IOSSDKPATH)
PLATFORMCC := gcc
PLATFORMLL := gcc

export CP := cp
export RM_F := rm -f
export CAT := cat

# compiler, linker (gcc)
DEBUG_MODE = 1
ifeq ($(DEBUG_MODE),1)
CFLAGS = -g -O3
else
CFLAGS = -O3
endif
ALL_CFLAGS = -Wall -Werror-implicit-function-declaration $(CFLAGS)

all : setup bin/mruby bin/mbrc $(IOSSIMLIB) $(IOSDEVLIB)
	lipo -arch i386 $(IOSSIMLIB) -arch armv7 $(IOSDEVLIB) -create -output $(IOSLIB)
	cp $(IOSLIB) MRuby.framework/Versions/Current/MRuby
	cp -R mruby/include/* MRuby.framework/Versions/Current/Headers
	cp mruby/src/encoding.h MRuby.framework/Versions/Current/Headers/mruby
	cp mruby/src/oniguruma.h MRuby.framework/Versions/Current/Headers/mruby
	sed -i '' 's/mruby\.h/..\/mruby\.h/g' MRuby.framework/Versions/Current/Headers/mruby/*
	sed -i '' 's/mruby\/khash\.h/..\/mruby\/khash\.h/g' MRuby.framework/Versions/Current/Headers/mruby/*
	sed -i '' 's/mruby\/data\.h/..\/mruby\/data\.h/g' MRuby.framework/Versions/Current/Headers/mruby/encoding.h
	sed -i '' 's/mruby\/object\.h/..\/mruby\/object\.h/g' MRuby.framework/Versions/Current/Headers/mruby/value.h

setup : 
	test -d $(SIMSDKPATH) || echo "Can't find simulator SDK path"
	test -d $(SIMSDKPATH)
	test -d $(IOSSDKPATH) || echo "Can't find iOS SDK path"
	test -d $(IOSSDKPATH)
	mkdir -p tmp/lib
	mkdir -p bin

bin/mruby :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/mrblib --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/tools/mruby --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	cp mruby/bin/mruby bin/mruby

bin/mbrc :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/mrblib --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/tools/mrbc --no-print-directory CC='$(PLATFORMCC)' LL='$(PLATFORMLL)' ALL_CFLAGS='$(ALL_CFLAGS)'
	cp mruby/bin/mrbc bin/mrbc

$(IOSSIMLIB) :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) mrblib.o -C mruby/mrblib MRBC='../../bin/mrbc' --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	mv $(MRUBYLIB) $(IOSSIMLIB)
	ar r $(IOSSIMLIB) mruby/mrblib/mrblib.o

$(IOSDEVLIB) :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) mrblib.o -C mruby/mrblib MRBC='../../bin/mrbc' --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	mv $(MRUBYLIB) $(IOSDEVLIB)
	ar r $(IOSDEVLIB) mruby/mrblib/mrblib.o

clean :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	rm -rf tmp
	rm -rf bin
	rm -f bin/mrbc bin/mruby
	rm -f MRuby.framework/Versions/Current/MRuby
	rm -rf MRuby.framework/Versions/Current/Headers/*
