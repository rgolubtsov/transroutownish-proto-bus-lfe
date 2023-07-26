;
; apps/bus/src/bus-helper.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.1.5
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.1.5
 | @since   0.0.5
 |#
(defmodule aux
    "The helper module for the application."

    (export-macro EXIT-FAILURE
                  EXIT-SUCCESS
                  EMPTY-STRING
                  SPACE
                  SLASH
                  NEW-LINE)
; -----------------------------------------------------------------------------
    (export-macro ERR-DATASTORE-NOT-FOUND
                  ERR-CANNOT-START-SERVER
                  ERR-ADDR-ALREADY-IN-USE
                  ERR-SERV-UNKNOWN-REASON)
; -----------------------------------------------------------------------------
    (export-macro MSG-SERVER-STARTED
                  MSG-SERVER-STOPPED)
; -----------------------------------------------------------------------------
    (export-macro ROUTE-ID-REGEX)
; -----------------------------------------------------------------------------
    (export-macro REST-PREFIX
                  REST-DIRECT)
; -----------------------------------------------------------------------------
    (export-macro MIME-TYPE
                  MIME-SUB-TYPE)
; -----------------------------------------------------------------------------
    (export-macro FROM
                  TO)
; -----------------------------------------------------------------------------
    (export (-get-settings 0))
)

; Helper constants.
(defmacro EXIT-FAILURE ()    1) ;    Failing exit status.
(defmacro EXIT-SUCCESS ()    0) ; Successful exit status.
(defmacro EMPTY-STRING ()   "")
(defmacro SPACE        ()  " ")
(defmacro SLASH        ()  "/")
(defmacro NEW-LINE     () "\n")

; Common error messages.
(defmacro ERR-PORT-VALID-MUST-BE-POSITIVE-INT ()
      (++ "Valid server port must be a positive integer value, "
          "in the range 1024 .. 49151. The default value of 8080 "
          "will be used instead."))
(defmacro ERR-DATASTORE-NOT-FOUND ()
          "FATAL: Data store file not found. Quitting...")
(defmacro ERR-CANNOT-START-SERVER ()
          "FATAL: Cannot start server ")
(defmacro ERR-ADDR-ALREADY-IN-USE ()
          "due to address requested already in use. Quitting...")
(defmacro ERR-SERV-UNKNOWN-REASON ()
          "for an unknown reason. Quitting...")

; Common notification messages.
(defmacro MSG-SERVER-STARTED () "Server started on port ")
(defmacro MSG-SERVER-STOPPED () "Server stopped"         )

#| ----------------------------------------------------------------------------
 | The regex pattern for the element to be excluded from a bus stops sequence:
 | it is an arbitrary identifier of a route, which is not used
 | in the routes processing anyhow.
 |#
(defmacro ROUTE-ID-REGEX () "^\\d+")

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

; REST URI path-related constants.
(defmacro REST-PREFIX () "route" )
(defmacro REST-DIRECT () "direct")

; HTTP response-related constants.
(defmacro MIME-TYPE     () #"application")
(defmacro MIME-SUB-TYPE () #"json"       )

; HTTP request parameter names.
(defmacro FROM () #"from")
(defmacro TO   () #"to"  )

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
    (let ((ds-path-prefix-(application:get_env 'routes-datastore-path-prefix)))
    (let ((ds-path-prefix (cond ((=/= ds-path-prefix- 'undefined)
        (let ((ds-path-prefix-0 (element 2 ds-path-prefix-)))
        (let ((ds-path-prefix-1 (string:is_empty ds-path-prefix-0)))
        (if  (not ds-path-prefix-1) ds-path-prefix-0
               (SAMPLE-ROUTES-PATH-PREFIX)))))
        ('true (SAMPLE-ROUTES-PATH-PREFIX)))))

    (let ((ds-path-dir-(application:get_env 'routes-datastore-path-dir)))
    (let ((ds-path-dir (cond ((=/= ds-path-dir- 'undefined)
        (let ((ds-path-dir-0 (element 2 ds-path-dir-)))
        (let ((ds-path-dir-1 (string:is_empty ds-path-dir-0)))
        (if  (not ds-path-dir-1) ds-path-dir-0
               (SAMPLE-ROUTES-PATH-DIR)))))
        ('true (SAMPLE-ROUTES-PATH-DIR)))))

    (let ((ds-filename-(application:get_env 'routes-datastore-filename)))
    (let ((ds-filename (cond ((=/= ds-filename- 'undefined)
        (let ((ds-filename-0 (element 2 ds-filename-)))
        (let ((ds-filename-1 (string:is_empty ds-filename-0)))
        (if  (not ds-filename-1) ds-filename-0
               (SAMPLE-ROUTES-FILENAME)))))
        ('true (SAMPLE-ROUTES-FILENAME)))))

    `#(
        ,server-port
        ,debug-log-enabled ; <== "true" or "false".
    ,(++ ds-path-prefix
         ds-path-dir
         ds-filename)
    )))))))))))
)

; vim:set nu et ts=4 sw=4:
