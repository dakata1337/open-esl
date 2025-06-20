#!/bin/sh
set -e

function build_proj() {
    prev=$PWD
    cd $1
    archive="../$(basename $PWD)-gerber.zip"
    rm -f $archive
    7z a $archive build/*
    cd $prev
}

build_proj "jade-ii-spacer"
build_proj "jade-ii-stator"
