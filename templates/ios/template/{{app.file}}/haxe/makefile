
ifeq ("$(ARCHS)","normal")
	ARCHS = armv6 armv7 i386
endif

HAXE_BUILDS := $(ARCHS:%=build-haxe-%)

ifeq ("$(CONFIGURATION)","Debug")
   BUILD_STYLE := Debug
endif

ifeq ("$(BUILD_STYLE)","Debug")
   DEBUG := -debug
   CONFIG := Debug
else
   DEBUG :=
   CONFIG := Release
endif

HAXE_OS := $(PLATFORM_NAME)
BUILD_TYPE := device
EXTRA_DEFINES :=
SIMFLAG :=
ifeq ("$(HAXE_OS)","iphonesimulator")
   HAXE_OS := iphonesim
   BUILD_TYPE := simulator
   EXTRA_DEFINES := -D simulator
   SIMFLAG := -sim
endif
CONFIG := $(CONFIG)-$(HAXE_OS)

LIB_DEST := $(SIMFLAG)$(DEBUG)/libApplicationMain.a
LIB_MBEDTLS_DEST := $(SIMFLAG)$(DEBUG)/libmbedtls_hxcpp.a

SIMULATOR_ARCH = i386 x86_64

SUFFIX_i386 = -x86
SUFFIX_x86_64 = -x86_64
SUFFIX_armv6 = -armv6
SUFFIX_armv7 = -armv7
SUFFIX_arm64 = -arm64

HXCPP_FLAGS_i386 = -D HXCPP_X86
HXCPP_FLAGS_x86_64 = -D HXCPP_X86_64
HXCPP_FLAGS_armv6 = -D HXCPP_ARMV6
HXCPP_FLAGS_armv7 = -D HXCPP_ARMV7
HXCPP_FLAGS_arm64 = -D HXCPP_ARM64

ifeq ("$(ACTION)","clean")
default: clean
else
default: $(HAXE_BUILDS)
endif

default: debug_print

debug_print:
	@echo "Make $(HAXE_BUILDS)"

$(HAXE_BUILDS): build-haxe-%:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)$(SUFFIX_$*)"
	haxe Build.hxml $(HXCPP_FLAGS_$*) $(EXTRA_DEFINES) -cpp build/$(CONFIG)$(SUFFIX_$*) $(DEBUG)
	cd build/$(CONFIG)$(SUFFIX_$*); ::HAXELIB_PATH:: export HXCPP_NO_COLOR=1; \
		haxelib run ::CPP_BUILD_LIBRARY:: Build.xml haxe -Ddestination="$(CURDIR)/../lib/$*$(LIB_DEST)" \
		-options Options.txt $(DEBUG)
	touch ../Classes/Main.mm
	cd build/$(CONFIG)$(SUFFIX_$*); ::HAXELIB_PATH:: export HXCPP_NO_COLOR=1; \
		::CPP_CACHE_WORKAROUND:: haxelib run ::CPP_BUILD_LIBRARY:: "$(CURDIR)/BuildHxcppMbedtls.xml" \
		-Ddestination="$(CURDIR)/../lib/$*$(LIB_MBEDTLS_DEST)" \
		-options "$(CURDIR)/build/$(CONFIG)$(SUFFIX_$*)/Options.txt" $(DEBUG)

clean:
	rm -rf build

.PHONY: default debug_print clean $(HAXE_BUILDS)
.SUFFIXES:
