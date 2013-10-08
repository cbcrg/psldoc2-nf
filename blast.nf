params.db = "$HOME/projects/database/4blast/uniref50"
params.query = "$HOME/sample.fa"
params.output = "tfpssm.csv"
params.chunkSize = 1
params.training = "$HOME/training.fa"

DB = file(params.db)
out_file = file(params.output)

id = channel()
seq = channel()

blast_cmd="psiblast -matrix BLOSUM80 -evalue 1e-5 -gapopen 9 -gapextend 2 -threshold 999 -seg yes -soft_masking true -num_iterations 3"


def parseId(def str) { 
    str = str.readLines()[0]
	def m = (str =~ /^>(\S+)\sclass=(\S+);$/)
	if( m.matches() ) {
	  return "${m[0][1]},${m[0][2]},"
	}
	def n = (str =~ /^>(\S+)$/)
	if( n.matches() ) {
	  return "${n[0][1]},NAN,"
	}
	return "NAN,NAN,"
}


inputFile = file(params.query)
inputFile.chunkFasta( params.chunkSize ) { 
  seq << it 
  id << parseId(it)
}

task {
    input id
    input '-': seq
    output tfpssmResult

    """
    cat - | $blast_cmd -db $DB -query - -out_ascii_pssm blastResult
    pssm2tfpssm blastResult temp
    echo -ne "$id" > tfpssmResult
    cat temp >> tfpssmResult
    """
}

merge {
    input tfpssmResult
    output TFPSSM_RESULT

    """
    cat ${tfpssmResult} >> TFPSSM_RESULT
    """
}


/* 
 * training part 
 */

t_seq = channel()
t_id = channel() 

trainingFile = file(params.training)
trainingFile.chunkFasta( params.chunkSize ) {
  t_seq << it
  t_id << parseId(it)
}

task ('training') {
    input t_id
    input '-': t_seq
    output t_result

    """
    cat - | $blast_cmd -db $DB -query - -out_ascii_pssm blastResult
    pssm2tfpssm blastResult temp
    echo -ne "$t_id" > t_result
    cat temp >> t_result
    """
}

merge ('training merge')  {
    input t_result
    output t_tfpssm

    """
    cat ${t_result} >> t_tfpssm
    """
}


query_tfpssm = read(TFPSSM_RESULT)
training_tfpssm = read(t_tfpssm)


out1 = channel()
out2 = channel()
out3 = channel()

task ('prediction') {
  input training_tfpssm
  input query_tfpssm
  output 'plot_train.csv': out1
  output 'plot_test.csv': out2
  output '1NN_res.csv': out3 

  """
  export R_LIBS_USER='$PWD/r_libs'
  per_CA.R ${training_tfpssm} ${query_tfpssm}
  """
}




