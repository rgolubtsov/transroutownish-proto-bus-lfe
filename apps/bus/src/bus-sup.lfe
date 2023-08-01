;
; apps/bus/src/bus-sup.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.3.0
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.3.0
 | @since   0.0.1
 |#
(defmodule bus-sup
    "The supervisor module of the application."

    (behavior supervisor)

    (export (start_link 0) (init 1))
)

#| ----------------------------------------------------------------------------
 | @returns The `ok' tuple containing the PID of the supervisor created
 |          and the `state' indicator (defaults to an empty list).
 |#
(defun start_link ()
    "Creates the supervisor process as part of a supervision tree."

    (supervisor:start_link `#(local ,(MODULE)) (MODULE) ())
)

#| ----------------------------------------------------------------------------
 | @returns The `ok' tuple containing configuration for the supervisor
 |          and specifications of child processes.
 |#
(defun init (_)
    "The supervisor initialization callback.
     Gets called after the supervisor is started.
     Defines configuration for the supervisor
     and specifications of child processes."

    (let ((sup-flags `#M(
        strategy  one_for_all ; Defaults to "one_for_one".
        intensity 0           ; Defaults to 1 restart.
        period    1           ; Defaults to 5 seconds.
    )))

    (let ((child-specs ())) ; No any particular specs; relying on the defaults.

    `#(ok #(
        ,sup-flags
        ,child-specs
    ))))
)

; vim:set nu et ts=4 sw=4:
