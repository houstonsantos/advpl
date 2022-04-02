#include "protheus.ch"


/*/{Protheus.doc} SetCodBarProd
    (Função utilizada no cadastro de produto através do campo B1_XCODBAR preenche automaticamente 
    o campo do código de barras com o padrão interno baseado em  EAN8)
    @type  User Function
    @author user
    @since 28/10/2019
    @version 1.0
    @param none
    @return return
	@see (links_or_references)
/*/

User Function SetCodBarProd()

    If !Empty(M->B1_COD)
        M->B1_CODBAR := Iif(M->B1_XCODBAR == 'S', U_GetNumberCodBar(SubStr(FwCodEmp() + AllTrim(M->B1_COD), 2, 7), "EAN8"), "")
    Else
        MessageBox("Antes de definir o código de barras é necessário que o código do produto esteja preenchido.", "Atenção", 48)
    EndIf

Return .T.

/*/{Protheus.doc} GetNumberCodBar
    Função que gera o código de barras com o seu DV
    de acordo com o padrão passado por parâmetro)
    @type User Function
    @author Houston Santos
    @since 22/11/2019
    @version 1.0
    @param cCod, cType
    @return cCodBar
	@see (links_or_references)
/*/

User Function GetNumberCodBar(cCod, cType)

    Local nSoma   := 0
    Local nDv     := 0
    Local cCodBar := ""
    Local nPosition := 0
    
    If (AllTrim(Upper(cType)) == "EAN8")
        For nPosition := 1 to Len(cCod)

            Private nNumero := Val(SubStr(cCod, nPosition, 1))

            If (nPosition % 2) == 0
                nSoma += nNumero
            Else
                nSoma += nNumero * 3
            EndIf

        Next
        nDv     := 10 - (nSoma % 10)
        cCodBar := cCod + cValToChar(Iif(nDv == 10, 0, nDv))
    EndIf

Return cCodBar
