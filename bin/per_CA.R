#!/bin/env Rscript

#####
# require for FactoMineR package
#####
library("ellipse")
library("car")
library("scatterplot3d")
library("leaps")

library("FactoMineR")

######################
# read inputs
######################
args<-commandArgs(TRUE)
train_tfpssm<-args[1]
test_tfpssm<-args[2]

print (train_tfpssm)
print (test_tfpssm)


######################
# load data
######################
data<-read.csv(train_tfpssm, header=FALSE)
if(is.na(data[1,ncol(data)]))
{
  data<-data[,-ncol(data)] #remove the last useless column, ie, proteinID,class,0.23,...,034,
}

train_ID<-data[,1]	#protein ID
train_class<-data[,2]	#protein label
train_data<-data[,c(3:length(data))]

data<-read.csv(test_tfpssm, header=FALSE)
if(is.na(data[1,ncol(data)]))
{
  data<-data[,-ncol(data)] #remove the last useless column,
}

test_ID<-data[,1]	#protein ID
test_class<-data[,2]	#protein label
test_data<-data[,c(3:length(data))]

m<-rbind(train_data,test_data)
sup_i<-nrow(train_data)+1

######################
# Correspondence Analysis
######################
m.CA<-CA(m, row.sup=sup_i:nrow(m), graph=FALSE)
train_vec<-m.CA$row$coord
test_vec <-m.CA$row.sup$coord

# 1 nearest neighbor prediction
pred_c<-test_class
for(i in 1:nrow(test_vec))
{
  print(i)
  sim <- -Inf
  sim_index<-1
  for(j in 1:nrow(train_vec))
  {
     tmp_sim<-sqrt(sum((as.matrix(test_vec[i,])[1,] - train_vec[j,]) ^ 2))*(-1)  
     if(tmp_sim > sim)
     {
	sim<-tmp_sim
	sim_index<-j
     }
   }
   pred_c[i]<-train_class[sim_index]
}

######################
# data output
######################
# output CA 2D deminsion into 2D plot
output_train<-data.frame(id = train_ID, class = train_class, x = train_vec[,1], y = train_vec[,2])
output_test<-data.frame(id = test_ID, class = test_class, x = test_vec[,1], y = test_vec[,2])

write.csv(output_train,"plot_train.csv",quote = FALSE)
write.csv(output_test,"plot_test.csv",quote = FALSE)

# output 1NN prediction
output_res<-cbind(as.vector(test_ID),as.vector(test_class),as.vector(pred_c),as.integer(pred_c==test_class))
colnames(output_res)<-c("name","family","pred_family","correct")
write.csv(output_res,file="1NN_res.csv",quote = FALSE)

