FROM fedora:20
MAINTAINER Paolo Di Tommaso <paolo.ditommaso@gmail.com>

#
# Create the home folder 
#
RUN mkdir -p /root
ENV HOME /root

RUN yum install -q -y bc ed which wget nano unzip make gcc gcc-c++ gcc-gfortran gsl-devel

#
# BLAST
#
RUN wget -q ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.2.29+-x64-linux.tar.gz; \
    tar xf ncbi-blast-2.2.29+-x64-linux.tar.gz; \
    mv ncbi-blast-2.2.29+ /opt/; \
    rm -rf ncbi-blast-2.2.29+-x64-linux.tar.gz; \
    ln -s /opt/ncbi-blast-2.2.29+/ /opt/blast;

#
# Install R + packages
#
RUN yum install -y R-core install R-devel

RUN Rscript -e 'install.packages("car",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("ellipse",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("lattice",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("cluster",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("scatterplot3d",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("leaps",dependencies = TRUE, repos="http://cran.r-project.org")'; \
 Rscript -e 'install.packages("FactoMineR",dependencies = TRUE, repos="http://cran.r-project.org")';

#
# Custom tools 
#
ADD bin/CA_pred.R /usr/local/bin/
ADD bin/CA_train+nFoldValidation.R /usr/local/bin/
ADD bin/source /root/source
RUN cd /root/source; make; mv /root/pssm2tfpssm /usr/local/bin/

#
# Conf environment
#
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/blast/bin


