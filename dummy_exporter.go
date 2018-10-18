package main

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/prometheus/common/version"
	"gopkg.in/alecthomas/kingpin.v2"
	"log"
	"net/http"
)

var (
	listenAddress = kingpin.Flag("web.listen-address", "Address to listen on for web interface and telemetry").Default(":9999").String()
	metricsPath   = kingpin.Flag("web.telemetry-path", "Path under which to expose metrics.").Default("/metrics").String()
)

type collector struct{}

func newCollector() (*collector, error) {
	return &collector{}, nil
}

func (collector collector) Describe(ch chan<- *prometheus.Desc) {}

func (collector collector) Collect(ch chan<- prometheus.Metric) {}

func main() {
	kingpin.Version(version.Print("dummy_exporter"))
	kingpin.HelpFlag.Short('h')
	kingpin.Parse()

	collector, err := newCollector()
	if err != nil {
		log.Fatal(err)
	}
	prometheus.MustRegister(collector)

	http.Handle(*metricsPath, promhttp.Handler())
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`<html>
             <head><title>Dummy Exporter</title></head>
             <body>
             <h1>Dummy Exporter</h1>
             <p><a href='` + *metricsPath + `'>Metrics</a></p>
             </body>
             </html>`))
	})
	log.Fatal(http.ListenAndServe(*listenAddress, nil))
}
