#!/usr/bin/env Rscript

#####
# require for Correspondence Analysis
#####
library("FactoMineR")

######################
# read inputs
######################
args<-commandArgs(TRUE)
train_tfpssm<-args[1]
test_tfpssm<-args[2]
CA_dim<-as.numeric(args[3])

######################
# load data
######################
data<-read.csv(train_tfpssm, header=FALSE)
if(is.na(data[1,ncol(data)]))
{
  data<-data[,-ncol(data)] #remove the last useless column, ie, proteinID,class,0.23,...,034,
}

train_ID<-data[,1]		#protein ID
train_class<-as.vector(data[,2])#protein label
train_data<-data[,c(3:length(data))]

data<-read.csv(test_tfpssm, header=FALSE)
if(is.na(data[1,ncol(data)]))
{
  data<-data[,-ncol(data)] #remove the last useless column,
}

test_ID<-data[,1]		#protein ID
test_class<-as.vector(data[,2])	#protein label
test_data<-data[,c(3:length(data))]

m<-rbind(train_data,test_data)
sup_i<-nrow(train_data)+1

######################
# Correspondence Analysis
######################
m.CA<-CA(m, ncp=CA_dim, row.sup=sup_i:nrow(m), graph=FALSE)
train_vec<-m.CA$row$coord
test_vec <-m.CA$row.sup$coord

# 1 nearest neighbor prediction
pred_c<-test_class
for(i in 1:nrow(test_vec))
{
  sim <- -Inf
  sim_index<-1
  for(j in 1:nrow(train_vec))
  {
     tmp_sim<-sqrt(sum((test_vec[i,] - train_vec[j,]) ^ 2))*(-1)
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
# output 1NN prediction
output_res<-cbind(as.vector(test_ID),as.vector(test_class),as.vector(pred_c),as.integer(pred_c==test_class))
colnames(output_res)<-c("name","family","pred_family","correct")
write.csv(output_res,file="1NN_res.csv",quote = FALSE)

# output json format for CA 2D plot
out_str<-"[\n"
# output x,y position
out_str<-paste(out_str,"data:[")
for(i in 1:nrow(test_vec))
{
	out_str<-paste(out_str, "[", test_vec[i,1], ",", test_vec[i,2], "],")
}
out_str<-paste(out_str,"]\n")
# output labels
out_str<-paste(out_str,"labels:[")
for(i in 1:nrow(test_vec))
{
	out_str<-paste(out_str, test_ID[i], ",")
}
out_str<-paste(out_str,"]\n")
# output localization site
out_str<-paste(out_str,"loc:[")
for(i in 1:nrow(test_vec))
{
	out_str<-paste(out_str, pred_c[i], ",")
}
out_str<-paste(out_str,"]\n],\n")

cat(out_str,file="plot_query.json")

