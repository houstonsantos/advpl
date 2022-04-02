#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "colors.ch"


/*/{Protheus.doc} ProdSEQ
	(Gera codigo do Produto automatico, concatenando o codigo do Grupo de Produto + Ponto (.) + Seguencial automatico.
	[ B1_GRUPO + Ponto + Sequencial ], sendo seu formato:
	
	GRUPO + ponto + SEGUENCIAL
		9999  +   .   + 999999

	PARAMETROS
		Recebe:
			NIHIL
  		Devolve:
			_cUP --> Numero seguencial do Produto do tipo caracter de 10 possicoes

 	PROCEDIMENTOS PARA INSTALACAO
    	1. Criar gatilhos para alimentar o campo do codigo do produto:
           	Campo........: B1_GRUPO
           	Cnt. Dominio.: B1_COD
           	Regra........: U_ProdSEQ() ou EXECBLOCK("ProdSEQ",.F.,.F.)

		2. Alterar a propriedade e a ordem dos campos abaixo;
           Campo........: B1_COD
           Propriedade..: Visualizar
           Ordem:
           	1. B1_FILIAL
           	2. B1_GRUPO
           	3. B1_COD

	    3. Aplicar no Inic. Padrao do campo [SB1->B1_COD] a Expressao: [IIF(LCOPIA,U_PRODSEQ(),SPACE(15))].)
	@type  Function
	@author TOTVS NORDESTE
	@since 04/11/2011
	@version 1.0
	@param none
	@return _cUP
	@example
	(examples)
	@see (links_or_references)
/*/

User Function ProdSEQ()

	Local cUltimo  := ""
	Local nTAM_GRU := 4
	Local nTAM_COD := 6
	Local cSepar   := "."

	// Declaracao de Variaveis
	SetPrvt("_xGrp,_xRETORNO,_nUP,_cALIAS,_nRECNO,_nORDEM,_n")

	// Retorna sem efetuar modificações caso não esteja em modo de INCLUSAO
	If !INCLUI 
		Return()
	Endif

	// Salva a area corrente
	_cALIAS := Select()
	_nORDEM := Indexord()
	_nRECNO := Recno()

	// Para atender a necessidade de gerar um codigo novo quando da acao de COPIA
	cGrupo	:= Iif(lCopia, SB1->B1_GRUPO, M->B1_GRUPO)

	// Tratamento de excessao para MOD - Mao de Obra Direta
	If Alltrim(cGrupo) != "MOD"
		// Verifica tamnaho do Campo Grupo para garantir a integridade do sistema
		If Len(AllTrim(cGrupo)) > nTAM_GRU
			MsgInfo('Esse grupo não pode montar um codigo de produto, verifique o tamanho do codigo.')
			cGrupo := " "
			Return(cGrupo)	
		Endif
		// Implemento + 1 no Codigo do Produto
		// Funcao que devolve o ultimo Codigo utilizado no Grupo 
		cUltimo	  := xGetCodGrp(cGrupo)
		_xRETORNO := Substr(AllTrim(cUltimo), nTAM_GRU + 1 + Len(cSepar), 6)		
		_xRETORNO := Iif(Empty(_xRETORNO), Strzero(0, nTAM_COD), _xRETORNO)			
		_nUP	  := Int(Val(_xRETORNO) + 1)
		_cUP	  := AllTrim(cGrupo) + cSepar + Strzero(_nUP, nTAM_COD)
	Endif
	DBSelectArea(_cALIAS)
	DBSetOrder(_nORDEM)
	Recno(_nRECNO)

Return _cUP


/*/{Protheus.doc} xGetCodGrp
	(Funcao que verifica qual ultimo comdigo utilizado para um determinado Grupo de produtos.)
	@type  Function
	@author TOTVS NORDESTE
	@since 11/11/2011
	@version 1.0
	@param pGrupo
	@return cCodPro
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function xGetCodGrp(pGrupo)

	Local aAreaAnt := GetArea()
	Local cQuery   := ""
	Local cCodPro  := ""

	cQuery += "Select *"
	cQuery += "from " + RetSQLName("SB1")
	cQuery += " where B1_FILIAL  = '"+xFilial("SB1")+"'"
	cQuery += " and D_E_L_E_T_ != '*' "
	cQuery += " and B1_GRUPO = '"+pGrupo+"'"
	cQuery += " Order by B1_COD DESC"
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery ALIAS TEMP_SB1 NEW

	DBSelectArea("TEMP_SB1")
	TEMP_SB1->(DBGotop())
	cCodPro := TEMP_SB1->B1_COD
	DBCloseArea()
	RestArea(aAreaAnt)

Return cCodPro
