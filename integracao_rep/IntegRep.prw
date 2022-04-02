#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#define SRT_PULA Chr(13) + Chr(10)


/*/{Protheus.doc} IntegRep
    (Integração REP SIGAGPE/Atualizações/Integrações/Integração REP)
    @type  Function
    @author Houston Santos
    @since 01/10/2016
    @version 1
    @return none
    @see (links_or_references)
/*/

User Function IntegRep()
	
	Local nOpc := 0
	Local cTitulo := "Integração REP"
	Local aTexto := {}
	Local aButton := {}
	Private cDmat := "      "
	Private cAmat := "      "
		
	// Texo da tela princial.
	Aadd(aTexto, "Está rotina tem como objetivo exportar dados de funcionários, de acordo com o número de ")
	Aadd(aTexto, "matrícula informada, os dados serão salvos em um arquivo do tipo exemplo.txt, os dados  ")
	Aadd(aTexto, "presente neste arquivo podem ser importado em qualquer REP, que atenda ao layout AFD    ")
	Aadd(aTexto, "disposto no Sistema de Registro Eletrônico de Ponto - SREP - Portaria MTE 1.510/2009.   ")
			
	// Adicionando botões a tela principal.
	Aadd(aButton, {5, .T., {||DadosMat()}})
	Aadd(aButton, {1, .T., {||nOpc := 1, FechaBatch()}}) 
	Aadd(aButton, {2, .T., {||FechaBatch()}}) 
		
	// Chamando tela principal.
	FormBatch(cTitulo, aTexto, aButton)
	
	If nOpc == 1 .and. cDmat != "      "
		CreArq()
	Else
		Msginfo("Matrícula não informada.","Exportação não Realizada")
	EndIf

Return nil


/*/{Protheus.doc} DadosMat
    (Tela para informar número de matrícula)
    @type  Function
    @author Houston Santos
    @since 24/09/2016
    @version 1
    @return none
    @see (links_or_references)
/*/

Static Function DadosMat()
	
	Local nOpc := 0
	Local cTitulo := "Exportar Funcionários"
		
	// Tela onde será informado o número ou faixa de matrícula.
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 180,280 PIXEL
	@ 005,005 TO 85, 138 OF oDlg PIXEL
		
	@ 020,010 SAY "Da Matrícula?" 	SIZE 55, 07 OF oDlg PIXEL
	@ 040,010 SAY "Até Matrícula?" 	SIZE 55, 07 OF oDlg PIXEL
		
	@ 018,060 MSGET cDmat SIZE 06, 06 OF oDlg PIXEL PICTURE "@R 999999" VALID NaoVazio() .and. ValMat(cDmat)    
	@ 038,060 MSGET cAmat SIZE 06, 06 OF oDlg PIXEL PICTURE "@R 999999" VALID NaoVazio() .and. ValMat(cAmat)
		
	DEFINE SBUTTON FROM 68, 72  TYPE 1 ACTION (nOpc := 1, oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 68, 105 TYPE 2 ACTION (nOpc := 2, oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
		
Return nil


/*/{Protheus.doc} ValMat
    (Validação da matrícula informada)
    @type  Function
    @author Houston Santos
    @since 24/09/2016
    @version 1
    @param cMat
    @return lMat
    @see (links_or_references)
/*/

Static Function ValMat(cMat)
	
	Local aArea	:= GetArea()
	Local aAreaSRA := SRA->(GetArea())
	Private lMat := .T.
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	SRA->(DbGoTop())
	
		// Validando matrícula informada.
		If !SRA->(DbSeek(FWxFilial("SRA") + cMat))
			Msginfo("Informe uma matrícula válida.", "Matrícula não encontrada")
			lMat := .F.
		EndIf
	
	RestArea(aAreaSRA)
	RestArea(aArea)
	
Return(lMat)


/*/{Protheus.doc} CreArq
    (Criação do arquivo de integração)
    @type  Function
    @author Houston Santos
    @since 07/10/2016
    @version 1
    @return none
    @see (links_or_references)
/*/

Static Function CreArq()

	Private cFileOpen := cGetFile('txt|*.txt|', OemToAnsi("Selecione um diretório..."), 1, 'c:\', .F., nOR(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY), .F., .T.)
	Private cArqTxt := cFileOpen + "REP" + Dtos(Date()) + ".txt"
    Private nHdl := FCreate(cArqTxt,,,.F.)

    // Verifica se o arquivo foi criado.
    If nHdl == -1 
    	MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.", "Atenção!") 
    	Return 
    EndIf
    
    Processa({||Runcont()}, "Aguarde...") 
	    
Return nil


/*/{Protheus.doc} Runcont
    (Gerando informações e gravando em arquivo)
    @type  Function
    @author Houston Santos
    @since 01/10/2016
    @version 1
    @return none
    @see (links_or_references)
/*/

Static Function Runcont()
	
	Local aArea	:= GetArea()
	Local cQuery := ""
	Local cLin := ""
		        
	// Montando a consulta.
	cQuery := " SELECT "								   + SRT_PULA
	cQuery += "   RA_MAT, 	  "							   + SRT_PULA
	cQuery += "   RA_PIS, 	  "							   + SRT_PULA
	cQuery += "   RA_ADMISSA, "							   + SRT_PULA
	cQuery += "   RA_NOME,    "							   + SRT_PULA
	cQuery += "   RA_CODFUNC  "							   + SRT_PULA
	cQuery += " FROM  "									   + SRT_PULA
	cQuery += "   "+RetSQLName("SRA")+" SRA "			   + SRT_PULA
	cQuery += " WHERE "									   + SRT_PULA
	cQuery += "   SRA.RA_MAT BETWEEN "					   + SRT_PULA
	cQuery += "   "+cDmat+" AND "+cAmat+" AND "			   + SRT_PULA
	cQuery += "   SRA.RA_FILIAL = "+FWxFilial("SRA")+"AND" + SRT_PULA  
	cQuery += "   SRA.D_E_L_E_T_ = '' "				       + SRT_PULA
	cQuery := ChangeQuery(cQuery)
	
	// Executando consulta.
	TCQuery cQuery New Alias "SQL_SRA"
	
	DbSelectArea("SQL_SRA")
	SQL_SRA->(DbGoTop())
	
	// Numero de registros a processar.
	ProcRegua(SQL_SRA->(RecCount()))
	
	// Percorrendo os registros.
	While ! SQL_SRA->(EOF())
		
		// Incrementa a régua. 
		IncProc("Exportando Matrícula" + " " + SQL_SRA->RA_MAT)
		
		// Montando layout de integração REP
		cLin := PadL(SQL_SRA->RA_MAT,20, "0")		
		cLin +=	AllTrim(SQL_SRA->RA_PIS)	
		cLin +=	AllTrim(PadL(SubStr(SQL_SRA->RA_ADMISSA, 7, 2) + SubStr(SQL_SRA->RA_ADMISSA, 5, 2) + SubStr(SQL_SRA->RA_ADMISSA, 1, 4), 14, "0"))
		cLin +=	PadR(SQL_SRA->RA_NOME, 52, " ")		
		cLin +=	PadR(Posicione("SRJ", 1, FWxFilial("SRJ") + SQL_SRA->RA_CODFUNC, "RJ_DESC"), 30, " ") + SRT_PULA
		
		// Gravando em arquivo texto.
		If FWrite(nHdl, cLin, Len(cLin)) != Len(cLin) 
			If !MsgAlert("Ocorreu um erro na gravação do arquivo." + "Continua?", "Atenção!")
				Exit 
			EndIf 
		EndIf 
		SQL_SRA->(dbSkip())
	EndDo
	
	// Fechando arquivo.
	FClose(nHdl)
	
	SQL_SRA->(DbCloseArea())
	RestArea(aArea)
	
Return nil

