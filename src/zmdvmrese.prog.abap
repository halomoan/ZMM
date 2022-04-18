
*----------------------------------------------------------------------*
*  Dieser Report wird automatisch bei der Pflege der Tabelle           *
*  440A anwendungsspezifisch generiert.                                *
*  Bitte keine manuellen Änderungen durchführen                        *
*                                                                      *
*   Generiert am: 19980326  Um: 192514     Durch: REINELTK             *
*----------------------------------------------------------------------*

DATA: BEGIN OF ALTRESERV    ,
        BDMNG                          LIKE
        RESB-BDMNG                                                    ,
        BDTER                          LIKE
        RESB-BDTER                                                    ,
        KZEAR                          LIKE
        RESB-KZEAR                                                    ,
        LGORT                          LIKE
        RESB-LGORT                                                    ,
        RSSTA                          LIKE
        RESB-RSSTA                                                    ,
        WERKS                          LIKE
        RESB-WERKS                                                    ,
        XLOEK                          LIKE
        RESB-XLOEK                                                    ,
      END OF ALTRESERV    .
DATA: BEGIN OF NEURESERV    ,
        BDMNG                          LIKE
        RESB-BDMNG                                                    ,
        BDTER                          LIKE
        RESB-BDTER                                                    ,
        KZEAR                          LIKE
        RESB-KZEAR                                                    ,
        LGORT                          LIKE
        RESB-LGORT                                                    ,
        RSSTA                          LIKE
        RESB-RSSTA                                                    ,
        WERKS                          LIKE
        RESB-WERKS                                                    ,
        XLOEK                          LIKE
        RESB-XLOEK                                                    ,
      END OF NEURESERV    .
