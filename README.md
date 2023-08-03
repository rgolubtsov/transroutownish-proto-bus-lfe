# Trans-RoutE-Townish (transroutownish) :small_orange_diamond: Urban bus routing microservice prototype (LFE/OTP port)

**An LFE (Lisp Flavoured Erlang) application, designed and intended to be run as a microservice,
<br />implementing a simple urban bus routing prototype**

**Rationale:** This project is a *direct* **[LFE](https://lfe.io "Lisp-2+ dialect for the Erlang VM")** port of the earlier developed **urban bus routing prototype**, written in Erlang/OTP using **[Cowboy](https://ninenines.eu "Small, fast, modern HTTP server for Erlang/OTP")** web server library, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from there](https://github.com/rgolubtsov/transroutownish-proto-bus-cowboy)** as is, without any modifications or adjustment.

Consider an IoT system that aimed at planning and forming a specific bus route for a hypothetical passenger. One crucial part of such system is a **module**, that is responsible for filtering bus routes between two arbitrary bus stops where a direct route is actually present and can be easily found. Imagine there is a fictional urban public transportation agency that provides a wide series of bus routes, which covered large city areas, such that they are consisting of many bus stop points in each route. Let's name this agency **Trans-RoutE-Townish Co., Ltd.** or in the Net representation &mdash; **transroutownish.com**, hence the name of the project.

A **module** that is developed here is dedicated to find out quickly, whether there is a direct route in a list of given bus routes between two specified bus stops. It should immediately report back to the IoT system with the result `true` if such a route is found, i.e. it exists in the bus routes list, or `false` otherwise, by outputting a simple JSON structure using the following format:

```
{
    "from"   : <starting_bus_stop_point>,
    "to"     : <ending_bus_stop_point>,
    "direct" : true
}
```

`<starting_bus_stop_point>` and `<ending_bus_stop_point>` above are bus stop IDs: unique positive integers, taken right from inputs.

A bus routes list is a plain text file where each route has its own unique ID (positive integer) and a sequence of its bus stop IDs. Each route occupies only one line in this file, so that they are all representing something similar to a list &mdash; the list of routes. The first number in a route is always its own ID. Other consequent numbers after it are simply IDs of bus stops in this route, up to the end of line. All IDs in each route are separated by whitespace, usually by single spaces or tabs, but not newline.

There are some constraints:
1. Routes are considered not to be a round trip journey, that is they are operated in the forward direction only.
2. All IDs (of routes and bus stops) must be represented by positive integer values, in the range `1 .. 2,147,483,647`.
3. Any bus stop ID may occure in the current route only once, but it might be presented in any other route too.

The list of routes is usually mentioned throughout the source code as a **routes data store**, and a sample routes data store can be found in the `data/` directory of this repo.

Since the microservice architecture for building independent backend modules of a composite system are very prevalent nowadays, this seems to be natural for creating a microservice, which is containerized and run as a daemon, serving a continuous flow of HTTP requests.

This microservice is intended to be built locally and to be run like a conventional daemon in the VM environment, as well as a containerized service, managed by Docker.

One may consider this project has to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building a similar microservice, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

---

## Table of Contents

* **[Building](#building)**
  * **[Creating a Docker image](#creating-a-docker-image)**
* **[Running](#running)**
  * **[Running a Docker image](#running-a-docker-image)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**
  * **[Error handling](#error-handling)**

## Building

The microservice is known to be built and run successfully under **Ubuntu Server (Ubuntu 22.04.2 LTS x86-64)**. Install the necessary dependencies (`erlang-nox`, `erlang-dev`, `rebar3`, `make`, `docker.io`):

```
$ sudo apt-get update && \
  sudo apt-get install erlang-nox erlang-dev make docker.io -y
...
```

Rebar3 is preferred to install as the following:

```
$ curl -sO https://s3.amazonaws.com/rebar3/rebar3      && \
  chmod -v 700 rebar3 && ./rebar3 local install        && \
  export PATH=/home/<username>/.cache/rebar3/bin:$PATH && \
  rm -vf rebar3
...
```

The LFE (Lisp Flavoured Erlang) distribution can be downloaded and installed automatically as a dependency of the Rebar3 LFE plugin `rebar3_lfe`. For that to be done, it needs to simply launch the `$ rebar3` command without any arguments or options. The LFE distribution will be installed into the `./_build/default/plugins/lfe/` directory.

**Build** the microservice using **Rebar3** (and its LFE plugin):

```
$ rebar3         lfe clean;   \
  rebar3 as prod lfe clean
...
$ rebar3             compile; \
  rebar3 as prod     compile
...
$ rebar3         lfe release; \
  rebar3 as prod lfe release
...
```

Or **build** the microservice using **GNU Make** (optional, but for convenience &mdash; it covers the same **Rebar3** build workflow under the hood):

```
$ make clean
...
$ make      # <== Compilation phase.
...
$ make all  # <== Assembling releases of the microservice.
...
```

---

The following command given is for demonstrational purposes only &mdash; Rebar3 will always fetch necessary dependencies during a one of their building phases, even at the `clean`-ing phase:

```
$ rebar3 tree
===> Fetching rebar3_lfe v0.4.4
===> Fetching rebar_cmd v0.4.0
===> Fetching rebar3_hex v6.11.4
...
===> Fetching lfe v2.1.1
===> Fetching ltest v0.13.4
===> Fetching erlang_color v1.0.0
...
===> Verifying dependencies...
===> Fetching cowboy v2.10.0
===> Fetching jsx v3.1.0
===> Fetching syslog v1.1.0
===> Fetching pc v1.14.0
===> Analyzing applications...
...
└─ bus─0.3.2 (project app)
   ├─ cowboy─2.10.0 (hex package)
   │  ├─ cowlib─2.12.1 (hex package)
   │  └─ ranch─1.8.0 (hex package)
   ├─ jsx─3.1.0 (hex package)
   └─ syslog─1.1.0 (hex package)
```

### Creating a Docker image

**Build** a Docker image for the microservice:

```
$ # Pull the Erlang image first, if not already there:
$ sudo docker pull erlang:alpine
...
$ # Then build the microservice image:
$ sudo docker build -ttransroutownish/buslfe .
...
```

## Running

**Run** the microservice using its startup script along with the `foreground` command, that is meant "*Start release with output to stdout*":

```
$ ./_build/prod/rel/bus/bin/bus foreground; echo $?
...
```

The microservice then can be stopped, again by using its startup script along with the `stop` command, that is meant "*Stop the running node*". It should be issued in another terminal session, not the current one:

```
$ ./_build/prod/rel/bus/bin/bus stop; echo $?
0
```

To identify, which commands are available and what they mean, the startup script can be run without specifying a command or arguments:

```
$ ./_build/prod/rel/bus/bin/bus
Usage: bus [COMMAND] [ARGS]

Commands:

  foreground              Start release with output to stdout
  remote_console          Connect remote shell to running node
...
  stop                    Stop the running node
  restart                 Restart the applications but not the VM
...
  daemon                  Start release in the background with run_erl (named pipes)
...
  daemon_attach           Connect to node started as daemon with to_erl (named pipes)
...
```

Thus, to **run** the microservice as a daemon, in the background, the `daemon` command should be used instead:

```
$ ./_build/prod/rel/bus/bin/bus daemon; echo $?
0
```

The `daemon_attach` command then allows connecting to the microservice to make interactions with them. But the latter is not required at all regarding the true purpose of the microservice. And it can be stopped again with the `stop` command in the same terminal session.

### Running a Docker image

**Run** a Docker image of the microservice, deleting all stopped containers prior to that:

```
$ sudo docker rm `sudo docker ps -aq`; \
  export PORT=8765 && sudo docker run -dp${PORT}:${PORT} --name buslfe transroutownish/buslfe; echo $?
...
```

## Consuming

All the routes are contained in a so-called **routes data store**. It is located in the `data/` directory. The default filename for it is `routes.txt`, but it can be specified explicitly (if intended to use another one) in the `apps/bus/src/bus.app.src` file.

**Identify**, whether there is a direct route between two bus stops with IDs given in the **HTTP GET** request, searching for them against the underlying **routes data store**:

HTTP request param | Sample value | Another sample value | Yet another sample value
------------------ | ------------ | -------------------- | ------------------------
`from`             | `4838`       | `82`                 | `2147483647`
`to`               | `524987`     | `35390`              | `1`

The direct route is found:

```
$ curl 'http://localhost:8765/route/direct?from=4838&to=524987'
{"direct":true,"from":4838,"to":524987}
```

The direct route is not found:

```
$ curl 'http://localhost:8765/route/direct?from=82&to=35390'
{"direct":false,"from":82,"to":35390}
```

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. Logs can be seen and analyzed by `tail`ing the `_build/prod/rel/bus/log/bus.log` logfile:

```
$ tail -f _build/prod/rel/bus/log/bus.log
...
[2023-07-31|01:20:11.256584+03:00][info]  Server started on port 8765
[2023-07-31|01:20:11.257210+03:00][info]  Application: bus. Started at: bus@localhost.
[2023-07-31|01:21:25.207825+03:00][debug]  from=4838 | to=524987
[2023-07-31|01:21:50.882326+03:00][debug]  from=82 | to=35390
[2023-07-31|01:25:35.616223+03:00][info]  Server stopped
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Jul 31 01:20:10 <hostname> bus[<pid>]: Starting up
Jul 31 01:20:11 <hostname> bus[<pid>]: Server started on port 8765
Jul 31 01:21:25 <hostname> bus[<pid>]: from=4838 | to=524987
Jul 31 01:21:50 <hostname> bus[<pid>]: from=82 | to=35390
Jul 31 01:25:35 <hostname> bus[<pid>]: Server stopped
```

### Error handling

When the query string passed in a request, contains inappropriate input, or the URI endpoint doesn't contain anything else at all after its path, the microservice will respond with the **HTTP 400 Bad Request** status code, including a specific response body in JSON representation, like the following:

```
$ curl 'http://localhost:8765/route/direct?from=qwerty4838&to=-i-.;--089asdf../nj524987'
{"error":"Request parameters must take positive integer values, in the range 1 .. 2,147,483,647. Please check your inputs."}
```

Or even simpler:

```
$ curl http://localhost:8765/route/direct
{"error":"Request parameters must take positive integer values, in the range 1 .. 2,147,483,647. Please check your inputs."}
```

**TBD** :dvd:
