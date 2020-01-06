#!/usr/bin/env bash

dir=$(dirname $0)

protoc $dir/MobileDeviceService.proto --proto_path=$dir --plugin=$HOME/bin/protoc-gen-swift --swift_out=$dir --plugin=$HOME/bin/protoc-gen-grpc-swift --grpc-swift_opt=Server=true,Client=true --grpc-swift_out=$dir

protoc $dir/Log.proto --proto_path=$dir --plugin=$HOME/bin/protoc-gen-swift --swift_out=$dir
