#!/bin/bash
# Copyright (C) 2012 Ion Torrent Systems, Inc. All Rights Reserved

# This is a fork of Matt Dyer's FastQC plugin for Ion Torrent Servers, which is
# itself a wrapper around Babraham institute's FastQC program.
# FastQC program: http://www.bioinformatics.bbsrc.ac.uk/projects/fastqc/
# FastQC plugin: https://ioncommunity.thermofisher.com/docs/DOC-2602
# FastQC version included: v0.10.1

VERSION="3.4.1.1.b" # major.minor.bug..temp

# ===================================================
# Plugin functions
# ===================================================

#*! @function
#  @param  $*  the command to be executed
run ()
{
    echo "running: $*"
    eval "$*";
    EXIT_CODE="$?";
    return ${EXIT_CODE}
}

#*! @function
#  @param  $*  the command to be executed
analyze ()
{
    BAM_FILE_PATH=$*
    BAM_FILE_NAME=${BAM_FILE_PATH##*/}
    FASTQC_OUT_DIR_BARCODE="${BAM_FILE_NAME%.bam}_fastqc"
    echo "Analyzing: ${BAM_FILE_NAME}"
    if ! [ -f ${TSP_FILEPATH_PLUGIN_DIR}/${FASTQC_OUT_DIR_BARCODE}/fastqc_report.html ]; then
        run ${FASTQC} "${BAM_FILE_PATH}" --outdir="${TSP_FILEPATH_PLUGIN_DIR}/";
        RET=$?  
    else
        echo "  ...output files already present. Skipping."
        RET=0
    fi
    if [ ${RET} -eq 0 ]; then  
        # s/.fastq/_fastqc/  
        BARCODE=${BAM_FILE_NAME%_*}
        printf "<li><a target=\"_blank\" href=\"${FASTQC_OUT_DIR_BARCODE}/fastqc_report.html\">FastQC Report - ${BARCODE}</a></li>\n" >> ${REPORT_HTML}  
    fi
}

#*! @function
set_output_paths ()
{
    PLUGIN_OUT_UNMAPPED_BAM_NAME=${TSP_FILEPATH_UNMAPPED_BAM##*/};
    PLUGIN_OUT_MAPPED_BAM_NAME=${TSP_FILEPATH_BAM##*/};
}

# ===================================================
# Plugin initialization
# ===================================================
# Test for the existence of the relevant input files.
test_for_file "${TSP_FILEPATH_UNMAPPED_BAM}";

# Set defaults
set_output_paths;

# Test for the existence of the relevant executables.
FASTQC="${DIRNAME}/FastQC/fastqc"
test_for_executable ${FASTQC};

FASTQC_VERSION=`${FASTQC} --version`

# Make sure plugin output is cleared of any previous results
if [ -f ${TSP_FILEPATH_PLUGIN_DIR} ]; then
    rm -rf "${TSP_FILEPATH_PLUGIN_DIR}/*_fastqc"
    rm -rf "${TSP_FILEPATH_PLUGIN_DIR}/*_block.html"
    rm -rf "${TSP_FILEPATH_PLUGIN_DIR}/FastQC_reports.html"
else
    mkdir -p "${TSP_FILEPATH_PLUGIN_DIR}"
fi

# ===================================================
# Run FastQC Plugin
# ===================================================

## Always run on combined file, if present:
if [ -f ${TSP_FILEPATH_UNMAPPED_BAM} ]; then
    FASTQC_OUT_DIR=${PLUGIN_OUT_UNMAPPED_BAM_NAME/%.bam/_fastqc}
    echo "Analyzing unmapped combined BAM file: ${TSP_FILEPATH_UNMAPPED_BAM}"
    run "${FASTQC} ${TSP_FILEPATH_UNMAPPED_BAM} --outdir=${RESULTS_DIR}/"
    RET=$?
elif [ -f ${TSP_FILEPATH_BAM} ]; then
    FASTQC_OUT_DIR=${PLUGIN_OUT_MAPPED_BAM_NAME/%.bam/_fastqc}
    echo "Analyzing combined BAM file: ${TSP_FILEPATH_BAM}"
    run "${FASTQC} ${TSP_FILEPATH_BAM} --outdir=${RESULTS_DIR}/"
    RET=$?
else
    echo "No combined BAM file is present. The biggest valid BAM found will be shown in the report page."
    RET=1
fi

# Initialize Report
REPORT_HTML=${RESULTS_DIR}/${PLUGINNAME}_block.html  
  
printf "<html>\n<body>\n" > ${REPORT_HTML}  
  
if [ ${RET} -eq 0 ]; then  
    (   
        #Show all data per_base_quality graph on block preview window  
        printf "<img width=\"600\" height=\"450\" src=\"${FASTQC_OUT_DIR}/Images/per_base_quality.png\"/><p>Per Base Sequence Quality - All Reads</p>\n"  
        # Add top level report  
        printf "<li><a target=\"_blank\" href=\"${FASTQC_OUT_DIR}/fastqc_report.html\">FastQC Report - All Reads</a></li>\n"  
    ) >> ${REPORT_HTML}  
else  
    printf "<p>No cumulative data found. Working...</p>" >> ${REPORT_HTML}
    # checking BAMs for the biggest one
    BIGGEST_BAM_PATH=$(find ${ANALYSIS_DIR} -maxdepth 2 -name "*.bam" -printf "%k KB\t%p\n" | sort -rn | head -1 | cut -f2)
    run ${FASTQC} "${BIGGEST_BAM_PATH}" --outdir="${TSP_FILEPATH_PLUGIN_DIR}/";
    RET=$?  
    if [ ${RET} -eq 0 ]; then  
        # s/.fastq/_fastqc/  
        BAM_FILE_NAME=${BIGGEST_BAM_PATH##*/}
        FASTQC_OUT_DIR_BARCODE="${BAM_FILE_NAME%.bam}_fastqc"
        printf "<img width=\"600\" height=\"450\" src=\"${FASTQC_OUT_DIR_BARCODE}/Images/per_base_quality.png\"/><p>Top image: Per Base Sequence Quality - Sample ${BAM_FILE_NAME}</p>\n" >> ${REPORT_HTML}  
    fi
fi  
  
# Barcoded run - append per-run results  
if [ -e "${TSP_FILEPATH_BARCODE_TXT}" ]; then  
    echo "Found barcode data at: ${TSP_FILEPATH_BARCODE_TXT}"  
    printf "<p>Barcode data found:</p>" >> ${REPORT_HTML}  
    # Checking mapped BAMs first
    printf "<p>Mapped BAM files:</p>" >> ${REPORT_HTML}
    for BAM_FILE_PATH in $(ls ${ANALYSIS_DIR}/*.bam 2>/dev/null | grep "IonXpress\|nomatch"); do
        analyze ${BAM_FILE_PATH}
    done
    printf "<p>Unmapped BAM files:</p>" >> ${REPORT_HTML}
    for BAM_FILE_PATH in $(ls ${BASECALLER_DIR}/*.bam 2>/dev/null | grep "IonXpress\|nomatch"); do
        analyze ${BAM_FILE_PATH}
    done
else
    echo "No barcode data found."  
    printf "<p>No barcode data found.</p>" >> ${REPORT_HTML}  
fi  
  
## Close up Report output  
(  
    printf "<p>Plugin execution ended.</p>\n"
    printf "</ul>\n"  
    printf "<pre>${FASTQC_VERSION}</pre>\n"  
    printf "</body>\n</html>\n"  
) >> ${REPORT_HTML}  


