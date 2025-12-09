# Pyroscope Java Agent Profiling Engines

This document describes how to choose between the two profiling engines used by the
Pyroscope Java agent, and how to configure them via environment variables.

## Profiling engine: async-profiler vs JFR (Pyroscope Java agent)

The Pyroscope Java agent can use two different profiling engines:

- **Default:** [`async-profiler`](https://github.com/jvm-profiling-tools/async-profiler)
- **Optional:** JVM’s built-in **Java Flight Recorder (JFR)**

You choose the engine via the `PYROSCOPE_PROFILER_TYPE` environment variable.

---

## Default (async-profiler)

On Linux (RHEL 7/8/9, etc.) the agent uses **async-profiler** by default – you don’t need
to set anything special:

```bash
export PYROSCOPE_APPLICATION_NAME=java-demo
export PYROSCOPE_SERVER_ADDRESS=http://pyroscope:4040

java -javaagent:/opt/pyroscope/pyroscope.jar      -jar app.jar
```

**Characteristics:**

- Low-overhead sampling profiler
- Good visibility into **Java, native, and kernel** frames
- Supports CPU, allocation, and lock profiling
- Great for **deep performance investigations** on Linux

This is usually the best option for Linux servers with `perf_events` enabled.

---

## JFR-based profiling

You can tell the Pyroscope agent to use JVM’s built-in **JFR** instead:

```bash
export PYROSCOPE_APPLICATION_NAME=java-demo
export PYROSCOPE_SERVER_ADDRESS=http://pyroscope:4040

# Use JFR instead of async-profiler:
export PYROSCOPE_PROFILER_TYPE=JFR

# (Recommended) send data to Pyroscope in JFR format:
export PYROSCOPE_FORMAT=jfr

java -javaagent:/opt/pyroscope/pyroscope.jar      -jar app.jar
```

**Characteristics:**

- Uses the **JFR engine built into the JVM**
- Designed for **always-on, low-overhead** production profiling
- Works in environments where `perf_events` / eBPF are restricted
- Aligns nicely if you already use **JFR + Mission Control**

---

## When to use which?

| Engine          | Use when…                                                                 |
|-----------------|---------------------------------------------------------------------------|
| async-profiler  | Linux (RHEL 8/9 etc.), you want maximum detail incl. native/kernel code. |
| JFR             | Windows or locked-down Linux, or when you prefer sticking to pure JFR.   |

Both engines feed data into the same Pyroscope backend, so you can switch between them
just by changing environment variables.
