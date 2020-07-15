#! /bin/bash
# standard checks to run after editing to verify that the basic functionality will still succeed

export LC_NUMERIC=C
# set up indication colours (hack style test, but it works)
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW='\033[0;33m'
NOCOLOR="\033[0m"


# simple input to provide input msfile
if [[ "$#" -lt 1 ]]
then
    # TODO: need to improve the unpacking of the input parameters
    echo "Usage: $0 <msfile> [-c|--clean] [-v|--verbose]"
    exit 1
fi
msfile=$1; shift
verbose=0
# handle optional arguments if they exist, ignore the rest
while [[ $# -gt 0 ]]
    do
    key=$1
    case $key in
        -c | --clean)
            # clean previous output
            make clean
            shift  # past argument
            ;;
        -v | --verbose)
            # show png output graphs
            verbose=1
            shift  # past argument
            ;;
        *)  # unknown options
            shift  # past unknown arguments
            ;;
    esac
done

function runcmd {
    CMD="shadems $msfile $ARGS"
    if [ -n "$figname" ]
    then
        CMD="$CMD --png $figname"
    fi
    echo $CMD

    if $CMD
        then
            echo -e "${GREEN} Success ${NOCOLOR}"
        else
            echo -e "${RED} Failure ${NOCOLOR}"
            if [[ $succeed == 1 ]]
            then
                exit 1
            fi
        fi
    echo
}

# running options for testing (still need more work, this in only framework starting)
basename='testim.png'

## check everything still working
succeed=1  # test is expected to pass
ARGS="--field 0 --corr XX,YY"
runcmd $msfile $ARGS
ARGS="--xaxis FREQ --yaxis DATA:amp --field 0 --corr XX,YY"
runcmd $msfile $ARGS
ARGS="--xaxis TIME,TIME --yaxis DATA:amp:XX,DATA:amp:YY --field 0"
runcmd $msfile $ARGS
ARGS="--xaxis TIME,FREQ --yaxis DATA:amp:XX,DATA:amp:YY --field 0"
runcmd $msfile $ARGS
ARGS="--xaxis TIME,FREQ --yaxis DATA:amp:XX,YY --field 0 --corr XX,YY --cmin 0 --cmax 5 --xmin 0.85e9 --xmax 1.712e9"
runcmd $msfile $ARGS
ARGS="--xaxis TIME,FREQ --yaxis DATA:amp:XX,YY --field 0 --cmin 0,0 --cmax 5,5 --xmin 0.85e9 --xmax 1.712e9"
runcmd $msfile $ARGS
ARGS="--xaxis TIME --yaxis amp -C DATA --corr XX,YY --field 0 --chan 10:21:2"
runcmd $msfile $ARGS

## induce first parser error to check len(xaxes) vs len(yaxes)
succeed=0  # test is expected to pass
ARGS="--xaxis TIME --yaxis DATA:amp:XX,DATA:amp:YY --field 0"
runcmd $msfile $ARGS
## induce second parser error to check all list options are = len to len(xaxes)
ARGS="--xaxis TIME,FREQ --yaxis DATA:amp:XX,YY --field 0 --corr XX,YY --cmin 0,0,1 --cmax 5,5,5 --xmin 0.85e9 --xmax 1.712e9"
runcmd $msfile $ARGS
## induce third parser error to check that both min and max limits are specified
ARGS="--xaxis TIME --yaxis DATA:amp --field 0 --xmin 0.85e9"
runcmd $msfile $ARGS
ARGS="--xaxis TIME --yaxis DATA:amp --field 0 --xmax 1.712e9"
runcmd $msfile $ARGS
## induce fourth parser error to check channel slicing input
ARGS="--xaxis TIME --yaxis amp -C DATA --corr XX,YY --field 0 --chan 10:21,4"
runcmd $msfile $ARGS



# echo $CMD
# $CMD
# echo
# CMD="shadems msfiles/small.ms --xaxis TIME,TIME --yaxis DATA:amp:XX,DATA:amp:YY --field 0"
# echo $CMD
# $CMD
# echo
# 
# # plot limits

# figname="plot-basic-$basename"
# runcmd $msfile $ARGS $figname
# 

# # options for plot generation from easy to difficult to evaluate that all succeed during development
# CMD="shadems msfiles/medium.ms --xaxis FREQ --yaxis DATA:amp --field 0 --corr XX,YY --xmin 0.85e9 --xmax 1.712e9"
# echo $CMD
# $CMD
# echo
# ARGS="--xaxis FREQ --yaxis DATA:amp --field 0 --corr XX,YY --xmin 0.85e9 --xmax 1.712e9"
# figname="plot-withlimits-$basename"
# runcmd $msfile $ARGS $figname
# 
# # set colours
# ARGS="--xaxis FREQ --yaxis DATA:amp --field 0 --corr XX,YY --colour-by DATA:amp --xmin 0.85e9 --xmax 1.712e9"
# figname="plot-colourbyAMP-$basename"
# runcmd $msfile $ARGS $figname

# show output graphs
if [[ $verbose == 1 ]]
then
    echo "show generated output images"
    for file in *.png
    do
        echo $file
        xdg-open $file
    done
fi

# -fin-

