;
; apps/bus/src/bus-helper.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.5
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.0.5
 | @since   0.0.5
 |#
(defmodule aux
    "The helper module for the application."

    (export-macro MSG-SERVER-STARTED
                  MSG-SERVER-STOPPED)
)

; Common notification messages.
(defmacro MSG-SERVER-STARTED () "Server started")
(defmacro MSG-SERVER-STOPPED () "Server stopped")

; vim:set nu et ts=4 sw=4:
