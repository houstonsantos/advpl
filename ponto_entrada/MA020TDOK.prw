#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'


/* ATEN��O: N�O COMPILAR FONTE N�O EST� SENDO UTILIZADO, FOI SUBTITUIDO */

/*/{Protheus.doc} MA020TDOK
    (Valida a cria��o do fornecedor e retorna um l�gico para confirmar ou n�o a sua cria��o)
    @type  Function
    @author Houston Santos
    @since 23/09/2020
    @version 1
    @return true
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6085756)
/*/

User Function MA020TDOK

	local aArea      
	local lRet := .T.
	aArea := GetArea()

	If Inclui
		cTipo := Upper(M->A2_TIPO)
		Reclock("SA2",.f.)
		REPLACE A2_XITMCTB WITH "F" + AllTrim(If((Val(FWCodEmp()) <> 6), If((cTipo == "F"), "0" + M->A2_CGC, SubStr(M->A2_CGC, 1, 12)), M->A2_COD + M->A2_LOJA))                                                            
		SA2->(MSUNLOCK())
	Endif
	
	Restarea(aArea)

Return lRet
