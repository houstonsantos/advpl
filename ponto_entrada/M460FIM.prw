#include "protheus.ch"
#include 'topconn.ch'
#define CTRF Chr(13) + Chr(10)


/*/{Protheus.doc} M460FIM
    (Inclusão das datas Comp Inicial(C5_XCOMIN) e Comp Final(C5_XCOMFI) 
    do pedido de venda na SE1, ponto executado na preparação do documento)
    @type  Function
    @author Houston Santos
    @since 01/07/2019
    @version version
    @return return
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6784180)
/*/

User Function M460FIM()

    Local aArea := GetArea()
    Local cNatu := SE1->E1_NATUREZ
    Local cClie := SE1->E1_NOMCLI
    Local cPref := SE1->E1_PREFIXO
    Local cNume := SE1->E1_NUM
    Local cTipo := SE1->E1_TIPO
    Local cQuery := ""
    Local cCompcon := GetMV("MV_COMPCON")

    If (cCompcon)
        cQuery := " SELECT "                 			 + CTRF
	    cQuery += "  E1_FILIAL,  "						 + CTRF
	    cQuery += "  E1_NATUREZ, "						 + CTRF
	    cQuery += "  E1_NOMCLI,  " 						 + CTRF
	    cQuery += "  E1_PREFIXO, "						 + CTRF
	    cQuery += "  E1_NUM,     "						 + CTRF
	    cQuery += "  E1_TIPO,    "						 + CTRF
        cQuery += "  R_E_C_N_O_  "						 + CTRF
	    cQuery += " FROM  "	+ RetSQLName("SE1") + " SE1" + CTRF
	    cQuery += " WHERE "								            + CTRF
	    cQuery += "  SE1.E1_FILIAL = "  + FWxFilial("SE1") + " AND" + CTRF
        cQuery += "  SE1.E1_NATUREZ = '" + cNatu + "' AND"		    + CTRF
        cQuery += "  SE1.E1_NOMCLI = '"  + cClie + "' AND"          + CTRF
        cQuery += "  SE1.E1_PREFIXO = '" + cPref + "' AND"		    + CTRF
        cQuery += "  SE1.E1_NUM = '"     + cNume + "' AND"		    + CTRF
        cQuery += "  SE1.E1_TIPO = '"    + cTipo + "' AND"          + CTRF
	    cQuery += "  SE1.D_E_L_E_T_ = '' "				            + CTRF
        cQuery := ChangeQuery(cQuery)

        // Executando consulta.
	    TCQuery cQuery New Alias "SQL_SE1"

	    DbSelectArea("SQL_SE1")
	    SQL_SE1->(DbGoTop())

        // Percorrendo os registros.
	    While ! SQL_SE1->(EOF())
            DbSelectArea("SE1")
            DbGoto(SQL_SE1->R_E_C_N_O_)
            RecLock("SE1", .F.)
	    	    E1_XCOMIN := SC5->C5_XCOMIN
	    	    E1_XCOMFI := SC5->C5_XCOMFI
            SE1->(MsUnlock())
            SE1->(DbCloseArea())
	    	SQL_SE1-> (dbSkip())		
	    EndDo
        SQL_SE1->(DbCloseArea())
    EndIf
    
    RestArea(aArea)

Return
