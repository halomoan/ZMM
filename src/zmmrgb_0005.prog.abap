REPORT  zmmrgb_0005.
*---------------------------------------------------------------------*
* Program    : ZMMRGB_0006
* FRICE#     : MMGBE_016
* Title      : PO Approval Report
* Author     : Venkatesh Gopalarathnam
* Date       : 28.12.2010
* Specification Given By:
* Purpose	   : To generate display POs for approval and enable user to
*              approve POs relevant to the user.
*---------------------------------------------------------------------*
* Modification Log
* Date         Author          Num  Transport Req no. Description
* -----------  -------         ---  ---------------------------------*
* 28.12.2010   VEGOPALARATH    001                Initial creation
* 10.01.2011   VEGOPALARATH    002  P30K901533    Deletion indicator issue
*                                                 Alloy tkt no - T000409
* 16.05.2011   MMIRASOL        003  P30K903020    1. Added 'Details Button
*                                                    to Header Screen
*                                                 2. Adjusted computation of
*                                                    PO Value based on
*                                                    "returned item" status
*                                                 3. Added a "PO Items
*                                                    Details" Screen
*                                                 4. Added a "RFQ Details"
*                                                    Screen
*                                                 5. Added a "Available
*                                                    Source Contracts
*                                                    Screen"
*                                                 6. Added a "Available
*                                                    Source Info Records/
*                                                    Purchase Org/Plant"
*                                                    Screen
*---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* I N C L U D E S
*----------------------------------------------------------------------*
INCLUDE zmmrgb_0005_top. " Data declarations

INCLUDE zmmrgb_0005_fetch_sub. " Subroutines

*----------------------------------------------------------------------*
* START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

*Fetch Purchase Orders from EKKO
  PERFORM fetch_pord.

*Fetch EKPO data
  PERFORM fetch_ekpo_data.

* Begin of P30K903020
*          Fetch Account Assignments
  PERFORM: fetch_acc,

*          Fetch Valid Purchase Orgs for Plant
           fetch_t024w,

*          Fetch RFQ records
           fetch_rfq,

*          Fetch Available Source Contracts
           fetch_asc,

*          Fetch Available Source Info Records/Plants
           fetch_asi_conn, "Non Consignment
           fetch_asi_cony, "Consignment

*          Fetch Order Price History
           fetch_eipa,

*          Fetch Contract Items
           fetch_a016,

*          Fetch MIR (Plant Specific)
           fetch_a017,

*          Fetch MIR
           fetch_a018.
* End   of P30K903020

*Fetch Release Codes
  PERFORM fetch_relcodes.

*Fetch Vendor names
  PERFORM vendor_names.

*Rearrange data
  PERFORM rearrange_data.

END-OF-SELECTION.
*----------------------------------------------------------------------*
* END OF SELECTION
*----------------------------------------------------------------------*

* Begin of P30K903020
  PERFORM: field_catalog,
           set_variants.
* End   of P30K903020

  IF it_final IS NOT INITIAL.
*Display report
    PERFORM alv_display.
  ELSE.
    MESSAGE text-002 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.
