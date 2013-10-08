// #export _JAVA_OPTIONS=-Xmx1g
// #time ../../bin/nextflow scripts/blast.nf --query=samples/small.fa --output=res.tfpssm.csv

//############################
//### initialization ###
//############################
params.db = "$HOME/projects/database/4blast/uniref50"
params.query = "$HOME/sample.fa"
params.output = "tfpssm.csv"
params.chunkSize = 1
DB=params.db
TFPSSM_RESULT=params.output

id = channel()
seq = channel()

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


inputFile = new File(params.query)
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
    $pssm2tfpssm_cmd blastResult temp
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

