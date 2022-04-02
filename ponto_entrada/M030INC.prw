#include "protheus.ch"
#define FORM_COMMIT 0


/*/{Protheus.doc} M030INC
    (Complemento de cadastro de cliente)
    @type  Function
    @author Houston Santos
    @since 05/09/2019
    @version version
    @param none
    @return return
    @see (https://tdn.totvs.com/pages/viewpage.action?pageId=6784136)
/*/

User Function M030INC()

	Local aAreaCTD := CTD->(GetArea())
    Local cCodItmCtbl := "C"   
    Local cTipo := ""
    Local cItmctbl := GetMV("MV_ITMCTBL")

    If (cItmctbl .And. PARAMIXB == FORM_COMMIT) 

        DbSelectArea("CTD")                                	
        CTD->(DbSetOrder(1))

        // Recupera o tipo de cliente cadastrado
        cTipo := A1_PESSOA

        // Definir o código do item contábil de acordo com a empresa
        // Esta ação é necessparia devido a diferença no formato de código do cliente entre as empresas.
        cCodItmCtbl += AllTrim(If((Val(FWCodEmp()) <> 6), If((cTipo == "F"), "0" + A1_CGC, SubStr(A1_CGC, 1, 12)), A1_COD + A1_LOJA))
        
        // Insere o item ctbl na tabela CTD e associa seu código ao cliente (SA1) inserido.
        RecLock("CTD",.T.)
            CTD_FILIAL := xFilial("CTD")
            CTD_ITEM := cCodItmCtbl
            CTD_CLASSE := "2"
            CTD_DESC01 := A1_NOME
            CTD_BLOQ := "2"
            CTD_DTEXIS := dDataBase
            CTD_ITLP := cCodItmCtbl
            SA1->A1_XITMCTB := cCodItmCtbl
        CTD->(MsUnLock())
        
    EndIf

	RestArea(aAreaCTD)

Return
