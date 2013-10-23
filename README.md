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

 1. localizaiton
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
 2. nuclear
    * uclear裡的子胞器(sub-localization)是針對細胞核這位置再繼續細分下去，也有sub-mitochondrian等子胞器的分類  
 3. protein function
    * Kinase

Build your own model
------------

 1. training phase
    * `psldoc2-train.nf` -> CA_train+nFoldValidation.R
    *  input: model.fasta
    *  output: model.tfpssm, plot_model.json, accuracy-nfold.csv, predict.csv (CA dims)

            $ nextflow psldoc2_train.nf --model=../../../data/PSL/PSORTb3.0/Archaeal.fasta --fold_num=5

 2. predicting phase 
    * `psldoc2-pred.nf` -> CA_pred.R (query.fasta, model.tfpssm, CA dims)
    *  input: query.fasta, model.tfpssm
    *  output: plot_query.json, query.pred
 
            $ nextflow psldoc2_pred.nf --query=small.fa --model=m_tfpssm_merge --CA_dim=36

