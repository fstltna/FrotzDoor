# Define path for ar
AR = /usr/bin/ar

# Define path for ranlib
RANLIB = /usr/bin/ranlib

# Define your C compiler.  I recommend gcc if you have it.
# MacOS users should use "cc" even though it's really "gcc".
#
CC = gcc

# Enable compiler warnings. This is an absolute minimum.
CFLAGS += -Wall -Wextra -std=gnu99

# Define your optimization flags.
#
# These are good for regular use.
OPTS = -O2 -fomit-frame-pointer -falign-functions=2 -falign-loops=2 -falign-jumps=2
# These are handy for debugging.
#OPTS = $(CFLAGS) -g

# Define where you want Frotz installed (typically /usr/local).
#
PREFIX = /usr/local
MAN_PREFIX = $(PREFIX)
CONFIG_DIR = /etc
#CONFIG_DIR = $(PREFIX)/etc

# Pick your sound support.  The most featureful form of sound support is
# through libao.  Comment all of these out if you don't want sound.
#
SOUND = none
#SOUND = ao
#SOUND = sun
#SOUND = oss


##########################################################################
# The configuration options below are intended mainly for older flavors
# of Unix.  For Linux, BSD, and Solaris released since 2003, you can
# ignore this section.
##########################################################################

# If your machine's version of curses doesn't support color...
#
COLOR = yes

# If this matters, you can choose libcurses or libncurses.
#
CURSES = -lncurses
#CURSES = -lcurses

# Just in case your operating system keeps its user-added header files
# somewhere unusual...
#
#INCL = -I/usr/local/include
#INCL = -I/usr/pkg/include
#INCL = -I/usr/freeware/include
#INCL = -I/5usr/include
## INCL path for Apple MacOS Sierra 10.12 plus MacPorts
INCL = -I/opt/local/include

# Just in case your operating system keeps its user-added libraries
# somewhere unusual...
#
#LIB = -L/usr/local/lib
#LIB = -L/usr/pkg/lib
#LIB = -L/usr/freeware/lib
#LIB = -L/5usr/lib
## LIB path for Apple MacOS Sierra 10.12 plus MacPorts
LIB = -L/opt/local/lib

# Uncomment this if you're compiling Unix Frotz on a machine that lacks 
# the strrchr() libc library call.  If you don't know what this means,
# leave it alone.
#
#STRRCHR_DEF = -DNO_STRRCHR

# Uncomment this if you're compiling Unix Frotz on a machine that lacks
# the memmove(3) system call.  If you don't know what this means, leave it
# alone.
#
#NO_MEMMOVE = yes

# Default sample rate for sound effects.
# All modern sound interfaces can be expected to support 44100 Hz sample
# rates.  Earlier ones, particularly ones in Sun 4c workstations support
# only up to 8000 Hz.
SAMPLERATE = 44100

# Audio buffer size in frames
BUFFSIZE = 4096

# Default sample rate converter type
DEFAULT_CONVERTER = SRC_SINC_MEDIUM_QUALITY

#########################################################################
# This section is where Frotz is actually built.
# Under normal circumstances, nothing in this section should be changed.
#########################################################################

SRCDIR = src
VERSION = 2.45pre
NAME = frotz
BINNAME = $(NAME)
DISTFILES = bugtest
DISTNAME = $(BINNAME)-$(VERSION)
distdir = $(DISTNAME)

COMMON_DIR = $(SRCDIR)/common
COMMON_TARGET = $(SRCDIR)/frotz_common.a
COMMON_OBJECT = $(COMMON_DIR)/buffer.o \
		$(COMMON_DIR)/err.o \
		$(COMMON_DIR)/fastmem.o \
		$(COMMON_DIR)/files.o \
		$(COMMON_DIR)/hotkey.o \
		$(COMMON_DIR)/input.o \
		$(COMMON_DIR)/main.o \
		$(COMMON_DIR)/math.o \
		$(COMMON_DIR)/object.o \
		$(COMMON_DIR)/process.o \
		$(COMMON_DIR)/quetzal.o \
		$(COMMON_DIR)/random.o \
		$(COMMON_DIR)/redirect.o \
		$(COMMON_DIR)/screen.o \
		$(COMMON_DIR)/sound.o \
		$(COMMON_DIR)/stream.o \
		$(COMMON_DIR)/table.o \
		$(COMMON_DIR)/text.o \
		$(COMMON_DIR)/variable.o

CURSES_DIR = $(SRCDIR)/curses
CURSES_TARGET = $(SRCDIR)/frotz_curses.a
CURSES_OBJECT = $(CURSES_DIR)/ux_init.o \
		$(CURSES_DIR)/ux_input.o \
		$(CURSES_DIR)/ux_pic.o \
		$(CURSES_DIR)/ux_screen.o \
		$(CURSES_DIR)/ux_text.o \
		$(CURSES_DIR)/ux_blorb.o \
		$(CURSES_DIR)/ux_audio.o \
		$(CURSES_DIR)/ux_resource.o \
		$(CURSES_DIR)/ux_audio_none.o \
		$(CURSES_DIR)/ux_locks.o

DUMB_DIR = $(SRCDIR)/dumb
DUMB_TARGET = $(SRCDIR)/frotz_dumb.a
DUMB_OBJECT =	$(DUMB_DIR)/dumb_init.o \
		$(DUMB_DIR)/dumb_input.o \
		$(DUMB_DIR)/dumb_output.o \
		$(DUMB_DIR)/dumb_pic.o \
		$(DUMB_DIR)/dumb_blorb.o

BLORB_DIR = $(SRCDIR)/blorb
BLORB_TARGET =  $(SRCDIR)/blorblib.a
BLORB_OBJECT =  $(BLORB_DIR)/blorblib.o

TARGETS = $(COMMON_TARGET) $(CURSES_TARGET) $(BLORB_TARGET)

FLAGS = $(OPTS) $(INCL)

SOUND_LIB = -lao -ldl -lpthread -lm -lsndfile -lvorbisfile -lmodplug -lsamplerate

#########################################################################
#########################################################################
# Targets
#

.PHONY: all help dist clean distclean install install_dumb uninstall uninstall_dumb

$(NAME): $(COMMON_DIR)/git_hash.h $(COMMON_DIR)/defines.h $(CURSES_DIR)/defines.h $(COMMON_TARGET) $(CURSES_TARGET) $(BLORB_TARGET)
	@echo Linking $(NAME)...
ifeq ($(SOUND), ao)
	$(CC) -o $(BINNAME)$(EXTENSION) $(TARGETS) $(LIB) $(CURSES) $(SOUND_LIB)
else ifeq ($(SOUND), none)
	$(CC) -o $(BINNAME)$(EXTENSION) $(TARGETS) $(LIB) $(CURSES) -DNO_SOUND
else ifndef SOUND
	$(CC) -o $(BINNAME)$(EXTENSION) $(TARGETS) $(LIB) $(CURSES) -DNO_SOUND
else
	@echo "Invalid sound choice $(SOUND)."
endif

dumb:		d$(NAME)
d$(NAME):	$(COMMON_DIR)/git_hash.h $(COMMON_DIR)/defines.h $(COMMON_TARGET) $(DUMB_TARGET) $(BLORB_TARGET)
	@echo Linking d$(NAME)...
	$(CC) -o d$(BINNAME)$(EXTENSION) $(COMMON_TARGET) $(DUMB_TARGET) $(BLORB_TARGET) $(LIB)

all:	$(NAME) d$(NAME)


.SUFFIXES:
.SUFFIXES: .c .o .h

$(COMMON_OBJECT): %.o: %.c
	#$(CC) $(OPTS) -o $@ -c $<
	$(CC) $(OPTS) $(INCL) -o $@ -c $<

$(BLORB_OBJECT): %.o: %.c
	$(CC) $(CFLAGS) $(OPTS) -o $@ -c $<

$(DUMB_OBJECT): %.o: %.c
	$(CC) $(CFLAGS) $(OPTS) -o $@ -c $<

$(CURSES_OBJECT): %.o: %.c
	#$(CC) $(OPTS) -o $@ -c $<
	$(CC) $(OPTS) $(INCL) -o $@ -c $<


####################################
# Get the defines set up just right
#
$(COMMON_DIR)/defines.h:
	@echo "Generating $@"
	@echo "#define VERSION \"$(VERSION)\"" > $@

$(CURSES_DIR)/defines.h:
	@echo "Generating $@"
	@echo "#define CONFIG_DIR \"$(CONFIG_DIR)\"" >> $@
	@echo "#define SOUND \"$(SOUND)\"" >> $@
	@echo "#define SAMPLERATE $(SAMPLERATE)" >> $@
	@echo "#define BUFFSIZE $(BUFFSIZE)" >> $@
	@echo "#define DEFAULT_CONVERTER $(DEFAULT_CONVERTER)" >> $@

ifeq ($(SOUND), none)
	@echo "#define NO_SOUND" >> $@
endif

ifndef SOUND
	@echo "#define NO_SOUND" >> $@
endif

ifdef COLOR
	@echo "#define COLOR_SUPPORT" >> $@
endif

ifdef NO_MEMMOVE
	@echo "#define NO_MEMMOVE" >> $@
endif


# If we're building from a Git repository, fetch the commit tag and put 
#   it into $(COMMON_DIR)/git_hash.h.
# If not, that should mean that we're building from a tarball.  In that 
#  case, $(COMMON_DIR)/git_hash.h should already be there.
#
hash: $(COMMON_DIR)/git_hash.h
$(COMMON_DIR)/git_hash.h:
ifneq ($(and $(wildcard .git),$(shell which git)),)
	@echo "Creating $(COMMON_DIR)/git_hash.h"
	@echo "#define GIT_HASH \"$$(git rev-parse HEAD)\"" > $(COMMON_DIR)/git_hash.h
	@echo "#define GIT_HASH_SHORT \"$$(git rev-parse HEAD|head -c7 -)\"" >> $(COMMON_DIR)/git_hash.h
	@echo "#define GIT_TAG \"$$(git describe --tags)\"" >> $(COMMON_DIR)/git_hash.h
	@echo "#define GIT_BRANCH \"$$(git rev-parse --abbrev-ref HEAD)\"" >> $(COMMON_DIR)/git_hash.h
else
	$(error $(COMMON_DIR)/git_hash.h is missing!.)
endif


########################################################################
# If you're going to make this target manually, you'd better know which
# config target to make first.
#
common_lib:	$(COMMON_TARGET)
$(COMMON_TARGET): $(COMMON_OBJECT)
	@echo
	@echo "Archiving common code..."
	$(AR) rc $(COMMON_TARGET) $(COMMON_OBJECT)
	$(RANLIB) $(COMMON_TARGET)
	@echo

curses_lib:	$(CURSES_TARGET)
$(CURSES_TARGET): $(CURSES_OBJECT)
	@echo
	@echo "Archiving curses interface code..."
	$(AR) rc $(CURSES_TARGET) $(CURSES_OBJECT)
	$(RANLIB) $(CURSES_TARGET)
	@echo

dumb_lib:	$(DUMB_TARGET)
$(DUMB_TARGET): $(DUMB_OBJECT)
	@echo
	@echo "Archiving dumb interface code..."
	$(AR) rc $(DUMB_TARGET) $(DUMB_OBJECT)
	$(RANLIB) $(DUMB_TARGET)
	@echo

blorb_lib:	$(BLORB_TARGET)
$(BLORB_TARGET): $(BLORB_OBJECT)
	@echo
	@echo "Archiving Blorb file handling code..."
	$(AR) rc $(BLORB_TARGET) $(BLORB_OBJECT)
	$(RANLIB) $(BLORB_TARGET)
	@echo

install: $(NAME)
	@install -D -m 755 $(BINNAME)$(EXTENSION) "$(DESTDIR)$(PREFIX)/bin/$(BINNAME)$(EXTENSION)"
	@install -D -m 644 doc/$(NAME).6 "$(DESTDIR)$(MAN_PREFIX)/man/man6/$(NAME).6"

uninstall:
	@rm -f "$(DESTDIR)$(PREFIX)/bin/$(NAME)"
	@rm -f "$(DESTDIR)$(MAN_PREFIX)/man/man6/$(NAME).6"

install_dumb: d$(NAME)
	@install -D -m 755 d$(BINNAME)$(EXTENSION) "$(DESTDIR)$(PREFIX)/bin/d$(BINNAME)$(EXTENSION)"
	@install -D -m 644 doc/d$(NAME).6 "$(DESTDIR)$(MAN_PREFIX)/man/man6/d$(NAME).6"

uninstall_dumb:
	@rm -f "$(DESTDIR)$(PREFIX)/bin/d$(NAME)"
	@rm -f "$(DESTDIR)$(MAN_PREFIX)/man/man6/d$(NAME).6"

dist: distclean hash
	mkdir $(distdir)
	@for file in `ls`; do \
		if test $$file != $(distdir); then \
			cp -Rp $$file $(distdir)/$$file; \
		fi; \
	done
	find $(distdir) -type l -exec rm -f {} \;
	tar chof $(distdir).tar $(distdir)
	gzip -f --best $(distdir).tar
	rm -rf $(distdir)
	@echo
	@echo "$(distdir).tar.gz created"
	@echo

clean:
	rm -f $(SRCDIR)/*.h $(SRCDIR)/*.a
	rm -f $(COMMON_DIR)/defines.h
ifneq ($(and $(wildcard .git),$(shell which git)),)
	rm -f $(COMMON_DIR)/git_hash.h
endif
	rm -f $(CURSES_DIR)/defines.h
	find . -name *.o -exec rm -f {} \;
	find . -name *.O -exec rm -f {} \;

distclean: clean
	rm -f $(BINNAME)$(EXTENSION) d$(BINNAME)$(EXTENSION) s$(BINNAME)
	find . -iname *.exe -exec rm -f {} \;
	find . -iname *.bak -exec rm -f {} \;
	find . -iname *.lib -exec rm -f {} \;
	rm -f *core $(SRCDIR)/*core
	-rm -rf $(distdir)
	-rm -f $(distdir).tar $(distdir).tar.gz

help:
	@echo
	@echo "Targets:"
	@echo "    frotz"
	@echo "    dfrotz"
	@echo "    install"
	@echo "    uninstall"
	@echo "    install_dfrotz"
	@echo "    uninstall_dfrotz"
	@echo "    clean"
	@echo "    distclean"
	@echo "    dist"
	@echo
