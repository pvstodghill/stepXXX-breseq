#! /bin/bash

# ------------------------------------------------------------------------
# set up the runtime environment
# ------------------------------------------------------------------------

# exit on error
set -e

if [ "$PVSE" ] ; then
    # In order to help test portability, I eliminate all of my
    # personalizations from the PATH.
    export PATH=/usr/local/bin:/usr/bin:/bin
fi

# ------------------------------------------------------------------------
# Check the config file
# ------------------------------------------------------------------------

THIS_DIR=$(dirname $BASH_SOURCE)
CONFIG_SCRIPT=$THIS_DIR/config.bash
if [ ! -e "$CONFIG_SCRIPT" ] ; then
    echo 1>&2 Cannot find "$CONFIG_SCRIPT"
    exit 1
fi

# ------------------------------------------------------------------------
# These functions implement the computation.
# ------------------------------------------------------------------------

function setup_variables {
    [ "$ROOT_DIR" ] || ROOT_DIR=$(./scripts/find-closest-ancester-dir $THIS_DIR $FASTQ $REPLICONS)
    if [ -z "$USE_NATIVE" ] ; then
	# use docker
	[ "$HOWTO" ] || HOWTO="./scripts/howto -f packages.yaml -m $ROOT_DIR"
	[ "$THREADS" ] || THREADS=$(./scripts/howto -f packages.yaml -q -c breseq nproc)
    else
	# go native
	HOWTO=
	THREADS=$(nproc)
    fi

}

# run_breseq [-d name ] replicon1.gbk replicon2.gbk ... \ 
#    -- reads1.fastq.gz  reads2.fastq.gz ... \
#    [-- other breseq args ]

function run_breseq {
    OUT_DIR=results
    NAME=results
    if [ "$1" = "-d" ] ; then
	if [ -z "$2" ] ; then
	    echo 1>&2 "Missing argument after -d"
	    exit 1
	fi
	OUT_DIR=results/$2
	NAME="$2"
	shift 2
	rm -rf $OUT_DIR
	mkdir -p $OUT_DIR
    fi

    REPLICONS=""
    REPLICONS_ARGS=""
    while [ -n "$1" -a "$1" != "--" ] ; do
	REPLICONS+=" $1"
	REPLICONS_ARGS+=" -r$1"
	shift 1
    done
    if [ "$1" = "--" ] ; then
	shift 1
    fi
    FASTQ=""
    while [ -n "$1" -a "$1" != "--" ] ; do
	FASTQ+=" $1"
	shift 1
    done
    if [ "$1" = "--" ] ; then
	shift 1
    fi

    if [ -z "$REPLICONS" ] ; then
	echo 1>&2 "No replicons specified"
	exit 1
    fi
    if [ -z "$FASTQ" ] ; then
	echo 1>&2 "No FASTQ files specified"
	exit 1
    fi


    setup_variables
    (
	set -x
	${HOWTO} breseq -k -j ${THREADS} -o ${OUT_DIR} -n ${NAME} "$@" ${REPLICONS_ARGS} ${FASTQ}
    )
}

# ------------------------------------------------------------------------
# create empty `results` and `temp` directories
# ------------------------------------------------------------------------

(
    set -x
    cd $THIS_DIR
    rm -rf results #temp
    mkdir results #temp
)

# ------------------------------------------------------------------------
# Read the config file, which performs the actual computation.
# ------------------------------------------------------------------------

. "$CONFIG_SCRIPT"

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------
