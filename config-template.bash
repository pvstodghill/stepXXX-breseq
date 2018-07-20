# Uncomment to use native executables
#USE_NATIVE=1

# Uncomment to override default the number of used threads
#THREADS=5

# breseq is run using the `run_breseq` function, which is invoked as
# follows,
#
#     run_breseq [-d name ] replicon1.gbk replicon2.gbk ... \ 
#        -- reads1.fastq.gz  reads2.fastq.gz ... \
#        [-- other breseq args ]
#
# E.g., to compare a single set of reads against the DC3000 genome and
# write the output to the `results` directory.
#
#     run_breseq .../DC3000/NC_4*.gbk -- sequneces.fastq.gz
#
# The results can be written to a subdirectory of `results` using the
# `-d` option. E.g.,
#
#     # output to results/condition1
#     run_breseq -d condition1 .../DC3000/NC_4*.gbk -- sequneces1.fastq.gz
#     # output to results/condition2
#     run_breseq -d condition2 .../DC3000/NC_4*.gbk -- sequneces2.fastq.gz

