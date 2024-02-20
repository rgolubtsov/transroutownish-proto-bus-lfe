;
; apps/bus/src/bus-handler.lfe
; =============================================================================
; Urban bus routing microservice prototype (LFE/OTP port). Version 0.3.3
; =============================================================================
; An LFE (Lisp Flavoured Erlang) application, designed and intended to be run
; as a microservice, implementing a simple urban bus routing prototype.
; =============================================================================
; Copyright (C) 2023-2024 Radislav (Radicchio) Golubtsov
;
; (See the LICENSE file at the top of the source tree.)
;

#| ----------------------------------------------------------------------------
 | @version 0.3.3
 | @since   0.0.13
 |#
(defmodule bus-handler
    "The request handler module of the application."

    (export (init                   2)
            (content_types_provided 2)
            (to-json                2))
)

#| ----------------------------------------------------------------------------
 | @param req   The incoming HTTP request object.
 | @param state The so-called "state" of the HTTP request.
 |              This can be any data, payload passed with the request
 |              and used somehow during processing the request.
 |
 | @returns The `cowboy_rest' tuple containing the request object
 |          along with the state of the request.
 |          The atom `cowboy_rest' indicates that Cowboy will pick
 |          the REST handler behavior to operate on requests.
 |#
(defun init (req state)
    "The request handler initialization and processing callback.
     Used to process the incoming request and send the response."

    `#(cowboy_rest ,req ,state)
)

#| ----------------------------------------------------------------------------
 | @param req   The incoming HTTP request object.
 | @param state The so-called "state" of the HTTP request.
 |              This can be any data, payload passed with the request
 |              and used somehow during processing the request.
 |
 | @returns A list of media types the microservice provides when responding
 |          to the client. A special callback then will be called for any
 |          appropriate request regarding the corresponding media type:
 |          `application/json' is currently the only one used.
 |#
(defun content_types_provided (req state)
    "The REST-specific callback to respond to the client
     when one of the `HEAD', `GET', or `OPTIONS' methods is used."

    `#((#(#(
        ,(aux:MIME-TYPE) ,(aux:MIME-SUB-TYPE) ; content-type: application/json
        ()                    ; <== No any params needed for this content-type.
    ) to-json)) ,req ,state)
)

#| ----------------------------------------------------------------------------
 | @param req   The incoming HTTP request object.
 | @param state The so-called "state" of the HTTP request.
 |              This can be any data, payload passed with the request
 |              and used somehow during processing the request.
 |
 | @returns The body of the response in the JSON representation,
 |          containing the following properties:
 |          <ul>
 |          <li><strong>from</strong> &mdash; The starting bus stop point.</li>
 |          <li><strong>to</strong>   &mdash; The ending   bus stop point.</li>
 |          <li><strong>direct</strong> &mdash; The logical indicator
 |          of the presence of a direct route from `from' to `to'.</li>
 |          </ul>
 |#
(defun to-json (req state)
    "The so-called `ProvideCallback', used to return the response body."

    (let ((`#M(
        debug-log-enabled ,debug-log-enabled
        routes-list       ,routes-list
        syslog            ,syslog
    ) state))

    ; -------------------------------------------------------------------------
    ; --- Parsing and validating request params - Begin -----------------------
    ; -------------------------------------------------------------------------
    (let ((`#M(from ,from- to ,to-) (cowboy_req:match_qs `(
        #(from () ,(aux:ZERO))
        #(to   () ,(aux:ZERO))
    ) req)))

    (let ((from-- (if (is_boolean from-) (aux:ZERO) from-)))
    (let ((to--   (if (is_boolean to-  ) (aux:ZERO) to-  )))

    (cond (debug-log-enabled
        (let ((FROM--- (binary:bin_to_list (aux:FROM))))
        (let ((from--- (binary:bin_to_list from--    )))
        (let ((TO---   (binary:bin_to_list (aux:TO  ))))
        (let ((to---   (binary:bin_to_list to--      )))

        (logger:debug                     (++ FROM--- (aux:EQUALS) from---
            (aux:SPACE)(aux:V-BAR)(aux:SPACE) TO---   (aux:EQUALS) to---))

        (syslog:log syslog 'debug         (++ FROM--- (aux:EQUALS) from---
            (aux:SPACE)(aux:V-BAR)(aux:SPACE) TO---   (aux:EQUALS) to---)))))))
    ('true 'false))

    (let ((from (try(binary_to_integer from--) (catch(`#(error badarg ,_)0)))))
    (let ((to   (try(binary_to_integer to--  ) (catch(`#(error badarg ,_)0)))))

    (let ((is-request-malformed (if (or (< from 1) (< to 1)) 'true 'false)))
    ; -------------------------------------------------------------------------
    ; --- Parsing and validating request params - End -------------------------
    ; -------------------------------------------------------------------------

    (cond (is-request-malformed
        ; Not using the malformed_request/2 callback when responding
        ; with the HTTP 400 Bad Request status code; instead setting
        ; the response body and then sending the response, specifying
        ; the status code explicitly. All the required headers are already
        ; there, including the content-type, which is set correctly.
        (cowboy_req:reply (aux:HTTP-400-BAD-REQ) (cowboy_req:set_resp_body
        (jsx:encode `#M(
            error ,(list_to_binary (aux:ERR-REQ-PARAMS-MUST-BE-POSITIVE-INTS))
        )) req)))
    ('true
        ; Performing the routes processing to find out the direct route.
        (let ((direct (if (=:= from to) 'false
            (find-direct-route debug-log-enabled routes-list from to))))

        `#(,(jsx:encode `#M(
           ,(aux:FROM) ,from
           ,(aux:TO)   ,to
            direct     ,direct
        )) ,req ,state)))
    ))))))))
)

#| ----------------------------------------------------------------------------
 | @param debug-log-enabled The debug logging enabler.
 | @param routes-list       A list containing all available routes.
 | @param from-             The starting bus stop point.
 | @param to-               The ending   bus stop point.
 |
 | @returns `true' if the direct route is found, `false' otherwise.
 |#
(defun find-direct-route (debug-log-enabled routes-list from- to-)
    "Performs the routes processing (onto bus stops sequences) to identify
     and return whether a particular interval between two bus stop points
     given is direct (i.e. contains in any of the routes), or not."

    (let ((from (integer_to_list from-)))
    (let ((to   (integer_to_list to-  )))

    (try (progn
        (lists:foldl (lambda (route i)
            (if debug-log-enabled
                (logger:debug (++ (integer_to_list i)
                    (aux:SPACE)(aux:EQUALS)(aux:SPACE) route))
                'false)

            (let ((match-from
                (re:run route (++ (aux:SEQ1-REGEX) from (aux:SEQ2-REGEX)))))
            (if (is_tuple match-from)(cond ((=:= (element 1 match-from) 'match)
                ; Pinning in the starting bus stop point, if it's found.
                ; Next, searching for the ending bus stop point
                ; on the current route, beginning at the pinned point.
                (let ((route-from
                    (string:slice route (- (string:str route from) 1))))

                (if debug-log-enabled
                    (logger:debug (++ from
                        (aux:SPACE)(aux:V-BAR)(aux:SPACE) route-from))
                    'false)

                (let ((match-to (re:run route-from
                    (++ (aux:SEQ1-REGEX) to (aux:SEQ2-REGEX)))))
                (if (is_tuple match-to) (if (=:= (element 1 match-to) 'match)
                    (throw 'true) 'false) 'false))))
            ('true 'false)) 'false))

            (+ i 1)
        ) 1 routes-list) 'false)
    (catch
        (`#(throw true ,_) 'true)
    ))))
)

; vim:set nu et ts=4 sw=4:
