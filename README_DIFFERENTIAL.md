# README_DIFFERENTIAL

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

### Install FlameGraph utilities

```bash
git clone https://github.com/brendangregg/FlameGraph
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

Example slowdown:

```java
try { Thread.sleep(200); } catch (Exception ignored) {}
```

Or CPU burner loop:

```java
for (int i = 0; i < 50_000_000; i++) {
    Math.sqrt(i);
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

Convert both profiles into folded format:

```bash
pprof -raw baseline.pb.gz | ./FlameGraph/stackcollapse-go.pl > baseline.folded
pprof -raw regression.pb.gz | ./FlameGraph/stackcollapse-go.pl > regression.folded
```

Generate differential flamegraph output:

```bash
./FlameGraph/difffolded.pl baseline.folded regression.folded > diff.svg
```

Open `diff.svg` in your browser.

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

