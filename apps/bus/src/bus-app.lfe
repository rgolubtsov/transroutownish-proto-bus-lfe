;
; apps/bus/src/bus-app.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE port). Version 0.0.1
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

(defmodule bus-app
    "The callback module of the application."

    (behavior application)

    (export (start 2) (prep_stop 1) (stop 1))
)

#| ----------------------------------------------------------------------------
 | @param -start-type The atom `normal'.
 | @param -start-args The list of start arguments.
 |
 | @returns The `ok' tuple containing the PID of the top supervisor
 |          and the `state' value that holds the Syslog handle.
 |#
(defun start (-start-type -start-args)
    "The application entry point callback.
     Creates the supervision tree by starting the top supervisor."

    (let ((#('ok, pid) (bus-sup:start_link))))
)

#| ----------------------------------------------------------------------------
 | @param -state The `state' value, as returned from the `start' callback.
 |
 | @returns The `state' value that holds the atom `ok'.
 |#
(defun prep_stop (-state)
    "The application preparing-to-termination callback.
     Gets called just before the application is about to be stopped."

    'ok
)

#| ----------------------------------------------------------------------------
 | @param -state The `state' value, as returned from the `prep_stop' callback.
 |#
(defun stop (-state)
    "The application termination callback.
     Gets called after the application has been stopped."

    'ok
)

; vim:set nu et ts=4 sw=4:
