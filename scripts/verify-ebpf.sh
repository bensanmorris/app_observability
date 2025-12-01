#!/bin/bash
echo "Checking BPF, BTF, and kernel capabilities..."
ls /sys/kernel/btf/vmlinux && echo "✓ BTF available"
uname -r
bpftool feature probe
