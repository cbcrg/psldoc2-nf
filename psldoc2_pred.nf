blast_cmd="psiblast -matrix BLOSUM80 -evalue 1e-5 -gapopen 9 -gapextend 2 -threshold 999 -seg yes -soft_masking true -num_iterations 3"

params.db = "/db/uniprot/latest/uniref/uniref50/blast/db/uniref50.fasta"
params.query = "${baseDir}/data/examples/small.fa"
params.model = "${baseDir}/data/examples/small.tfpssm"
params.CA_dim = 36
params.output = "results"
params.chunkSize = 1

def parseId(def str) { 
    str = str.readLines()[0]
	def m = (str =~ /^>(\S+)\s+class=(\S+);$/)
	if( m.matches() ) {
	  return "${m[0][1]},${m[0][2]},"
	}
	def n = (str =~ /^>(\S+)$/)
	if( n.matches() ) {
	  return "${n[0][1]},NAN,"
	}
	return "NAN,NAN,"
}

/* 
 * initialization
 */

DB = file(params.db)
output_folder = file(params.output)
model_file = file(params.model)
if(!output_folder.exists()) output_folder.mkdirs()
if( !model_file.exists() ) { error 1, "Specified model file does not exist: ${model_file}" }

/* 
 * query part 
 */

q_id = Channel.from()
q_seq = Channel.from()

query_file = file(params.query)
query_file.slitFasta( by:params.chunkSize ) { 
  q_id << parseId(it)
  q_seq << it 
}

process query_blast {
    input:
    val q_id
    stdin q_seq
    
    output:
    file q_tfpssm

    """
    cat - | $blast_cmd -db $DB -query - -out_ascii_pssm blastResult
    pssm2tfpssm blastResult temp
    echo -ne "$q_id" > q_tfpssm
    cat temp >> q_tfpssm
    """
}

/* 
 * prediction by Correspondance Analysis + 1NN (CA)
 */

process query_CA_1NN {
  input:
  file q_tfpssm
  
  output:
  file plot_query
  file pred_query

  """
  CA_pred.R ${model_file} ${q_tfpssm} ${params.CA_dim}
  cat 'plot_query.json'> plot_query
  cat '1NN_res.csv' > pred_query
  """
}

/* 
 * Copy to output folder 
 */
 
plot_query.collectFile(name: 'all').subscribe { it.copyTo(output_folder) }
pred_query.collectFile(name: 'all').subscribe { it.copyTo(output_folder) }


