#include "protheus.ch"
 

 /*/{Protheus.doc} MATA070NH
    (Ponto de entrada MVC da rotina MATA070 [Bancos])
    @type User Function
    @author Houston Santos
    @since 08/10/2019
    @version version
    @return true
    @see (http://tdn.totvs.com/display/public/mp/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC)
/*/

User Function MATA070()

    Local aAreaSA6 := SA6->(GetArea())
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := nil
    Local cItmctbl := GetMV("MV_ITMCTBL")
 
    // Se tiver par�metros
    If (aParam <> nil)
        // Pega informa��es dos par�metros
        oObj     := aParam[1]
        cIdPonto := aParam[2]

        If (cIdPonto == 'MODELCOMMITTTS')
            // Se for inclusao ou exclusao e a MV_ITMCTBL for verdadeira, cria o item cont�bil e associa ou exclui, de acordo com a nOpc
            If ((oObj:nOperation == 3 .OR. oObj:nOperation == 5) .AND. cItmctbl == .T.)
                // Monta o c�digo do item cont�bil de acordo com a regra definida pelos analistas de TI
                cCodItmCtbl := AllTrim("B" + A6_COD) + StrZero(Val(AllTrim(A6_NUMCON)), 9)
                
                // Monta o array com as informa��es do item cont�bil que ser� inclu�do ou exclu�do
                aDadosAuto := {}
                aDadosAuto := {{'CTD_FILIAL', xFilial("CTD"), nil},; // Especifica a filial do registro
                               {'CTD_ITEM'  , cCodItmCtbl,    nil},; // Especifica qual o C�digo do item contabil
                               {'CTD_CLASSE', "2",            nil},; // Indica a classifica��o do centro de custo. 1-Receita ; 2-Despesa 	                           
                               {'CTD_DESC01', SA6->A6_NOME,   nil},; // Indica a Nomenclatura do item contabil na Moeda 1
                               {'CTD_BLOQ'  , "2",            nil},; // Indica se o Item Cont�bil est� ou n�o bloqueado para os lan�amentos cont�beis.
                               {'CTD_DTEXIS', dDataBase,      nil},; // Especifica qual a Data de In�cio de Exist�ncia para este Item Cont�bil
                               {'CTD_ITLP'  , cCodItmCtbl,    nil}}
                
                // Executa a rotina de acordo com a opera��o que est� sendo feita
                U_ExecAuto_CTBA040(aDadosAuto, oObj:nOperation)

                // Verifica se � uma opera��o de inclus�o para associal o item cont�bil criado com o banco
                If (oObj:nOperation == 3)
                    SA6->A6_XITMCTB := aDadosAuto[2][2]
                EndIf 
            EndIf
        EndIf
    EndIf

    RestArea(aAreaSA6)
    
Return xRet


 /*/{Protheus.doc} ExecAuto_CTBA040
    (Realiza o cadastro ou exclus�o do item cont�bil na CTD)
    @type  Function
    @author Houston Santos
    @since 08/10/2019
    @version version
    @param aDadosAuto, nOpc
    @return return
    @example U_ExecAuto_CTBA040(aDadosAuto, oObj:nOperation)
    @see (links_or_references)
/*/

User Function ExecAuto_CTBA040(aDadosAuto, nOpc)

    Local aAreaCTD := CTD->(GetArea())    
    Private lMsHelpAuto := .f.	
    Private lMsErroAuto := .f.	    

    // Insere o registro do Item cont�bil na CTD
    MSExecAuto({|x, y| CTBA040(x, y)}, aDadosAuto, nOpc)

    If (lMsErroAuto)
        MostraErro()
    EndIf

    RestArea(aAreaCTD)

Return .T.
