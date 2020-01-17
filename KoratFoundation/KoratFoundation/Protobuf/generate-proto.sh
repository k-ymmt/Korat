#!/usr/bin/env bash

dir=$(dirname $0)

function generate_protobuf() {
  protoc $dir/$1 \
    --swift_opt=Visibility=Public \
    --proto_path=$dir \
    --plugin=$HOME/bin/protoc-gen-swift \
    --swift_out=$dir
}

function generate_grpc() {
  protoc $dir/$1 \
    --proto_path=$dir \
    --plugin=$HOME/bin/protoc-gen-grpc-swift \
    --grpc-swift_opt=Server=true,Client=true,Visibility=Public \
    --grpc-swift_out=$dir
}

generate_protobuf log.proto

generate_protobuf MobileDeviceService.proto
generate_grpc MobileDeviceService.proto
