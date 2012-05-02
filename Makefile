RITEVM := tmp/lib/ritevm
IOSLIB := $(RITEVM)-ios.a
IOSSIMLIB := $(RITEVM)-iossim.a
IOSDEVLIB := $(RITEVM)-iosdev.a
XCODEROOT := "/Developer/Platforms"
IOSSIMCC := xcrun -sdk iphoneos llvm-gcc-4.2 -arch i386 -isysroot "$(XCODEROOT)/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.1.sdk/"
IOSDEVCC := xcrun -sdk iphoneos llvm-gcc-4.2 -arch armv7 -isysroot "$(XCODEROOT)/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk/"

# compiler, linker (gcc)
DEBUG_MODE = 1
ifeq ($(DEBUG_MODE),1)
CFLAGS = -g -O3
else
CFLAGS = -O3
endif
ALL_CFLAGS = -Wall -Werror-implicit-function-declaration $(CFLAGS)

all : setup $(IOSSIMLIB) $(IOSDEVLIB)
	lipo -arch i386 $(IOSSIMLIB) -arch armv7 $(IOSDEVLIB) -create -output $(IOSLIB)
	cp $(IOSLIB) MRuby.framework/Versions/Current/MRuby
	cp -R mruby/include/* MRuby.framework/Versions/Current/Headers

setup : bin/mruby bin/mbrc
	mkdir -p tmp/lib
	mkdir -p bin

bin/mruby :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/tools/mruby --no-print-directory ALL_CFLAGS='$(ALL_CFLAGS)'
	cp mruby/bin/mruby bin/mruby

bin/mbrc :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/tools/mrbc --no-print-directory ALL_CFLAGS='$(ALL_CFLAGS)'
	cp mruby/bin/mrbc bin/mrbc

$(IOSSIMLIB) :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) mrblib.o -C mruby/mrblib MRBC='../../bin/mrbc' --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(IOSSIMCC)' LL='$(IOSSIMCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	mv mruby/lib/ritevm.a $(IOSSIMLIB)
	ar r $(IOSSIMLIB) mruby/mrblib/mrblib.o

$(IOSDEVLIB) :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) mrblib.o -C mruby/mrblib MRBC='../../bin/mrbc' --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	$(MAKE) -C mruby/src --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	mv mruby/lib/ritevm.a $(IOSDEVLIB)
	ar r $(IOSDEVLIB) mruby/mrblib/mrblib.o

clean :
	$(MAKE) clean -C mruby --no-print-directory CC='$(IOSDEVCC)' LL='$(IOSDEVCC)' ALL_CFLAGS='$(ALL_CFLAGS)'
	rm -rf tmp
	rm -f bin/mrbc bin/mruby
	rm -f MRuby.framework/Versions/Current/MRuby
	rm -rf MRuby.framework/Versions/Current/Headers/*
