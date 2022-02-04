FROM ubuntu:21.04
MAINTAINER Mario Campos <mario-campos@github.com>
ARG build_type=Release

# Set the timezone so that apt-get(1) doesn't prompt for it.
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -qq \
    gcc \
    g++ \
    cmake \
    libgmp-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libboost-test-dev \
    python \
    libsqlite3-dev \
    libtbb-dev \
    libz-dev \
    libedit-dev \
    llvm-9 \
    llvm-9-dev \
    llvm-9-tools \
    clang-9

ADD https://github.com/NASA-SW-VnV/ikos/releases/download/v3.0/ikos-3.0.tar.gz .
RUN tar zxf ikos-3.0.tar.gz && mkdir ikos-3.0/build
RUN cd ikos-3.0/build && \
    MAKEFLAGS=-j2 cmake \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_BUILD_TYPE="$build_type" \
      -DLLVM_CONFIG_EXECUTABLE=/usr/lib/llvm-9/bin/llvm-config \
      .. && \
    make && make check && make install

RUN rm -rf ikos-3.0 ikos-3.0.tar.gz
