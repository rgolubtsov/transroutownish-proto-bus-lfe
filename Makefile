#
# Makefile
# =============================================================================
# Urban bus routing microservice prototype (LFE/OTP port). Version 0.3.0
# =============================================================================
# An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
# as a microservice, implementing a simple urban bus routing prototype.
# =============================================================================
# Copyright (C) 2023 Radislav (Radicchio) Golubtsov
#
# (See the LICENSE file at the top of the source tree.)
#

# Profile: "default" or "prod".
PROF = prod

EBIN = _build/$(PROF)/lib/bus/ebin
BEAM = $(EBIN)/bus-app.beam \
       $(EBIN)/bus-sup.beam

APPS = apps/bus/src
SRCS = $(APPS)/bus-app.lfe \
       $(APPS)/bus-sup.lfe

SERV = _build/$(PROF)/rel/bus/lib

# Specify flags and other vars here.
REBAR3 = rebar3
LFE    = lfe
ECHO   = @echo

# Making the first target (BEAMs).
$(BEAM): $(SRCS)
	$(REBAR3)         compile
	$(REBAR3) as prod compile

# Making the second target (releases).
$(SERV): $(BEAM)
	$(REBAR3)         $(LFE) release
	$(ECHO)
	$(REBAR3) as prod $(LFE) release
	$(ECHO)

.PHONY: all clean

all: $(SERV)

clean:
	$(REBAR3)         $(LFE) clean
	$(REBAR3) as prod $(LFE) clean

# vim:set nu ts=4 sw=4:
