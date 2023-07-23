;
; apps/bus/src/bus-app.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.10
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.0.10
 | @since   0.0.1
 |#
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

    ; Getting the application settings.
    (let ((settings (aux:-get-settings)))

    (let ((server-port       (element 1 settings)))
    (let ((debug-log-enabled (element 2 settings)))
    (let ((datastore         (element 3 settings)))

    ; Slurping routes from the routes data store.
    (let ((routes- (file:read_file (filename:join
                   (code:priv_dir 'bus) datastore))))

    (cond ((and (=:= (element 1 routes-) 'error )
                (=:= (element 2 routes-) 'enoent))
        (logger:critical (aux:ERR-DATASTORE-NOT-FOUND))

        (init:stop (aux:EXIT-FAILURE)))
    ('true 'false))

    (logger:debug (element 2 routes-))

    (let ((app-name (atom_to_list (element 2 (application:get_application)))))

    ; Opening the system logger.
    ; Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    (syslog:start) (let ((`#(ok ,syslog)
    (syslog:open app-name `(cons pid) 'daemon)))

    (let ((server-port- (integer_to_list server-port)))

    (logger:info             (++ (aux:MSG-SERVER-STARTED) server-port-))
    (syslog:log syslog 'info (++ (aux:MSG-SERVER-STARTED) server-port-)))

    (let ((`#(ok ,pid) (bus-sup:start_link)))

    `#(ok ,pid ,syslog) ; <==|syslog| will be returned as the value of |state|.
    ))))))))
)

#| ----------------------------------------------------------------------------
 | @param -state The `state' value, as returned from the `start' callback.
 |
 | @returns The `state' value that holds the atom `ok'.
 |#
(defun prep_stop (-state)
    "The application preparing-to-termination callback.
     Gets called just before the application is about to be stopped."

    (logger:info             (aux:MSG-SERVER-STOPPED))
    (syslog:log -state 'info (aux:MSG-SERVER-STOPPED))

    (syslog:close -state)

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
