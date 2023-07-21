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
(defmacro MIN-PORT () 1024)

#| ----------------------------------------------------------------------------
 | The maximum port number allowed.
 |#
(defmacro MAX-PORT () 49151)

#| ----------------------------------------------------------------------------
 | The default server port number.
 |#
(defmacro DEF-PORT () 8080)

; The path and filename of the sample routes data store.
(defmacro SAMPLE-ROUTES-PATH-PREFIX () "./"        )
(defmacro SAMPLE-ROUTES-PATH-DIR    () "data/"     )
(defmacro SAMPLE-ROUTES-FILENAME    () "routes.txt")

; -----------------------------------------------------------------------------
; Helper function. Used to get the application settings.
;
; Returns: The tuple containing values of individual settings.
(defun -get-settings ()
    ; Retrieving the port number used to run the server -----------------------
    (let ((server-port- (application:get_env 'server-port)))

    (let ((server-port  (cond ((=/= server-port- 'undefined)
        (let ((server-port-- (element 2 server-port-)))

        (cond ((and (>= server-port-- (MIN-PORT))
                    (=< server-port-- (MAX-PORT))) server-port--)
        ('true
            (logger:error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT))

            (DEF-PORT)
        ))))
    ('true
        (logger:error (ERR-PORT-VALID-MUST-BE-POSITIVE-INT))

        (DEF-PORT)
    ))))

    ; Identifying, whether debug logging is enabled ---------------------------
    (let ((debug-log-enabled- (application:get_env 'logger-debug-enabled)))

    (let ((debug-log-enabled  (cond ((=/= debug-log-enabled- 'undefined)
        (if (=:= (element 2 debug-log-enabled-) 'yes) 'true 'false))
        ('true 'false))))

    ; Retrieving the path and filename of the routes data store ---------------
    (let ((datastore-path-prefix- (application:get_env 'routes-datastore-path-prefix)))
    (let ((datastore-path-prefix  (cond ((=/= datastore-path-prefix- 'undefined)
        (let ((datastore-path-prefix-0 (element 2 datastore-path-prefix-)))
        (let ((datastore-path-prefix-1 (string:is_empty datastore-path-prefix-0)))
        (if  (not datastore-path-prefix-1) datastore-path-prefix-0
               (SAMPLE-ROUTES-PATH-PREFIX)))))
        ('true (SAMPLE-ROUTES-PATH-PREFIX)))))

    (let ((datastore-path-dir- (application:get_env 'routes-datastore-path-dir)))
    (let ((datastore-path-dir  (cond ((=/= datastore-path-dir- 'undefined)
        (let ((datastore-path-dir-0 (element 2 datastore-path-dir-)))
        (let ((datastore-path-dir-1 (string:is_empty datastore-path-dir-0)))
        (if  (not datastore-path-dir-1) datastore-path-dir-0
               (SAMPLE-ROUTES-PATH-DIR)))))
        ('true (SAMPLE-ROUTES-PATH-DIR)))))

    (let ((datastore-filename- (application:get_env 'routes-datastore-filename)))
    (let ((datastore-filename  (cond ((=/= datastore-filename- 'undefined)
        (let ((datastore-filename-0 (element 2 datastore-filename-)))
        (let ((datastore-filename-1 (string:is_empty datastore-filename-0)))
        (if  (not datastore-filename-1) datastore-filename-0
               (SAMPLE-ROUTES-FILENAME)))))
        ('true (SAMPLE-ROUTES-FILENAME)))))

    `#(
        ,server-port
        ,debug-log-enabled ; <== "true" or "false".
    ,(++ datastore-path-prefix
         datastore-path-dir
         datastore-filename)
    )))))))))))
)

; vim:set nu et ts=4 sw=4:
