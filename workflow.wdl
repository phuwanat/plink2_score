version 1.0

workflow plink2_score {
    input {
        File vcf_file
        File weight_file
        String? out_prefix
    }

    call plink2score {
        input: vcf_file = vcf_file, weight_file = weight_file,
               out_prefix = out_prefix
    }

    output {
        
    }

     meta {
          author: "Phuwanat Sakornsakolpat"
          email: "phuwanat.sak@mahidol.edu"
     }
}

task plink2score {
    input {
        File vcf_file
        File weight_file
        String? out_prefix
        Int mem_gb = 8
    }

    Int disk_size = ceil(3*(size(vcf_file, "GB"))) + 10
    String out_string = if defined(out_prefix) then out_prefix else basename(vcf_file, ".vcf.gz")

    command {
        plink2 \
            --vcf ${vcf_file} --vcf-half-call m\
            --make-bed \
            --out ${out_string}
        plink2 --bfile ${out_string} --score ${weight_file} 1 2 3 header center
    }

    output {
        Array[File] score_out = glob("plink*")
    }

    runtime {
        docker: "pgscatalog/plink2@sha256:1a18d7252cd8602255d179ce3c7a58eecac93908fa385a70d9db4f9beacbf717"
        disks: "local-disk " + disk_size + " SSD"
        memory: mem_gb + " GB"
    }
}
