class ZCL_Z_NOTIF_DPC_EXT definition
  public
  inheriting from ZCL_Z_NOTIF_DPC
  create public .

public section.
protected section.

  methods NOTIFICATIONSET_CREATE_ENTITY
    redefinition .
  methods T356_TSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_NOTIF_DPC_EXT IMPLEMENTATION.


  METHOD notificationset_create_entity.

    DATA: lv_NOTIF_TYPE         TYPE bapi2080-notif_type,
          lv_NOTIFHEADER        TYPE bapi2080_nothdri,
          ls_created_ntf_header TYPE bapi2080_nothdre,
          lt_longtext           TYPE TABLE OF bapi2080_notfulltxti,
          ls_notif              TYPE zcl_z_notif_mpc=>ts_notification_ih,
          lt_bapiret2           TYPE TABLE OF bapiret2,
          ls_t100_message       TYPE scx_t100key.

    lv_NOTIF_TYPE = 'I1'. "simple real estate message

    io_data_provider->read_entry_data(    IMPORTING    es_data = ls_notif ).

    lv_notifheader-funct_loc = ls_notif-funct_loc.
    lv_notifheader-priority = ls_notif-priokx(1). "first character = key in text

    SPLIT ls_notif-short_text AT cl_abap_char_utilities=>newline INTO
          TABLE DATA(lt_lines) .
    LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<f_line>).
      APPEND INITIAL LINE TO lt_longtext ASSIGNING FIELD-SYMBOL(<f_longtext>).
      <f_longtext>-objtype = 'QMEL' .
      <f_longtext>-objkey = '00000000' .
      <f_longtext>-FOrmat_col = 'AS' .
      <f_longtext>-text_line = <f_line>.
    ENDLOOP.

    lv_notifheader-short_text = lt_lines[ 1 ] .

    CALL FUNCTION 'BAPI_ALM_NOTIF_CREATE'
      EXPORTING
*       EXTERNAL_NUMBER    =
        notif_type         = lv_notif_type
        notifheader        = lv_notifheader
*       TASK_DETERMINATION = ' '
*       SENDER             =
*       ORDERID            =
*       IV_DONT_CHK_MANDATORY_PARTNER       =
*       NOTIFCATION_COPY   =
*       DOCUMENT_ASSIGN_COPY                = ' '
*       MAINTACTYTYPE      =
*       DATE_ADJUSTMENT    = 'O'
      IMPORTING
        notifheader_export = ls_created_ntf_header
*       MAINTACTYTYPE_EXPORT                =
      TABLES
*       NOTITEM            =
*       NOTIFCAUS          =
*       NOTIFACTV          =
*       NOTIFTASK          =
*       NOTIFPARTNR        =
        longtexts          = lt_longtext
*       KEY_RELATIONSHIPS  =
        return             = lt_bapiret2
*       EXTENSIONIN        =
*       EXTENSIONOUT       =
      .
    LOOP AT lt_bapiret2 INTO DATA(lv_bapiret2) WHERE type CA 'EA'.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      ls_t100_message-msgid = lv_bapiret2-id .
      ls_t100_message-msgno  = lv_bapiret2-number .
      ls_t100_message-attr1 = lv_bapiret2-message_v1 .
      ls_t100_message-attr2 = lv_bapiret2-message_v2.
      ls_t100_message-attr3 = lv_bapiret2-message_v3.
      ls_t100_message-attr4 = lv_bapiret2-message_v4.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_t100_message.

    ENDIF.
    CALL FUNCTION 'BAPI_ALM_NOTIF_SAVE'
      EXPORTING
        number      = ls_created_ntf_header-notif_no
      IMPORTING
        notifheader = ls_created_ntf_header
      TABLES
        return      = lt_bapiret2.
    LOOP AT lt_bapiret2 INTO lv_bapiret2 WHERE type CA 'EA'.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception .
    ENDIF.
    er_entity = ls_notif.
    er_entity-qmnum = ls_created_ntf_header-notif_no .
  ENDMETHOD.


  METHOD t356_tset_get_entityset.
    SELECT FROM t356_t
      FIELDS
      priok,
      priokx
      WHERE spras EQ @sy-langu AND
      artpr = '$1'
      ORDER BY priok
        INTO CORRESPONDING FIELDS OF TABLE @et_entityset
      .
  ENDMETHOD.
ENDCLASS.
