blast_cmd="psiblast -matrix BLOSUM80 -evalue 1e-5 -gapopen 9 -gapextend 2 -threshold 999 -seg yes -soft_masking true -num_iterations 3"

params.db = "/db/uniprot/latest/uniref/uniref50/blast/db/uniref50.fasta"
params.model = "${baseDir}/data/examples/small.fa"
params.output = "results"
params.fold_num = 5
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
if(!output_folder.exists()) output_folder.mkdirs()

/* 
 * model part 
 */
m_seq = Channel.create()
m_id = Channel.create()

model_file = file(params.model)
model_file.splitFasta( by:params.chunkSize ) {
  m_id << parseId(it)
  m_seq << it
}

process model_blast {
    input:
    val m_id
    stdin m_seq
    output:
    file 'm_tfpssm' into m_tfpssm

    """
    cat - | $blast_cmd -db $DB -query - -out_ascii_pssm blastResult
    pssm2tfpssm blastResult temp
    echo -ne "$m_id" > m_tfpssm
    cat temp >> m_tfpssm
    """
}

(m_tfpssm_merge, m_tfpssm_merge_2) = m_tfpssm.collectFile(name: 'all')

process model_CA  {
	echo true
	    
    input:
    file model_tfpssm_file from m_tfpssm_merge
    
    output:
    file plot_model
    file accuracy
    file pred_res

    """
    export R_LIBS_USER='$PWD/r_libs'
    CA_train+nFoldValidation.R ${model_tfpssm_file} ${params.fold_num}
    cat 'plot_model.json' > plot_model
    cat 'accuracy.csv' > accuracy
    cat '1NN_res.csv' > pred_res
    """
}

plot_model.subscribe { it.copyTo(output_folder)  }
accuracy.subscribe { it.copyTo(output_folder) }
pred_res.subscribe { it.copyTo(output_folder) }
m_tfpssm_merge_2.subscribe { it.copyTo(output_folder) }

