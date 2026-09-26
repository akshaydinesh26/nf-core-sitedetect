process COMBINEFASTA {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d7/d7e24dc1e4d93ca4d3a76a78d4c834a7be3985b0e1e56fddd61662e047863a8a/data' :
        'community.wave.seqera.io/library/bwa_htslib_samtools:83b50ff84ead50d0' }"

    input:
    path(fasta)
    val(primer)

    output:
    path("combined_index.fasta"), emit: index_fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    touch primer.fasta
    printf ">primer\\n${primer}\\n" > primer.fasta

    cat ${fasta} "./primer.fasta" > combined_index.fasta

    """

    stub:
    """
    touch combined_index.fasta
    """
}
