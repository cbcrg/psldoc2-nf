PSLDoc2
=======

PSLDoc2 is the extended version of PSLDoc and it is implemented based on the nextflow framework.
https://github.com/paoloditommaso/nextflow

web site: 
http://tcoffee.crg.cat/psldoc2

Dependencies
------------

 * PSI-BLAST (Position-Specific Initiated BLAST 2.2.28+)
 * FactoMineR R package (it requires R packages: car, ellipse, lattice, cluster, scatterplot3d, leaps) http://cran.r-project.org/web/packages/FactoMineR/index.html
 

Stand alone version
------------

Prediction
------------

 * Model: 
 * prokaryotic : PSORTb v3 data
 * eukaryotic
 *  plant protein, http://cal.tongji.edu.cn/PlantLoc/
 * Viral protein 
 * Nucleus
 * Kinase

Build your own model
------------

 * training phase
 * psldoc2-train.nf -> CA_train.R
 *  input: model.fasta
 *  output: model.tfpssm, plot_model.json, accuracy+nfold.csv (CA dims)
 * predicting phase -> CA_pred.R (query.fasta, model.tfpssm, CA dims)
 *  input: query.fasta, model.tfpssm
 *  output: plot_query.json, query.pred
