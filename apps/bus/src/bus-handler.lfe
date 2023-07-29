;
; apps/bus/src/bus-handler.lfe
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
 | @returns The list of media types the microservice provides when responding
 |          to the client. The special callback then will be called for any
 |          appropriate request regarding the corresponding media type:
 |          `application/json' is currently the only used one.
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

    (logger:debug (atom_to_list debug-log-enabled))

    ; -------------------------------------------------------------------------
    ; --- Parsing and validating request params - Begin -----------------------
    ; -------------------------------------------------------------------------
    (let ((`#M(from ,from- to ,to-) (cowboy_req:match_qs `(
        #(from () ,(aux:ZERO))
        #(to   () ,(aux:ZERO))
    ) req)))

    (let ((from-- (if (is_boolean from-) (aux:ZERO) from-)))
    (let ((to--   (if (is_boolean to-  ) (aux:ZERO) to-  )))

    (cond ((not debug-log-enabled)
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

    (logger:debug (integer_to_list from))
    (logger:debug (integer_to_list to  ))

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
            error ,(aux:ERR-REQ-PARAMS-MUST-BE-POSITIVE-INTS)
        )) req)))
    ('true
        ; Performing the routes processing to find out the direct route.
        (let ((direct (if (=:= from to) 'false
            'true))) ; <== TODO: Call find-direct-route/4 here.

        `#(,(jsx:encode `#M(
           ,(aux:FROM) ,from
           ,(aux:TO)   ,to
            direct     ,direct
        )) ,req ,state)))
    ))))))))
)

; vim:set nu et ts=4 sw=4:
