#include "rwmake.ch"
#define CTRF CHR(13) + CHR(10)


/*/{Protheus.doc} A390ZERO
    (Adiciona a manutenção de lote ROTINA MATA390 a possibilidade 
    de inclusão de novos lotes em produtos com saldo zerado)
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
    // lRet := .F. -> Não permite a inclusao de Lotes Zerados (Padrao)Return lRet
    Local lRet := .T.

    If !fConfirm()
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} fConfirm
    (Confirma a inclusão de novo lote com saldo zero)
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
									"Saldo em estoque inexistênte, lembrando que novos lotes devem ser definidos no momento da classificação (ENTRADA DE NF)." + CTRF +;
									"Esta ação irá permitir a criação de saldo zero no sistema, deseja realmente executa-la?" ;
								)
		cTitLog	:= OemToAnsi( "Atenção" )	// Atencao!"
		lRet :=  MsgYesNo( OemToAnsi( cMsgYesNo ) ,  OemToAnsi( cTitLog ) ) 
	
Return(lRet)
