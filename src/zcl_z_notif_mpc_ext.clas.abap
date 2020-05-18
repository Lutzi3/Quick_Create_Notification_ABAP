class ZCL_Z_NOTIF_MPC_EXT definition
  public
  inheriting from ZCL_Z_NOTIF_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_Z_NOTIF_MPC_EXT IMPLEMENTATION.


  METHOD define.

    DATA : lv_namespace   TYPE string,
           lr_annotation  TYPE REF TO cl_fis_shlp_annotation,
           lr_annotation2 TYPE REF TO cl_fis_shlp_annotation.


    super->define( ) .

    model->set_soft_state_enabled( iv_soft_state_enabled = abap_true ).
    model->get_schema_namespace( IMPORTING ev_namespace = lv_namespace ).

    "Priority Search Help Annotation
    lr_annotation = cl_fis_shlp_annotation=>create(
        io_odata_model               = model
        io_vocan_model               = vocab_anno_model
        iv_namespace                 = lv_namespace
        iv_entitytype                = 'notification_ih'
        iv_property                  = 'Priokx'
     "   iv_search_help               = 'HREIC_F4_PRIO'
     "   iv_search_help_field         = 'PRIORITY'
        iv_valuelist_entityset       = 'T356_TSet'
        iv_valuelist_property        = 'Priokx' ) . "'Ktext' ).

    " lr_annotation->add_display_parameter( iv_valuelist_property  = 'Name' ) .
    " lr_annotation->add_display_parameter( iv_valuelist_property  = 'Description' ) .
    " lr_annotation->add_display_parameter( iv_valuelist_property  = 'PostCode' ) .
    " lr_annotation->add_display_parameter( iv_valuelist_property  = 'City' ) .
    DATA(lo_txt_property2) = model->get_entity_type( 'notification_ih' )->get_property( 'Priokx' ).
    lo_txt_property2->set_value_list( /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values ).

    "Functional Location Search Help Annotation
    lr_annotation2 = cl_fis_shlp_annotation=>create(
        io_odata_model               = model
        io_vocan_model               = vocab_anno_model
        iv_namespace                 = lv_namespace
        iv_entitytype                = 'notification_ih'
        iv_property                  = 'FunctLoc'
        iv_search_help               = 'IFLMT'
        iv_search_help_field         = 'TPLNR'
        iv_valuelist_entityset       = 'IflmtSet'
        iv_valuelist_property        = 'Tplnr' ).

  lr_annotation2->add_display_parameter( iv_valuelist_property  = 'Pltxt' ) .
   lr_annotation2->add_display_parameter( iv_valuelist_property  = 'Spras' ) .

  ENDMETHOD.
ENDCLASS.
