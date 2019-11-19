//
// Version:
// Test:
// Command: 
// 
//
/*
 * Remote run test
 * Source:
 * 
 * Steps considered: 

 */ 
import static groovy.json.JsonOutput.*

nextflow.preview.dsl=2

// print all parameters:
// println(prettyPrint(toJson( params )))


//////////////////////////////////////////////////////
//  Import sub-workflows from the modules:

include star as STAR from '../workflows/star.nf' params(params)
include QC_FILTER from '../src/scanpy/workflows/qc_filter.nf' params(params)
include SC__FILE_CONCATENATOR from '../src/utils/processes/utils.nf' params(params.sc.file_concatenator + params.global + params)
include NORMALIZE_TRANSFORM from '../src/scanpy/workflows/normalize_transform.nf' params(params + params.global)
include HVG_SELECTION from '../src/scanpy/workflows/hvg_selection.nf' params(params + params.global)
include DIM_REDUCTION from '../src/scanpy/workflows/dim_reduction.nf' params(params + params.global)
include CLUSTER_IDENTIFICATION from '../src/scanpy/workflows/cluster_identification.nf' params(params + params.global)
include SC__H5AD_TO_LOOM from '../src/utils/processes/h5adToLoom.nf' params(params + params.global)
include SC__PUBLISH_H5AD from '../src/utils/processes/utils.nf' params(params + params.global)

// data channel to start from 10x data:
include getChannel as getTenXChannel from '../src/channels/tenx.nf' params(params)


workflow single_sample_star {
    
    data = STAR()
    QC_FILTER( data )
    NORMALIZE_TRANSFORM( QC_FILTER.out.filtered )
    HVG_SELECTION( NORMALIZE_TRANSFORM.out )
    DIM_REDUCTION( HVG_SELECTION.out.scaled )
    CLUSTER_IDENTIFICATION( DIM_REDUCTION.out.dimred )
    SC__PUBLISH_H5AD( CLUSTER_IDENTIFICATION.out.marker_genes,
        params.global.project_name+".single_sample.output")
    filteredloom = SC__H5AD_TO_LOOM( CLUSTER_IDENTIFICATION.out.marker_genes )
    
}

