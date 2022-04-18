*--------------------------------------------------------------------*
*  PPHG - Deloitte Consulting
*--------------------------------------------------------------------*
*  Program Title      : ECC - SAP Ariba Integration Cockpit Outbound
*  Program Description: Outbound integration program to create Project,
*                       Event in Ariba by calling webservice
*  SAP R/3 Module     : Material Management (MM)
*  SAP Version        : ECC6
*
*--------------------------------------------------------------------*
*  Name          Date        Description                   Change ID
*--------------------------------------------------------------------*
*  Allan Taufiq  05/09/2016  Initial version               P30K908429
*--------------------------------------------------------------------*
PROGRAM  zmmint_0001.

INCLUDE: zmmint_0001_top,
         zmmint_0001_pbo,
         zmmint_0001_pai,
         zmmint_0001_f01.

LOAD-OF-PROGRAM.
  PERFORM f_initialize_value.
