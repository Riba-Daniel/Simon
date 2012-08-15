#!/bin/sh

# build.sh
# dUsefulStuff
#
# Created by Derek Clarkson on 27/08/10.
# Copyright 2010 Derek Clarkson. All rights reserved.

DC_SCRIPTS_DIR=../dUsefulStuff/scripts

# build specific.
DC_PROJECT_VERSION=0.1.9
DC_PROJECT_NAME=Simon
DC_SRC_DIR=classes
DC_BUILD_SCHEME="Simon"
DC_COMPANY_ID=au.com.derekclarkson
DC_AUTHOR="Derek Clarkson"
DC_PUBLIC_HEADER_PATH=include/$DC_PROJECT_NAME

# Include common scripts.
source $DC_SCRIPTS_DIR/defaults.sh
source $DC_SCRIPTS_DIR/common.sh

# Clean and setup.
$DC_SCRIPTS_DIR/clean.sh

$DC_SCRIPTS_DIR/createDocumentation.sh

compileWorkspace iphonesimulator5.1 i386 i386
compileWorkspace iphoneos6.0 "armv6 armv7" "armv6 armv7"

$DC_SCRIPTS_DIR/buildStaticLibrary.sh
$DC_SCRIPTS_DIR/assembleFramework.sh

# Copy API documentation to web site.
rm -fr ../drekka.github.com/simon/api/*
cp -vR build/appledoc/html/* ../drekka.github.com/simon/api

# Copy change log.
cp -v ChangeLog.textile ../drekka.github.com/simon

# Final assembly.
$DC_SCRIPTS_DIR/createDmg.sh
