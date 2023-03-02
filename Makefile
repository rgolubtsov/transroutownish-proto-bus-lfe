#
# Makefile
# =============================================================================
# Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.1
# =============================================================================
# An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
# as a microservice, implementing a simple urban bus routing prototype.
# =============================================================================
# Copyright (C) 2023 Radislav (Radicchio) Golubtsov
#
# (See the LICENSE file at the top of the source tree.)
#

# ----- Bugger   Off -------
# --- 7 Drunken  Sailors ---
# ----- Friendly Reunion ---
BEAM = bus-app.beam \
       bus-sup.beam

APPS = apps/bus/src
SRCS = $(APPS)/bus-app.lfe \
       $(APPS)/bus-sup.lfe

# Specify flags and other vars here.
LFEC    = lfec
ECHO    = @echo
RMFLAGS = -vR

# Making the target (BEAMs).
$(BEAM): $(SRCS)
	$(LFEC) $(SRCS)
	$(ECHO)

.PHONY: all clean

all: $(BEAM)

clean:
	$(RM) $(RMFLAGS) $(BEAM)

# vim:set nu ts=4 sw=4:
