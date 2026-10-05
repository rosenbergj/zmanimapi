#!/usr/bin/env bash
# Build the Lambda dependency layer zip (build/layer.zip) from uv.lock.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf build
mkdir -p build/layer

uv export --frozen --no-dev --no-emit-project -o build/requirements.txt

# Lambda's python3.13 runtime is Amazon Linux 2023 (glibc 2.34). Compiled packages
# must be prebuilt wheels; pymeeus ships only source, but it's pure Python.
uv pip install -r build/requirements.txt --target build/layer/python \
  --python-platform x86_64-manylinux_2_34 --python-version 3.13 \
  --only-binary :all: --no-binary pymeeus

(cd build/layer && zip -qr ../layer.zip python)
echo "Built build/layer.zip"
