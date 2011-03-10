#!/usr/bin/env zsh
# encoding: utf-8
# set_compile_flags.zsh

function set_compile_flags() {
    _archs="${1:-x86_64,i386}"
    _carchflag=""
    _parchflag=""
    for _af in i386 x86_64 ppc; do
      if (echo "${_archs}" | grep ${_af} > /dev/null); then
        _carchflag="${_carchflag} -arch ${_af}"
        print "Flags for ${_af} were added."
      else
        print "Flags for ${_af} were \E[1mnot\E[m\017 added."
      fi
    done
    

    
    if (echo "${_archs}" | grep 386 > /dev/null); then
        _parchflag="${_parchflag} -m32"
    fi
    if (echo "${_archs}" | grep 64 > /dev/null); then
        _parchflag="${_parchflag} -m64"
    fi

    TRIPLE="x86_64-apple-darwin10"
    export BUILD=$TRIPLE TARGET=$TRIPLE HOST=$TRIPLE


    CFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"
    CXXFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"
    CCFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"
    OBJCFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"
    OBJCXXFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"
    FCFLAGS="${_carchflag} ${_parchflag} -g -Os -pipe"

    FFLAGS="${_carchflag} ${_parchflag} -g -Os"
    CPPFLAGS="-I/usr/include -I/usr/local/include -I/Developer/usr/include -I/opt/local/include"
    CXXCPPFLAGS=$CPPFLAGS
    LDFLAGS="${_carchflag}${_parchflag} -L/usr/lib -L/usr/local/lib -L/Developer/usr/lib -L/opt/local/lib"
    CC=/usr/bin/gcc
    CXX=/usr/bin/g++
    F77=/usr/bin/gfortran
    CPP=$CC\ -E
    CXXCPP=$CXX\ -E
    cc=$CC
    GCC=$CC
    F90=$F77
    F95=$F77
    FC=$F77
    export CC CXX F77 CPP CXXCPP cc GCC F90 F95 FC
    export CFLAGS CXXFLAGS CCFLAGS OBJCFLAGS OBJCXXFLAGS FCFLAGS CPPFLAGS CXXCPPFLAGS LDFLAGS
}


