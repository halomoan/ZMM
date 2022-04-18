*--------------------------------------------------------------------*
*  PPHG - Deloitte Consulting
*--------------------------------------------------------------------*
*  Program Title      : ECC - SAP Ariba Integration Cockpit Inbound
*  Program Description: Inbound integration program to download Award
*                       from Ariba by calling webservice and convert
*                       into PIR/PO/Contract
*  SAP R/3 Module     : Material Management (MM)
*  SAP Version        : ECC6
*
*--------------------------------------------------------------------*
*  Name          Date        Description                   Change ID
*--------------------------------------------------------------------*
*  Allan Taufiq  01/10/2016  Initial version               P30K908509
*--------------------------------------------------------------------*
REPORT   zmmint_0002.

INCLUDE: zmmint_0002_top,
         zmmint_0002_pbo,
         zmmint_0002_pai,
         zmmint_0002_f01.

LOAD-OF-PROGRAM.
  PERFORM f_initialize_value.
