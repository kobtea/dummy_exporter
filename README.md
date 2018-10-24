# dummy_exporter

[![CircleCI](https://circleci.com/gh/kobtea/dummy_exporter.svg?style=svg)](https://circleci.com/gh/kobtea/dummy_exporter)
[![Go Report Card](https://goreportcard.com/badge/github.com/kobtea/dummy_exporter)](https://goreportcard.com/report/github.com/kobtea/dummy_exporter)

## Overview

`dummy_exporter` exports meaningless metrics for [Prometheus](https://prometheus.io/).
It is used for performance testing or developing to the prometheus ecosystem.


## Install

### Binary

Go to https://github.com/kobtea/dummy_exporter/releases

### Building from source

```bash
$ go get -d github.com/kobtea/dummy_exporter
$ cd $GOPATH/src/github.com/kobtea/dummy_exporter
$ dep ensure
$ make build
```

### Docker container

https://hub.docker.com/r/kobtea/dummy_exporter/

```bash
$ docker run -p 9510:9510 -v /PATH/TO/config.yml:/etc/dummy_exporter.yml kobtea/dummy_exporter
```


## Usage

```bash
$ ./dummy_exporter --help
usage: dummy_exporter [<flags>]

Flags:
  -h, --help              Show context-sensitive help (also try --help-long and --help-man).
      --web.listen-address=":9510"
                          Address to listen on for web interface and telemetry
      --web.telemetry-path="/metrics"
                          Path under which to expose metrics.
      --config=""         Path to config file
      --log.level="info"  Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal]
      --log.format="logger:stderr"
                          Set the log target and format. Example: "logger:syslog?appname=bob&local=7" or "logger:stdout?json=true"
      --version           Show application version.
```

Configuration format is below.

```yaml
# config.yml
metrics:
- name: <string>
  # support type are "counter" and "gauge"
  type: <string>
  # number of metrics
  size: <integer>
  labels:
    # label maps, it decide value with round robin
    <string>: [<string>, ...]
```

sample

```yaml
metrics:
- name: foo
  type: counter
  size: 1
- name: bar
  type: gauge
  size: 5
  labels:
    l1: [one, two, three]
    l2: [aaa]
```

```
$ curl -s localhost:9510/metrics | egrep dummy
# HELP dummy_bar dummy gauge
# TYPE dummy_bar gauge
dummy_bar{id="0",l1="one",l2="aaa"} 0.011785717417686026
dummy_bar{id="1",l1="two",l2="aaa"} 0.5018172515345635
dummy_bar{id="2",l1="three",l2="aaa"} 0.29800435709983797
dummy_bar{id="3",l1="one",l2="aaa"} 0.7182748953550191
dummy_bar{id="4",l1="two",l2="aaa"} 0.6318883214044725
# HELP dummy_foo dummy counter
# TYPE dummy_foo counter
dummy_foo{id="0"} 1
```


## License

MIT
