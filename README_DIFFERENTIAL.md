# README_DIFFERENTIAL

Minimal guide for generating differential flamegraphs using Pyroscope profiles.

## Requirements

Install latest Go + pprof:
```
go install github.com/google/pprof@latest
export PATH=$HOME/go/bin:$PATH
```

Install Brendan Gregg's FlameGraph tools:
```
git clone https://github.com/brendangregg/FlameGraph
```

## Generate Baseline Profile

1. Run demo + load generator.
2. Open Pyroscope UI → Export profile as `.pprof` or `.pb.gz`
```
mv baseline.pb.gz baseline.pb
```

Convert to SVG flamegraph:
```
pprof -svg baseline.pb > baseline.svg
```

## Apply Regression Change

Modify Java code, rebuild demo and generate load again.

Export new profile:
```
mv regression.pb.gz regression.pb
pprof -svg regression.pb > regression.svg
```

## Create Differential Flamegraph

```
./FlameGraph/difffolded.pl baseline.svg regression.svg > diff.svg
```

Open `diff.svg` in browser to view increases/decreases.
