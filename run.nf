//#time ../../bin/nextflow scripts/run.nf --train=samples/small.fa --train=samples/small.fa//
//#!/usr/bin/env nextflow

params.db = "$HOME/tools/blast-db/pdb/pdb"
DB=params.db

params.train = "$HOME/samples/train.fa"
params.test = "$HOME/samples/test.fa"

seq = channel()

task("callTFPSSM_train") {
    input params.train
    output tranTFPSSM

    """
    #if not exists file => genTFPSSM
    #../../bin/nextflow scripts/blast.nf --query=$fa --output=$tranTFPSSM
    """
}

task("callTFPSSM_test") {
    input params.test
    output testTFPSSM

    """
    #if not exists file => genTFPSSM
    #../../bin/nextflow scripts/blast.nf --query=$fa --output=$tranTFPSSM
    """
}

task("pred") {
    input tranTFPSSM
    input testTFPSSM
    output 

    """
    "R --slave --args $tranTFPSSM $testTFPSSM CA_plot.csv, CA_pred.csv < per_CA.R"
    """
}

