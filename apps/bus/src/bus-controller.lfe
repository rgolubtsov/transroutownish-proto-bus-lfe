;
; apps/bus/src/bus-controller.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.13
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.0.13
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

    ; Starting up the Cowboy web server along with all their dependencies.
    (application:ensure_all_started 'cowboy)

    (let ((dispatch (cowboy_router:compile `(
        #(_ (
            #(
                ; GET /route/direct
                ,(++ (aux:SLASH)(aux:REST-PREFIX)(aux:SLASH)(aux:REST-DIRECT))
                bus-handler #M(
                    debug-log-enabled ,debug-log-enabled
                    routes-list       ,routes-list
                    syslog            ,syslog
                )
            )
        ))
    ))))

    (let ((status- (cowboy:start_clear 'bus-listener `(
        #(port ,server-port)
    ) `#M(
        env #M(dispatch ,dispatch)
    ))))

    (logger:debug (atom_to_list (element 1 status-)))
    (logger:debug ( pid_to_list (element 2 status-)))

    (let ((server-port- (integer_to_list server-port)))

    (logger:info             (++ (aux:MSG-SERVER-STARTED) server-port-))
    (syslog:log syslog 'info (++ (aux:MSG-SERVER-STARTED) server-port-)))))))))
)

; vim:set nu et ts=4 sw=4:
