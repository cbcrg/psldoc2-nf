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

 * 1.localizaiton
 * prokaryotic : PSORTb v3 data
 *  Gram-negative
 *  Gram-positve
 *  archea
 * eukaryotic
 *  plant protein, http://cal.tongji.edu.cn/PlantLoc/
 *  human
 *  animal
 *  fungi
 *  yeast
 * Viral protein 
 * 2.nuclear
 * 3.general protein function
 * Kinase

Build your own model
------------

 * training phase
 * psldoc2-train.nf -> CA_train+nFoldValidation.R
 *  input: model.fasta
 *  output: model.tfpssm, plot_model.json, accuracy-nfold.csv, predict.csv (CA dims)
 
 $nextflow psldoc2_train.nf --model=../../../data/PSL/PSORTb3.0/Archaeal.fasta --fold_num=5

 * predicting phase -> CA_pred.R (query.fasta, model.tfpssm, CA dims)
 *  input: query.fasta, model.tfpssm
 *  output: plot_query.json, query.pred
 
 $nextflow psldoc2_pred.nf --query=data/examples/small.fa --model=results/m_tfpssm_merge --CA_dim=36
