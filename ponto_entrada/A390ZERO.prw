#include "rwmake.ch"
#define CTRF CHR(13) + CHR(10)


/*/{Protheus.doc} A390ZERO
    (Adiciona a manuten��o de lote ROTINA MATA390 a possibilidade 
    de inclus�o de novos lotes em produtos com saldo zerado)
    @type User Function (Ponto de Entrada)
    @author Houston Santos
    @since 31/07/2020
    @version 1
    @return return
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=6087915)
/*/

User Function A390ZERO()
    // Customizacoes do Cliente
    // lRet := .T. -> Permite a inclusao de lotes Zerados
    // lRet := .F. -> N�o permite a inclusao de Lotes Zerados (Padrao)Return lRet
    Local lRet := .T.

    If !fConfirm()
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} fConfirm
    (Confirma a inclus�o de novo lote com saldo zero)
    @type User Function
    @author Houston Santos
    @since 31/07/2020
    @version 1
    @param none
    @return Array
    @see (https://tdn.totvs.com/pages/viewpage.action?pageId=24347000)
/*/

Static Function fConfirm()

	Local lRet := .T.
	Local cMsgYesNo	:= ""
	Local cTitLog := ""

		cMsgYesNo := OemToAnsi(;
									"Saldo em estoque inexist�nte, lembrando que novos lotes devem ser definidos no momento da classifica��o (ENTRADA DE NF)." + CTRF +;
									"Esta a��o ir� permitir a cria��o de saldo zero no sistema, deseja realmente executa-la?" ;
								)
		cTitLog	:= OemToAnsi( "Aten��o" )	// Atencao!"
		lRet :=  MsgYesNo( OemToAnsi( cMsgYesNo ) ,  OemToAnsi( cTitLog ) ) 
	
Return(lRet)
