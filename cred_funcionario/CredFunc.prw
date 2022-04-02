#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#define SRT_PULA Chr(13) + Chr(10)


/*/{Protheus.doc} CredFun
	(Destinado a criar uma remessa para pagamento de funcionários, 
	Tela MarkBrowser para visualização e manipulação das demais funções do sistema.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param aRemessa
    @return lvalida
    @see (links_or_references)
/*/

User Function CredFun()

	Local nI := {}
	Local aCampo := {}
	Local aCampos := {}
	Local cAlias := "ZZC"

	Private aRotina   := {}
	Private cCadastro := "Crédito Funcionário"

	Aadd(aRotina, {"Pesquisar"    , "AxPesqui"  , 0, 1})
	Aadd(aRotina, {"Visualizar"   , "AxVisual"  , 0, 2})
	Aadd(aRotina, {"Incluir"      , "U_CredInc" , 0, 3})
	Aadd(aRotina, {"Alterar"      , "U_CredAlt" , 0, 4})
	Aadd(aRotina, {"Excluir"      , "U_CredExc" , 0, 5})
	Aadd(aRotina, {"Gerar Remessa", "U_GeraRem" , 0, 6})

	Aadd(aCampo, "ZZC_OK")
	Aadd(aCampo, "ZZC_COD")
	Aadd(aCampo, "ZZC_CPF") 
	Aadd(aCampo, "ZZC_NOME") 
	Aadd(aCampo, "ZZC_AGEN")
	Aadd(aCampo, "ZZC_CONTA")
	Aadd(aCampo, "ZZC_VALOR")

	DbSelectArea("SX3") 
	DbSetOrder(2) 

	For nI := 1 To Len(aCampo) 
		If DbSeek(aCampo[nI]) 
			Aadd(aCampos, {aCampo[nI], "", Iif(nI == 1, "", Trim(X3Titulo())), Trim(X3Picture(aCampo[nI]))}) 
		EndIf 
	Next

	DbSelectArea(cAlias)
	DbSetOrder(1)

	MarkBrow(cAlias, aCampo[1], "", aCampos, .F., "C",,,,,,)

Return nil


/*/{Protheus.doc} CredInc
    (Inclui um funcionário na tabela de créditar funcionário.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return nil
    @see (links_or_references)
/*/

User Function CredInc(cAlias, nReg, nOpc) 

	Local nOpcao := 0 
	nOpcao := AxInclui(cAlias, nReg, nOpc) 

	If nOpcao == 1 
		MsgInfo("Inclusão efetuada com sucesso!") 
	Else 
		MsgInfo("Inclusão cancelada!") 
	EndIf

Return nil


/*/{Protheus.doc} CredAlt
    (Altera os dados do funcionário da tabela créditar funcionário.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return nil
    @see (links_or_references)
/*/

User Function CredAlt(cAlias, nReg, nOpc) 

	Local nOpcao := 0 
	nOpcao := AxAltera(cAlias, nReg, nOpc) 

	If nOpcao == 1 
		MsgInfo("Alteração efetuada com sucesso!") 
	Else 
		MsgInfo("Alteração cancelada!") 
	EndIf

Return nil


/*/{Protheus.doc} CredExc
    (Deletar um funcionário da tabela créditar funcionário.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return nil
    @see (links_or_references)
/*/

User Function CredExc(cAlias, nReg, nOpc) 

	Local nOpcao := 0 
	nOpcao := AxDeleta(cAlias, nReg, nOpc) 

	If nOpcao == 1 
		MsgInfo("Exclusão efetuada com sucesso!") 
	Else 
		MsgInfo("Exclusão cancelada!") 
	EndIf

Return nil


/*/{Protheus.doc} DataRem
    (Tela para seleção da data de crédito.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return (StrTran(Dtoc(dGet), '/', ''))
    @see (links_or_references)
/*/

Static Function DataRem()

	Local oDlg
	Local cTitulo := "Remessa Bancaria"
	Local cData := SPACE(10)
	Local lHasButton := .T.
	
	Public dGet := Date()
	Public cNatureza := ""

	// Tela onde será informado a data para o crédito da remessa.
	oDlg := MSDialog():New(10,10,200,290,cTitulo,,,,,,,,,.T.)

	oTSay := tSay():New(20,10,{||'Data para crédito?'    },oDlg,,,,,,.T.,,,100,20)	
	oTGet := TGet():New(018,060,{|u|If(PCount() == 0,dGet,dGet := u)},oDlg,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dGet",,,,lHasButton)
	
	oTSay := tSay():New(40,10,{||'Natureza?'    },oDlg,,,,,,.T.,,,100,20)
	@ 038,060 MSGET cData F3 "SED" PICTURE "@!" SIZE 60, 10 OF oDlg PIXEL HASBUTTON

	oBtn1 := TBtnBmp2():New(120,150,50,50,'OK',,,,{||cNatureza := SED->ED_CODIGO, oDlg:End()},oDlg,,,.T.)
	oBtn2 := TBtnBmp2():New(120,200,50,50,'Cancel',,,,{||Alert("Operação cancelada!"), oDlg:End()},oDlg,,,.T.)

	oDlg:Activate(,,,.T.,{||},,)

Return (StrTran(Dtoc(dGet), '/', ''))


/*/{Protheus.doc} GeraRem
    (Função que gera a arquivo para remessa.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return nil
    @see (links_or_references)
/*/

User Function GeraRem()

	Local cSoma := Soma1(GetMv("MV_CREDFUN"))
	PutMv("MV_CREDFUN", cSoma)

	Private cFileOpen := cGetFile('rem|*.rem|', OemToAnsi("Selecione um diretório..."), 1,'c:\', .F., nOR(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY), .F., .T.)
	Private cArqRem := cFileOpen + "CF" + GetMv("MV_CREDFUN") + ".rem"
	Private nHdl := FCreate(cArqRem,,,.F.)

	// Verifica se o arquivo foi criado.
	If nHdl == -1 
		MsgAlert("O arquivo de nome "+cArqRem+" não pode ser executado! Verifique os parâmetros.", "Atenção!") 
		Return 
	EndIf

	Processa({||Runcont()}, "Aguarde...") 

Return nil


/*/{Protheus.doc} Runcont
    (Função principal para a criação do layout e inserção dos dados dentro do arquivo de remessa, header, dados e trailer.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param cAlias, nReg, nOpc
    @return nil
    @see (links_or_references)
/*/

Static Function Runcont()

	// Variaveis registro header do arquivo.
	Local cHeader := ""
	Local cRegHea := "0"
	Local cFitaRem := "1"
	Local cTipoArq := "REMESSA"
	Local cCodServ := "03"
	Local cTipCont := "CREDITO C/C" + Space(4)
	Local cAgencia := "01260"
	Local cRazao := "07050"
	Local cNuConta := Iif(CEMPANT == "01", "0020158", Iif(CEMPANT == "02", "0045910", "0057216"))
	Local cDigCont := Iif(CEMPANT == "01", "8", Iif(CEMPANT == "02", "0", "0"))
	Local cReserA := Space(2)
	Local cCodLib := Iif(CEMPANT == "01", "36506", Iif(CEMPANT == "02", "50816", "44879"))
	Local cNomeEmp := PadR(SubStr(SM0->M0_NOME, 1, 25 ), 25, " ")
	Local cCodBanc := "237"
	Local cNomBanc := "BRADESCO" + Space(7)
	Local cDatFita := StrZero(Day(DDATABASE), 2) + StrZero(Month(DDATABASE), 2) + StrZero(Year(DDATABASE), 4)
	Local cDenGrav := "01600"
	Local cUniDen := "BPI"
	Local cIdMoeda := Space(1)
	Local cIdSec := "N"
	Local cReserB := Space(74)
	Local cSeqReg := GetMv("MV_CREDFUN")

	// Variaveis do registro de transação.
	Local cRazaoConta := "07380"
	Local cTipoServ	:= "298" 

	Local aArea	:= GetArea()
	Local cQuery := ""
	Local cLin := ""
	Local nCount := 2
	Local nValor := 0
	Local cCodFor := ""
	
	// Array para gravar na ZCR.
	Private aRemessa := {}

	cHeader := cRegHea + cFitaRem + cTipoArq + cCodServ + cTipCont + cAgencia + cRazao + cNuConta + cDigCont + cReserA + cCodLib 
	cHeader += cNomeEmp + cCodBanc + cNomBanc + cDatFita + cDenGrav + cUniDen + DataRem() + cIdMoeda + cIdSec + cReserB + cSeqReg

	// Montando a consulta.
	cQuery := " SELECT "								     + SRT_PULA
	cQuery += "  ZZC_FILIAL, "							     + SRT_PULA
	cQuery += "  ZZC_COD, 	 "							     + SRT_PULA
	cQuery += "  ZZC_CC,     " 							     + SRT_PULA
	cQuery += "  ZZC_NOME,	 "							     + SRT_PULA
	cQuery += "  ZZC_AGEN,   "							     + SRT_PULA
	cQuery += "  ZZC_CONTA,  "							     + SRT_PULA
	cQuery += "  ZZC_VALOR   "							     + SRT_PULA
	cQuery += " FROM  "									     + SRT_PULA
	cQuery += "   "+RetSQLName("ZZC") + " ZZC"			     + SRT_PULA
	cQuery += " WHERE "								         + SRT_PULA
	cQuery += "  ZZC.ZZC_OK = 'C' AND" 			 	         + SRT_PULA
	cQuery += "  ZZC.ZZC_FILIAL = "+FWxFilial("ZZC") + "AND" + SRT_PULA  
	cQuery += "  ZZC.D_E_L_E_T_ = '' "				         + SRT_PULA
	cQuery := ChangeQuery(cQuery)

	// Executando consulta.
	TCQuery cQuery New Alias "SQL_ZZC"

	DbSelectArea("SQL_ZZC")
	SQL_ZZC->(DbGoTop())

	// Numero de registros a processar.
	ProcRegua(RecCount())

	cLin := cHeader + SRT_PULA
	// Gravando registro header em arquivo texto.
	If FWrite(nHdl, cLin, Len(cLin)) != Len(cLin) 
		MsgAlert("Ocorreu um erro na gravação do arquivo." + "Continua?", "Atenção!")
		Fclose(nHdl)
		Return
	EndIf 

	// Percorrendo os registros.
	While ! SQL_ZZC->(EOF())
		// Incrementa a régua. 
		IncProc("Gerando Remessa" + " " + SQL_ZZC->ZZC_NOME)

		// Montando layout de remmessa.
		cLin := cFitaRem + Space(61) + SQL_ZZC->ZZC_AGEN + cRazaoConta + SQL_ZZC->ZZC_CONTA + Space(2)
		cLin +=	SubStr(SQL_ZZC->ZZC_NOME, 1, 38) + SQL_ZZC->ZZC_COD + PadL(AllTrim(StrTran(Transform(SQL_ZZC->ZZC_VALOR, "@E 999999999.99"), ',', '')), 13, "0") 
		cLin +=	cTipoServ + Space(52) + StrZero(nCount, 6, 0) + SRT_PULA
		nCount += 1
		nValor += SQL_ZZC->ZZC_VALOR

		// Gravando registro de transação em arquivo texto.
		If FWrite(nHdl, cLin, Len(cLin)) != Len(cLin) 
			MsgAlert("Ocorreu um erro na gravação do arquivo." + "Continua?", "Atenção!")
			Exit 
		EndIf 
		
		// Código do fornecedor da empresa que está logada
		Do Case
			Case CEMPANT == "01"
				cCodFor := '000194'
				
			Case CEMPANT == "02" 
				cCodFor := '001313'
				
			Case CEMPANT == "03"
				cCodFor := '000018'

			Case CEMPANT == "05"
				cCodFor := "000039"

			OTHERWISE
				Alert("Empresa não encontrada!")
		EndCase
			
		// Monta Array da função CredFin.
		Aadd(aRemessa, {'GPE', cSeqReg, 'FOL', cNatureza, cCodFor, DDATABASE, dGet, SQL_ZZC->ZZC_CC, SQL_ZZC->ZZC_VALOR, SQL_ZZC->ZZC_FILIAL, SQL_ZZC->ZZC_COD})
		SQL_ZZC->(DbSkip())	
	EndDo

	cLin := "9" + PadL(AllTrim(StrTran(Transform(nValor, "@E 999999999.99"), ',', '')), 13, "0") + Space(180) + StrZero(nCount, 6, 0)
	  
	// Gravando registro trailer em arquivo texto.
	If FWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
		MsgAlert("Ocorreu um erro na gravação do arquivo." + "Continua?", "Atenção!")
		Fclose(nHdl)
		Return 
	EndIf
	
	// Fechando arquivo.
	FClose(nHdl)

	If Val(cNatureza) > 0
		If ! RemZcr(aRemessa)
			If FErase(cArqRem) == -1
				MsgStop('Falha ao apagar arquivo')
			Else
				MsgStop('Arquivo apagado com sucesso')
			EndIf
		EndIf
	Else
		If FErase(cArqRem) == -1
			MsgStop('Falha ao apagar arquivo')
		Else
			MsgStop('Arquivo apagado com sucesso')
		EndIf
	EndIf

	SQL_ZZC->(DbCloseArea())
	RestArea(aArea)

Return nil


/*/{Protheus.doc} RemZcr
    (Gravando na ZCR remessas geradas e possivelmente enviadas ao banco.)
    @type Function
    @author Houston Santos
    @since 20/06/2017
    @version 1
    @param aRemessa
    @return lValida
    @see (links_or_references)
/*/

Static Function RemZcr(aRemessa)

	Local aAreaZCR := ZCR->(GetArea())
	Local lValida  := .F.
	Local nI

	DbSelectArea("ZCR")
	ZCR->(DbSetOrder(1))

		Begin Transaction
			For nI := 1 to Len(aRemessa)
				RecLock("ZCR", .T.)
					ZCR_FILIAL := aRemessa[nI,10]
					ZCR_COD := aRemessa[nI,11]
					ZCR_CODFOR := aRemessa[nI,5]
					ZCR_CC := aRemessa[nI,8]
					ZCR_SEQREG := aRemessa[nI,2]
					ZCR_VALOR := aRemessa[nI,9]
					ZCR_DATAG := aRemessa[nI,6]
					ZCR_NATURE := aRemessa[nI,4]
				ZCR->(MsUnlock())
			Next nI
			
			//Chamando CredFin
			If U_CredFin(aRemessa)
				MsgInfo('Remessa gerada com sucesso')
				lValida := .T.
			Else
				MsgStop('Erro ao gerar remessa')
				DisarmTransaction()
			EndIf
		End Transaction
	
	RestArea(aAreaZCR)
	
Return (lValida)
