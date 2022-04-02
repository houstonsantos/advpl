#include "rwmake.ch"
#include "protheus.ch"


 /*/{Protheus.doc} MA080MNU
    (Ponto de entrada para cópia do TES)
    @type  User Function
    @author Houston Santos
    @since 31/03/2020
    @version version
    @return true
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6784261
/*/

User Function MA080MNU()
	
	Local aRotina := ParamIxb[1]
	AADD(aRotina, {"Copiar", "U_FCopiaSF4()", 0, 4, 15, NIL})

Return(aRotina)


// Função padrão de inclusão de dados em tela.
User Function FCopiaSF4()

	AxInclui("SF4", SF4->(Recno()), 3,, "U_IniCposSF4",,,.F.,,,,,,.T.,,,,,)

Return Nil


// Funão para carregamento dos campos em variáveis de memória.
User Function IniCposSF4()

	Local bCampo := {|nCPO|Field(nCPO)}
	Local nCountCpo := 0

	// Abre a Tabela de Cadastro de TES.
	DbSelectArea("SF4")

	// Executa o laço de todos os campos da Tabela SF4.
	For nCountCpo := 1 TO SF4->(FCount())
		If (AllTrim(FieldName(nCountCpo)) <> "F4_CODIGO")
			// Inputa o valor do campo posicionado, na variável de memória.
			M-> & (EVAL(bCampo, nCountCpo)) := FieldGet(nCountCpo)
		EndIf
	Next nCountCpo

Return Nil
