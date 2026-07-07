#!/usr/bin/env bash
###############################################################################
# run_tests.sh
#
# Compiles INTCALC.cbl, runs it against the known sample dataset, and
# verifies the output report matches the expected baseline exactly.
# Acts as a simple regression test for a COBOL batch job — the same
# pattern used in real mainframe shops before promoting a change to
# the next environment.
###############################################################################
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/src/INTCALC.cbl"
WORKDIR="$(mktemp -d)"

echo "==> Compiling $SRC"
cobc -x -o "$WORKDIR/intcalc" "$SRC"

echo "==> Running against sample dataset"
cp "$ROOT_DIR/tests/sample_accounts.txt" "$WORKDIR/ACCTIN"
( cd "$WORKDIR" && ./intcalc )

echo "==> Comparing output to expected baseline"
if diff -u "$ROOT_DIR/tests/expected_output.txt" "$WORKDIR/ACCTRPT"; then
    echo "PASS: report output matches expected baseline"
    rm -rf "$WORKDIR"
    exit 0
else
    echo "FAIL: report output differs from expected baseline"
    rm -rf "$WORKDIR"
    exit 1
fi
