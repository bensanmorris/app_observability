# Performance regression detection (differential flamegraphs)

Differential CPU flamegraph workflow using **Pyroscope**, **pprof**, and **Brendan Gregg FlameGraph tools**.

This guide shows how to:

1. Capture a **baseline** CPU profile  
2. Modify Java code to introduce a **regression**  
3. Capture a second profile  
4. Generate a **differential flamegraph** highlighting performance impact  


## Requirements

### Install latest Go + pprof

```bash
go install github.com/google/pprof@latest
echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```


## Generate Baseline Profile

1. Ensure the demo + Pyroscope is running
2. Open **Pyroscope UI → Select CPU Profile → Export → .pprof / .pb.gz**

Rename export:

```bash
mv profile.pb.gz baseline.pb.gz
```

Optional — generate flamegraph for visual reference:

```bash
pprof -svg baseline.pb.gz > baseline.svg
```


## Modify Java Code to Introduce Regression

Example slowdown (replace code in Main.java with the code below):

```java
public class Main {
    private static volatile double sink;

    public static void main(String[] args) {
        while (true) {
            sink = burnCPU();
        }
    }

    private static double burnCPU() {
        double x = 0;
        for (int i = 0; i < 5000; i++) { // reduce outer to avoid waiting forever

            x += Math.pow(Math.random(), Math.random());

            // Regression: heavy and impossible to optimize away
            for (int j = 0; j < 2_000_000; j++) {
                x += Math.sin(j + System.nanoTime()) * Math.cos(j + System.nanoTime());
            }
        }
        sink = x;
        return x;
    }
}
```

### Rebuild and redeploy service

```bash
cd java-demo
docker build -t java-demo:latest .
kind load docker-image java-demo:latest --name observability-demo
kubectl rollout restart deploy/java-demo -n observability-demo
kubectl rollout status deploy/java-demo -n observability-demo
```

## Generate Regression Profile

Export new Pyroscope profile:

```bash
mv profile.pb.gz regression.pb.gz
```

Optional:

```bash
pprof -svg regression.pb.gz > regression.svg
```

---

## Create Differential Flamegraph

NB. It's assumed you have your baseline and regression files in the differential directory.

### Install FlameGraph utilities

```bash
cd differential
git clone https://github.com/brendangregg/FlameGraph
```

Convert both profiles into folded format:

```bash
go tool pprof -raw baseline.pb.gz | ./FlameGraph/stackcollapse-go.pl > baseline.folded
go tool pprof -raw regression.pb.gz | ./FlameGraph/stackcollapse-go.pl > regression.folded
```

Generate differential flamegraph output:

```bash
./FlameGraph/difffolded.pl baseline.folded regression.folded > diff.folded
./FlameGraph/flamegraph.pl --colors=diff --negate diff.folded > diff.svg
xdg-open diff.svg
```

### Reading the diff

| Colour | Meaning |
|-------|---------|
| 🔥 **Red** | CPU usage **increased** (regression) |
| 🟢 **Green** | CPU usage **decreased** (improvement) |
| ⚪ Grey | No significant change |

---

## Output Summary

```
baseline.pb.gz      ← before changes
regression.pb.gz    ← after regression
diff.svg            ← differential flamegraph
```

