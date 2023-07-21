;
; apps/bus/src/bus-helper.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.0.9
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.0.9
 | @since   0.0.5
 |#
(defmodule aux
    "The helper module for the application."

    (export-macro MSG-SERVER-STARTED
                  MSG-SERVER-STOPPED)

    (export (-get-settings 0))
)

; Common error messages.
(defmacro ERR-PORT-VALID-MUST-BE-POSITIVE-INT ()
      (++ "Valid server port must be a positive integer value, "
          "in the range 1024 .. 49151. The default value of 8080 "
          "will be used instead."))

; Common notification messages.
(defmacro MSG-SERVER-STARTED () "Server started")
(defmacro MSG-SERVER-STOPPED () "Server stopped")

#| ----------------------------------------------------------------------------
 | The minimum port number allowed.
 |#
(defmacro MIN_PORT () 1024)

#| ----------------------------------------------------------------------------
 | The maximum port number allowed.
 |#
(defmacro MAX_PORT () 49151)

#| ----------------------------------------------------------------------------
 | The default server port number.
 |#
(defmacro DEF_PORT () 8080)

; -----------------------------------------------------------------------------
; Helper function. Used to get the application settings.
;
; Returns: The tuple containing values of individual settings.
(defun -get-settings ()
    ; Retrieving the port number used to run the server -----------------------
    (let ((server-port- (application:get_env 'server-port)))

    (let ((server-port  (cond ((=/= server-port- 'undefined)
        (let ((server-port-- (element 2 server-port-)))

        (cond ((and (>= server-port-- (MIN_PORT))
                    (=< server-port-- (MAX_PORT))) server-port--)
        ('true
            (logger:error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT))

            (DEF_PORT)
        ))))
    ('true
        (logger:error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT))

        (DEF_PORT)
    ))))

    ; Identifying, whether debug logging is enabled ---------------------------
    (let ((debug-log-enabled 'true))

    ; Retrieving the path and filename of the routes data store ---------------
    (let ((datastore-path-prefix "x"))
    (let ((datastore-path-dir    "y"))
    (let ((datastore-filename    "z"))

    `#(
        ,server-port
        ,debug-log-enabled ; <== "true" or "false".
    ,(++ datastore-path-prefix
         datastore-path-dir
         datastore-filename)
    )))))))
)

; vim:set nu et ts=4 sw=4:
