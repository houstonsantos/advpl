#include "protheus.ch"


/*/{Protheus.doc} M020INC
    (Complemento de cadastro de fornecedor)
    @type  Function
    @author Houston Santos
    @since 05/09/2019
    @version version
    @return return
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=6087546)
/*/

User Function M020INC()

	// Recuperar área
	Local aAreaCTD := CTD->(GetArea())
	Local cCodItmCtbl := "F"
	Local cTipo := ""
	Local cItmctbl := GetMV("MV_ITMCTBL")

	If (cItmctbl .And. AllTrim(SA2->A2_CGC) == AllTrim(A2_CGC))

		DbSelectArea("CTD")
		CTD->(DbSetOrder(1))

		cTipo := A2_TIPO

		// Definir o código do item contábil de acordo com a empresa
		// Esta ação é necessparia devido a diferença no formato de código do fornecedor entre as empresas.
		cCodItmCtbl += AllTrim(If((Val(FWCodEmp()) <> 6), If((cTipo == "F"), "0" + A2_CGC, SubStr(A2_CGC, 1, 12)), A2_COD + A2_LOJA))

		RecLock("CTD",.T.)
			CTD_FILIAL := xFilial("CTD") 
			CTD_ITEM := cCodItmCtbl
			CTD_CLASSE := "2"          
			CTD_DESC01 := A2_NOME
			CTD_BLOQ := "2"    
			CTD_DTEXIS := dDataBase
			CTD_ITLP := cCodItmCtbl
			SA2->A2_XITMCTB := cCodItmCtbl
		CTD->(MsUnLock())

	EndIf
		
	RestArea(aAreaCTD)

Return(.T.)   
