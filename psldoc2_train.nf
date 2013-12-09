blast_cmd="psiblast -matrix BLOSUM80 -evalue 1e-5 -gapopen 9 -gapextend 2 -threshold 999 -seg yes -soft_masking true -num_iterations 3"

params.db = "/db/uniprot/latest/uniref/uniref50/blast/db/uniref50.fasta"
params.model = "$PWD/examples/small.fa"
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
m_seq = channel()
m_id = channel() 

model_file = file(params.model)
model_file.chunkFasta( params.chunkSize ) {
  m_id << parseId(it)
  m_seq << it
}

task ('model blast') {
    input m_id
    input '-': m_seq
    output m_tfpssm

    """
    cat - | $blast_cmd -db $DB -query - -out_ascii_pssm blastResult
    pssm2tfpssm blastResult temp
    echo -ne "$m_id" > m_tfpssm
    cat temp >> m_tfpssm
    """
}

merge ('model merge')  {
    input m_tfpssm
    output m_tfpssm_merge

    """
    cat ${m_tfpssm} >> m_tfpssm_merge
    """
}

model_tfpssm_file = read(m_tfpssm_merge)

task ('model CA')  {
    input model_tfpssm_file
    output plot_model
    output accuracy
    output pred_res
    echo true

    """
    export R_LIBS_USER='$PWD/r_libs'
    CA_train+nFoldValidation.R ${model_tfpssm_file} ${params.fold_num}
    cat 'plot_model.json' > plot_model
    cat 'accuracy.csv' > accuracy
    cat '1NN_res.csv' > pred_res
    """
}

plot_model_file=read(plot_model)
accuracy_file=read(accuracy)
pred_file=read(pred_res)

plot_model_file.moveTo(new File(output_folder, plot_model_file.getName()))
model_tfpssm_file.moveTo(new File(output_folder, model_tfpssm_file.getName()))
accuracy_file.moveTo(new File(output_folder, accuracy_file.getName()))
pred_file.moveTo(new File(output_folder, pred_file.getName()))

