process FLANKDETECT {
    tag "$meta.id"
    label 'process_single'


    container "${ 'sitedetect/japsa:1.9' }"

    input:
    tuple val(meta), path(bam)
    path(fasta)

    output:
    tuple val(meta), path("*_reformed.txt"), emit: clustered_sites
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    jsa.np.flankDetect \
        --flankFile \
        --bamFile \
        --refFile \
        ${args} \
        > '${prefix}_integration_site_clustering.txt'
    
    awk 'BEGIN{FS=OFS="\\t"}\$6!="NA"{if (NR!=1) print \$2,\$3,\$4,\$5,\$1,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13}' \
        '${prefix}_integration_site_clustering.txt' > '${prefix}_integration_site_reformed.txt' 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jsa: \$(jsa | sed -n 's/^Version \([^,]*\).*/\1/p' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch '${prefix}_integration_site_reformed.txt'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jsa: \$(jsa | sed -n 's/^Version \([^,]*\).*/\1/p' )
    END_VERSIONS
    """
}
