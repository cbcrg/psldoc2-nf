#include <string>
#include <fstream>
#include <iostream>
#include <iomanip>

#include "term.h"
#include "pssm.h"

bool fexists(string filename)
{
  ifstream ifile(filename.c_str());
  return ifile;
}

int main(int argc, char *argv[])
{
	const int gappedDipeptides_dis=13;
	int i;
	float termWei, weiSum=0;
	string pssm_f  = argv[1]; //input
	string tfpssm_f = argv[2]; //output
	Term term(gappedDipeptides_dis);

	if(!fexists(tfpssm_f.c_str()))
	{
		cout << "process  = " << pssm_f << endl;
		cout << "generate = " << tfpssm_f << endl;
		float *saveVector = new float [(int)term.size()];
		
		PSSM pssm(pssm_f.c_str());
		//pssm.normal_smooth();
		//pssm.window_smooth();
		
		for(i = 0; i < (int)term.size(); i++)
		{
			termWei = pssm.gap_dip_fre(term.get_term(i));
			saveVector[i] = termWei;
			weiSum += termWei;
		}	
		//Normalization
		for(i = 0; i < (int)term.size(); i++)
				saveVector[i] = saveVector[i]/weiSum;
//output TFPSSM to csv file
		fstream csvFile;
		csvFile.open(tfpssm_f.c_str(), ios::out);
		if(!csvFile)
		{
			perror(tfpssm_f.c_str());
			return 0;
		}
		for(i = 0; i < (int)term.size(); i++)
			csvFile << saveVector[i] << ",";
		csvFile << endl;
		csvFile.close();

		delete [] saveVector;
	}
	else if(fexists(tfpssm_f))
		cout << "tfpssm_file exist: " << tfpssm_f << endl;	
}
