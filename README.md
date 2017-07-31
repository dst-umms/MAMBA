<img src="static/mamba-logo.png" width="90px" height="90px" />

# MAMBA

## MAximum-likelihood-Method Based microbial Analysis
-----------------------------------------------------

***Background:***

Using NGS Whole Genome Sequencing data to elucidate the transmission mechanism and genetic diversity of bacterial isolates has become widespread for the purposes of epidemiological research and disease control. To address the complexity involved in analysing such data, some open source tools exist whose work is published in peer reviewed journals. However, the existing tools do not provide an end-to-end solution and demands the end user to figure out many components that need to be put together in order to successfully generate the results. This, in turn, involves significant computational knowledge that many researchers may not have. To address this concern, we have developed an automated, push-button style, end-to-end pipeline called MAMBA: MAximum likelihood-Method Based microbial Analysis. The main goals we have achieved with MAMBA are,

* **Abstracting away the installation:** 
MAMBA requires just 3 commands in addition to a few core dependencies (see Prerequisites section below) to fully install all the tools and dependencies necessary to run the entire pipeline. 

* **Abstracting away the environment:** MAMBA can be installed and executed on any systems running a LINUX/UNIX OS, without administrative privileges.

* **Parallel Execution:** MAMBA is built on the back of “Snakemake” - a python framework to build Bioinformatics pipelines - which is capable of leveraging multi-core architectures, be it a local computer or high-performance-computing-cluster, to significantly speed up the processing times.

* **Publication-ready Plots:** MAMBA glues together many tools (published in peer reviewed journals) and generates a stand-alone HTML Report (comprised of embedded images) that can easily be shared over email amongst the investigators.

***

***Prerequisites:***

In order to successfully install MAMBA, the following dependencies must be satisfied. Many of these requirements are core parts of the LINUX/UNIX OS and thus may be already available in most cases. Regardless, make sure the versions are correct and, most importantly, ensure that the required library files are present on your system.

* gcc >= 4.8
* g++ >=4.8
* GNU make >= 4.0
* bzip2
* wget
* git
* miniconda3 (https://conda.io/docs/install/quick.html)


In addition, make sure the following library files are present on your system:

* libbz2.so.1.0
* libjemalloc.so.1
* libXrender.so.1

***

***Installation:***

First, let’s clone the MAMBA code repo, using

`git clone https://github.com/dst-umms/MAMBA.git`

Next, set up the “conda” virtual environments (one-time only), using

```
conda env create -f MAMBA/envs/MAMBA.env.yaml
conda env create -f MAMBA/envs/MAMBA_PY2.env.yaml
conda env create -f MAMBA/envs/MAMB_R.env.yaml
```

**GATK Software (One time set-up only):**

GATK is a dependency for MAMBA. Due to licensing issues, we could not package this tool as part of MAMBA. If you do not have the GATK executable within your system PATH variable, you will need to download the “GenomeAnalysisTK-3.7.tar.bz2” and add the path to the “config.yaml” file (see below).

***

***Execution:***

***Kicking MAMBA tires with test data:***

We have placed test data (a subset of Aanensen et. al published data) on Dropbox that can be downloaded using the link:

`http://bit.ly/2twmgsN`

Assuming you have downloaded the files into MAMBA_TEST_DATA folder, follow the instructions below.

1. You should have a directory structure similar to this at this point.

```
.
├── MAMBA
└── MAMBA_TEST_DATA
```

2. Copy, “config.yaml” and “meta.csv” from the test_data folder to the current working space. Now the directory structure looks like this,

```
├── config.yaml
├── MAMBA
├── MAMBA_TEST_DATA
└── meta.csv
```

3. Using your favorite text editor, feel free to edit “config.yaml” to change memory and cpu values to fit your system. You should also update “gatk_exec” field with the path to GATK bzipped tar ball only if you don’t have GATK already installed in your system (See “GATK Software” section above to read more on this.)

4. Now, before kicking off the pipeline, we need to activate the “MAMBA” environment using this command:

    `source activate MAMBA`

    You should see at the start of command prompt,

    `(MAMBA) >`

Finally, we are all set to launch the pipeline. The exact command depends on whether you are on a local computer or a cluster.

**Local computer:**

`snakemake -s MAMBA/MAMBA.snakefile --jobs <number_of_cpus_available> --latency-wait 60 >&MAMBA.log &`

**LSF cluster:**

```
snakemake -s MAMBA/MAMBA.snakefile --cluster “bsub -n {threads} -e logs/ -o logs/ -J MAMBA -W 360 -q <queue_name> -R \”rusage[mem={resources[mem]}]\” -R \”span[hosts=1]\” ” --jobs <number of jobs you want to run in parallel> --latency-wait 60 >&MAMBA.log &
```

**Other cluster:** 

Other clusters may require different command arguments. Look into the documentation to replace values for:

* -n number_of_threads
* -e write logs to a folder
* -o write output to a folder
* -J job_name
* -W wall_clock_time_for_a_running_job
* -q name of the queue
* -mem memory to be given in “MegaBytes”


***

***Running “MAMBA” with your data:***

1. Presuming you have downloaded MAMBA and have a folder with fastq files in the current working space, your first step is to generate the "config.yaml" and "meta.csv" files using:

```
source activate MAMBA

python MAMBA/scripts/generate_config.py --fastq_folder /path/to/dir_with_fastqs 1>config.yaml 2>meta.csv

```

**Important Note:** (Input FastQ Filename Convention)

The files ought to be named as _R1.fastq.gz (leftmate) and _R2.fastq.gz (rightmate).

2. Edit "meta.csv" with project specific meta data. (See "Kicking MAMBA tires with test data" section above and explore meta.csv for a better understanding).

3. Edit the "config.yaml" file to choose both system level params and pipeline wide params.

4. Launch the pipeline using the commands mentioned in "Kicking MAMBA tires with test data" section above.


***

***NOTE: For more information on installation and execution of MAMBA, listen to the Video below.***

<div style="text-align:center">
<a href="http://www.youtube.com/watch?feature=player_embedded&v=wmW6izBum-U" 
target="_blank"><img src="http://img.youtube.com/vi/wmW6izBum-U/0.jpg" 
alt="MAMBA" width="240" height="180" border="10" /></a>
</div>

***

***MAMBA Output:***

* MAMBA output is present in the "analysis" folder in the local workspace.


***

***Contact us:***

Should you have any questions about MAMBA or wish to report any bugs please email `vangalamaheshh@gmail.com` or open an issue on our github page.  


***


