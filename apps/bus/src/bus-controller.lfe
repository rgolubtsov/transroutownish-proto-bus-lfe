;
; apps/bus/src/bus-controller.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.12
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.0.12
 | @since   0.0.12
 |#
(defmodule bus-controller
    "The controller module of the application."

    (export (startup 1))
)

#| ----------------------------------------------------------------------------
 | @param args The tuple containing the server port number to listen on,
 |             as the first element.
 |#
(defun startup (args)
    "Starts up the bundled web server."

    (let ((server-port       (element 1 args)))
    (let ((debug-log-enabled (element 2 args)))
    (let ((routes-list       (element 3 args)))
    (let ((syslog            (element 4 args)))

    (let ((server-port- (integer_to_list server-port)))

    (logger:info             (++ (aux:MSG-SERVER-STARTED) server-port-))
    (syslog:log syslog 'info (++ (aux:MSG-SERVER-STARTED) server-port-)))))))
)

; vim:set nu et ts=4 sw=4:
