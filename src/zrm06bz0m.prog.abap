***INCLUDE RM06BZ0M.

MODULE list_pbo OUTPUT.
*PERFORM BAN_DYNP_PBO(SAPFM06B).
  PERFORM ban_dynp_pbo(zmm_sapfm06b).
ENDMODULE.                    "LIST_PBO OUTPUT

*----------------------------------------------------------------------*
*  MODULE LIST_PBO_LOOP OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE list_pbo_loop OUTPUT.
*  PERFORM ban_dynp_pbo_loop(sapfm06b).
  PERFORM ban_dynp_pbo_loop(zmm_sapfm06b).
ENDMODULE.                    "LIST_PBO_LOOP OUTPUT

*----------------------------------------------------------------------*
*  MODULE LIST_PAI_LOOP1
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE list_pai_loop1.
*  PERFORM ban_dynp_pai_loop1(sapfm06b).
  PERFORM ban_dynp_pai_loop1(zmm_sapfm06b).
ENDMODULE.                    "LIST_PAI_LOOP1

*----------------------------------------------------------------------*
*  MODULE LIST_PAI_LOOP2
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE list_pai_loop2.
*  PERFORM ban_dynp_pai_loop2(sapfm06b).
  PERFORM ban_dynp_pai_loop2(zmm_sapfm06b).
ENDMODULE.                    "LIST_PAI_LOOP2

*----------------------------------------------------------------------*
*  MODULE LIST_EXIT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE list_exit.
*  PERFORM ban_dynp_list_exit(sapfm06b) USING ok-code.
  PERFORM ban_dynp_list_exit(zmm_sapfm06b) USING ok-code.
ENDMODULE.                    "LIST_EXIT

*----------------------------------------------------------------------*
*  MODULE LIST_OKCODE
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE list_okcode.
*  PERFORM ban_dynp_pai(sapfm06b) USING ok-code.
  PERFORM ban_dynp_pai(zmm_sapfm06b) USING ok-code.
ENDMODULE.                    "LIST_OKCODE
