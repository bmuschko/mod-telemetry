# Using logstash

[Logstash](https://www.elastic.co/docs/reference/logstash) is an open source data collection engine with real-time pipelining capabilities. Logstash can dynamically unify data from disparate sources and normalize the data into destinations of your choice. Cleanse and democratize all your data for diverse advanced downstream analytics and visualization use cases.

While Logstash originally drove innovation in log collection, its capabilities extend well beyond that use case. Any type of event can be enriched and transformed with a broad array of input, filter, and output plugins, with many native codecs further simplifying the ingestion process. Logstash accelerates your insights by harnessing a greater volume and variety of data.

## Starting logstash

Install logstash as described in the [installation instructions](https://www.elastic.co/downloads/logstash). Navigate to the installation directory of logstash. The executable can be found in the `bin` directory.

To start logstash, you need a [pipeline](https://www.elastic.co/docs/reference/logstash/creating-logstash-pipeline) file. The file [build-metrics-pipeline.conf](./build-metrics-pipeline.conf) defines a pipeline that accepts HTTP requests on port 8080 and defines the schema of the metrics produced by the `mod build` operation.

```
bin/logstash -f build-metrics-pipeline.conf
```

## Sending a data request

Navigate to the file you are interested in sending. For example, you send `mod build` metrics, navigate to `~/.moderne/cli/trace/build`. Select one of the files produced by a `mod build` execution, e.g. `trace-20250822112755-kp61K.csv`.

```
curl -X POST http://localhost:8080 \
  -H "Content-Type: text/csv" \
  --data-binary @trace-20250822112755-kp61K.csv
```