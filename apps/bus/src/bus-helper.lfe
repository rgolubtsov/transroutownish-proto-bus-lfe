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

; Common notification messages.
(defmacro MSG-SERVER-STARTED () "Server started")
(defmacro MSG-SERVER-STOPPED () "Server stopped")

; -----------------------------------------------------------------------------
; Helper function. Used to get the application settings.
;
; Returns: The tuple containing values of individual settings.
(defun -get-settings ()
    ; Retrieving the port number used to run the server -----------------------
    (let ((server-port 8765))

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
    ))))))
)

; vim:set nu et ts=4 sw=4:
