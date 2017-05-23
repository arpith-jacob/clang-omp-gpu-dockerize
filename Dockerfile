FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Arpith Jacob <arpith@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            libelf \
            libffi \
            python \
            build-essential \
            git \
            cmake \
            ninja-build

RUN mkdir -p /opt/ibm/sources && \
    mkdir -p /opt/ibm/build && \
    mkdir -p /opt/ibm/clang-ykt && \
    cd /opt/ibm/sources && \
    git clone https://github.com/clang-ykt/llvm && \
    cd /opt/ibm/sources/llvm/tools && git clone https://github.com/clang-ykt/clang && \
    cd /opt/ibm/sources/llvm/projects && git clone https://github.com/clang-ykt/openmp && \
    cd /opt/ibm/build && \
    cmake  -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/opt/ibm/clang-ykt \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DCMAKE_C_FLAGS='-DOPENMP_NVPTX_COMPUTE_CAPABILITY=37 -mcpu=pwr8' \
    -DCMAKE_CXX_FLAGS='-DOPENMP_NVPTX_COMPUTE_CAPABILITY=37 -mcpu=pwr8' \
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITY=37 \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=true \
    -G \
    Ninja \
    ../sources/llvm && \
    ninja

ENV LD_LIBRARY_PATH=/opt/ibm/clang-ykt/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/opt/ibm/clang-ykt/lib:$LIBRARY_PATH
ENV PATH=/opt/ibm/clang-ykt/bin:$PATH

# Compiler is built in /opt/ibm/clang-ykt/bin/
