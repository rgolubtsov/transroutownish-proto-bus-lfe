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

    (let ((from 1))
    (let ((to 100))
    (let ((direct 'false))

    ; TODO: Implement "Parsing and validating request params" mech.

    `#(,(jsx:encode `#M(
       ,(aux:FROM) ,from
       ,(aux:TO)   ,to
        direct     ,direct
    )) ,req ,state))))
)

; vim:set nu et ts=4 sw=4:
