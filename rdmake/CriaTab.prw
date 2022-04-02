#include "protheus.ch"


// Constantes usadas na cria��o dos campos
Static _X3_USADO := "���������������"
Static _X3_USFILIAL := "���������������"
Static _X3_RESERV := "�A"
Static _X3_OBRIGA := "�"
Static _X3_NAO_OBRIGA := ""

/*/{Protheus.doc} zCriaTab
	Fun��o para cria��o das tabelas na SX2|SX3|SIX|SXA
	@author Houston Santos
	@since 15/10/2019
	@version 1.0

		@param aSX2, Array, Dados das Tabelas
		@param aSX3, Array, Dados dos Campos
		@param aSX3, Array, Dados das Pastas
		@param aSIX, Array, Dados dos �ndices
		@example

		u_CriaTab()
		@obs Abaixo a estrutura dos arrays passados por parametros:

		FIELDS:=> MATRIZ (Estrutura que ir� criar a tabela com os campos no banco TOPCONN)
			[1] - Campo
			[2] - Tipo
			[3] - Tamanho
			[4] - Decimal

		SX2:=> ARRAY (Estrutura que ir� criar o registro na SX2 [TABELAS])
			[01] - Chave
			[02] - Descri��o
			[03] - Modo
			[04] - Modo Un.
			[05] - Modo Emp.

		SX3:=> MATRIZ (Estrutura que ir� criar o registro na SX3 [CAMPOS])
			[nLinha][01] - Campo
			[nLinha][02] - Filial?
			[nLinha][03] - Tamanho
			[nLinha][04] - Decimais
			[nLinha][05] - Tipo
			[nLinha][06] - T�tulo
			[nLinha][07] - Descri��o
			[nLinha][08] - M�scara
			[nLinha][09] - N�vel
			[nLinha][10] - Vld.User
			[nLinha][11] - Usado?
			[nLinha][12] - Ini.Padr.
			[nLinha][13] - Cons.F3
			[nLinha][14] - Visual
			[nLinha][15] - Contexto
			[nLinha][16] - Browse
			[nLinha][17] - Obrigat�rio?
			[nLinha][18] - Lista Op��es
			[nLinha][19] - Modo de Edi��o
			[nLinha][20] - Ini Browse
			[nLinha][21] - Pasta

		SIX:=> MATRIZ (Estrutura que ir� criar o registro na SIX [�NDICES])
			[nLinha][01] - �ndice
			[nLinha][02] - Ordem
			[nLinha][03] - Chave
			[nLinha][04] - Descri��o
			[nLinha][05] - Propriedade
			[nLinha][06] - NickName
			[nLinha][07] - Mostr.Pesq	

		SXA:=> MATRIZ (Estrutura que ir� criar o registro na SXA [PASTAS])
			[nLinha][01] - Alias
			[nLinha][02] - Ordem
			[nLinha][03] - Descri��o
			[nLinha][04] - Propriedade
			[nLinha][05] - Agrupamento
			[nLinha][06] - Tipo
/*/

User Function zCriaTab(aFields, aSX2, aSX3, aSIX, aSXA)

	// Recuperar a �rea das tabelas utilizadas e inicializa��o das vari�veis
	Local aArea := GetArea()
	Local aAreaX2 := SX2->(GetArea())
	Local aAreaX3 := SX3->(GetArea())
	Local aAreaIX := SIX->(GetArea())
	Local aAreaXA := SXA->(GetArea())
	Local cTabAux := aSX2[1]
	Local lTabCriada := .F.
	Local lTemAltera := .F.
	Local cMsgAux := ""
	Local nAtual := 0
	Local cOrdemAux := ""
	
	// Setando a ordem no primeiro registro
	SX2->(dbSetOrder(1)) 
	SX3->(dbSetOrder(2)) 
	SIX->(dbSetOrder(1))
	SXA->(dbSetOrder(1))
	
	// Se n�o conseguir posicionar na tabela, ir� cri�-la
	SX2->(DbSetOrder(1))
	If ! SX2->(DbSeek(cTabAux))
		RecLock("SX2", .T.)
			SX2->X2_CHAVE := cTabAux
			SX2->X2_PATH := "\data\"
			SX2->X2_ARQUIVO	:= cTabAux + FWCodEmp() + "0"
			SX2->X2_NOME := aSX2[2]
			SX2->X2_NOMESPA	:= aSX2[2]
			SX2->X2_NOMEENG	:= aSX2[2]
			SX2->X2_ROTINA := ""
			SX2->X2_MODO := aSX2[3]
			SX2->X2_MODOUN := aSX2[4]    
			SX2->X2_MODOEMP	:= aSX2[5]
			SX2->X2_DELET := 0
			SX2->X2_TTS	:= ""
			SX2->X2_UNICO := ""
			SX2->X2_PYME := ""
			SX2->X2_MODULO := 0
		SX2->(MsUnlock())

		If ! MsFile('\DATA\' + cTabAux + FWCodEmp() + '0')
			DbCreate(cTabAux + FWCodEmp() + '0', aFields, "TOPCONN")
		EndIf
	
		lTabCriada := .T.
	Else
		lTabCriada := .T.
	EndIf
	
	// Cria��o da pasta na SXA - Se n�o conseguir posicionar na tabela, ir� cri�-la
	If (Len(aSXA) > 0 .And. lTabCriada)
		For nAtual := 1 To Len(aSXA)
			SXA->(DbSetOrder(1))
			If ! SXA->(DbSeek(cTabAux))
				RecLock("SXA", .T.)
					SXA->XA_ALIAS := aSXA[nAtual][1]
					SXA->XA_ORDEM := aSXA[nAtual][2]
					SXA->XA_DESCRIC	:= aSXA[nAtual][3]
					SXA->XA_DESCSPA	:= aSXA[nAtual][3]
					SXA->XA_DESCENG	:= aSXA[nAtual][3]
					SXA->XA_PROPRI := aSXA[nAtual][4]
					SXA->XA_AGRUP := aSXA[nAtual][5]
					SXA->XA_TIPO := aSXA[nAtual][6]
				SX2->(MsUnlock())
			EndIf
		Next
	EndIf

	// Se a tabela tiver sido criada
	If (lTabCriada)
		// Percorrendo os campos
		For nAtual := 1 To Len(aSX3)
			If ! SX3->(DbSeek(aSX3[nAtual][01]))
				fProxSX3(cTabAux, @cOrdemAux)			
				// Se for campo de filial, trata de forma diferente
				If ! Empty(aSX3[nAtual][02])
					RecLock("SX3", .T.)
						SX3->X3_ARQUIVO	:= cTabAux
						SX3->X3_ORDEM := cOrdemAux
						SX3->X3_CAMPO := aSX3[nAtual][01]
						SX3->X3_TIPO := aSX3[nAtual][05]
						SX3->X3_TAMANHO	:= Val(aSX3[nAtual][03])
						SX3->X3_DECIMAL	:= Val(aSX3[nAtual][04])
						SX3->X3_TITULO := aSX3[nAtual][06]
						SX3->X3_TITSPA := aSX3[nAtual][06]
						SX3->X3_TITENG := aSX3[nAtual][06]
						SX3->X3_DESCRIC	:= aSX3[nAtual][07]
						SX3->X3_DESCSPA	:= aSX3[nAtual][07]
						SX3->X3_DESCENG	:= aSX3[nAtual][07]
						SX3->X3_PICTURE	:= aSX3[nAtual][08]
						SX3->X3_USADO := _X3_USFILIAL
						SX3->X3_RESERV := "��"
						SX3->X3_GRPSXG := "033"
						SX3->X3_PYME := "S"
						SX3->X3_IDXSRV := "N"
						SX3->X3_ORTOGRA	:= "N"
						SX3->X3_IDXFLD := "N"
						SX3->X3_BROWSE := "N"
						SX3->X3_NIVEL := Val(aSX3[nAtual][09])
					SX3->(MsUnlock())	
				// Sen�o cria o campo
				Else
					RecLock("SX3", .T.)
						SX3->X3_ARQUIVO	:= cTabAux
						SX3->X3_ORDEM := cOrdemAux
						SX3->X3_CAMPO := aSX3[nAtual][01]
						SX3->X3_TIPO := aSX3[nAtual][05]
						SX3->X3_TAMANHO	:= Val(aSX3[nAtual][03])
						SX3->X3_DECIMAL	:= Val(aSX3[nAtual][04])
						SX3->X3_TITULO := aSX3[nAtual][06]
						SX3->X3_TITSPA := aSX3[nAtual][06]
						SX3->X3_TITENG := aSX3[nAtual][06]
						SX3->X3_DESCRIC	:= aSX3[nAtual][07]
						SX3->X3_DESCSPA	:= aSX3[nAtual][07]
						SX3->X3_DESCENG	:= aSX3[nAtual][07]
						SX3->X3_PICTURE	:= aSX3[nAtual][08]
						SX3->X3_VLDUSER	:= aSX3[nAtual][10]
						SX3->X3_VALID := ""
						SX3->X3_USADO := Iif(Empty(aSX3[nAtual][11]), _X3_USADO, _X3_USFILIAL)
						SX3->X3_RELACAO	:= aSX3[nAtual][12]
						SX3->X3_F3 := aSX3[nAtual][13]
						SX3->X3_NIVEL := Val(aSX3[nAtual][09])
						SX3->X3_RESERV := Iif(aSX3[nAtual][05] == "M", "��", _X3_RESERV)
						SX3->X3_CHECK := ""
						SX3->X3_TRIGGER	:= ""
						SX3->X3_PROPRI := "U"
						SX3->X3_VISUAL := aSX3[nAtual][14]
						SX3->X3_CONTEXT	:= aSX3[nAtual][15]
						SX3->X3_BROWSE := aSX3[nAtual][16]
						SX3->X3_OBRIGAT	:= Iif(!Empty(aSX3[nAtual][17]), _X3_OBRIGA, _X3_NAO_OBRIGA)
						SX3->X3_CBOX := aSX3[nAtual][18]
						SX3->X3_CBOXSPA	:= aSX3[nAtual][18]
						SX3->X3_CBOXENG	:= aSX3[nAtual][18]
						SX3->X3_PICTVAR	:= ""
						SX3->X3_WHEN := aSX3[nAtual][19]
						SX3->X3_INIBRW := aSX3[nAtual][20]
						SX3->X3_GRPSXG := ""
						SX3->X3_FOLDER := aSX3[nAtual][21]
						SX3->X3_PYME := "S"
						SX3->X3_CONDSQL	:= ""
						SX3->X3_IDXSRV := "N"
						SX3->X3_ORTOGRA	:= "N"
						SX3->X3_IDXFLD := "N"   
						SX3->X3_TELA := ""
					SX3->(msUnlock())  
				EndIf
				lTemAltera := .T.
			EndIf
		Next
		
		// Percorrendo os �ndices
		For nAtual := 1 To Len(aSIX)
			// Se n�o conseguir posicionar, quer dizer que n�o existe o �ndice, logo ser� criado
			If ! SIX->(DbSeek(aSIX[nAtual][1] + aSIX[nAtual][2]))
				RecLock("SIX", .T.)
					SIX->INDICE	:= aSIX[nAtual][1]
					SIX->ORDEM := aSIX[nAtual][2]
					SIX->CHAVE := aSIX[nAtual][3]
					SIX->DESCRICAO := aSIX[nAtual][4]
					SIX->DESCSPA := aSIX[nAtual][4]
					SIX->DESCENG := aSIX[nAtual][4]
					SIX->PROPRI	:= aSIX[nAtual][5]
					SIX->F3 := ""
					SIX->NICKNAME := aSIX[nAtual][6]
					SIX->SHOWPESQ := aSIX[nAtual][7]
				SIX->(MsUnlock())
				lTemAltera := .T.
			EndIf
		Next
		
		// Se tiver altera��es em campo e/ou �ndices
		If (lTemAltera)
			// Bloqueia altera��es no Dicion�rio
			__SetX31Mode(.F.)
			
			// Se a tabela tiver aberta nessa se��o, fecha
			If Select(cTabAux) > 0
				(cTabAux)->(DbCloseArea())
			EndIf
		
			// Atualiza o Dicion�rio
			X31UpdTable(cTabAux)
			
			// Se houve Erro na Rotina
			If (__GetX31Error())
				cMsgAux := "Houveram erros na atualiza��o da tabela "+cTabAux+":"+Chr(13)+Chr(10)
				cMsgAux += __GetX31Trace()
				Aviso('Aten��o', cMsgAux, {'OK'}, 03)
			EndIf                                                         

			// Abrindo a tabela para criar dados no sql
			DbSelectArea(cTabAux)
			
			// Desbloqueando altera��es no dicion�rio
			__SetX31Mode(.T.)
		EndIf
	EndIf
	
	RestArea(aAreaIX) 
	RestArea(aAreaX3) 
	RestArea(aAreaX2) 
	RestArea(aAreaXA) 
	RestArea(aArea) 

Return


/*/{Protheus.doc} Static Function fProxSX3
	Fun��o que pega a pr�xima sequencia da SX3  
	@author Houston Santos
	@since 15/10/2019
	@version 1.0
	@param cTabela, Caracter, Tabela buscada
	@param cOrdem, Caracter, Ordem
	@return valor de retorno � pasado para cOrdem
	@example
	u_zExistSIX('SB1', 'CAMPO', @cOrdem)
	@see (links_or_references)
/*/

Static Function fProxSX3(cTabela, cOrdem)
	Local aArea := GetArea()
	Local aAreaX3 := SX3->(GetArea())
	Default cOrdem := ""
	
	// Se n�o vir ordem, ir� percorrer a SX3 para encontrar a ordem atual
	If Empty(cOrdem)
		SX3->(DBSetOrder(1)) //TABELA
		// Se conseguir posicionar na tabela
		If SX3->(DBSeek(cTabela))
			// Enquanto houver registros e for a mesma tabela
			While ! SX3->(EoF()) .And. SX3->X3_ARQUIVO == cTabela
				cOrdem := SX3->X3_ORDEM
				SX3->(DBSkip())
			EndDo
		Else
			cOrdem := "00"
		EndIf
		cOrdem := Soma1(cOrdem)
	// Sen�o, ir� somar 1, pois a tabela n�o tem nenhuma ordem
	Else
		cOrdem := Soma1(cOrdem)
	EndIf
	
	RestArea(aAreaX3)
	RestArea(aArea)

Return


/*/{Protheus.doc} Static Function zExistSIX
	Fun��o que verifica se o indice j� existe, setando a �ltima sequencia dispon�vel
	@author Houston Santos
	@since 15/10/2019
	@version 1.0
	@param cTabela, Caracter, Tabela buscada
	@param cNickName, Caracter, NickName do �ndice buscado
	@param cSequen, Caracter, �ltima sequencia dispon�vel dos �ndices
	@return lExist, Retorna se o �ndice j� existe ou n�o
	@example
	u_zExistSIX('SB1', 'CAMPO', @cOrdem)
	@see (links_or_references)
/*/

Static Function zExistSIX(cTabela, cNickName, cSequen)

	Local aAreaSIX := SIX->(GetArea())
	Local lExist := .F.
	Local cSequen := "1"
	
	SIX->(DbSetOrder(1))
	SIX->(DbGoTop())
	
	// Se conseguir posicionar na tabela
	If SIX->(DbSeek(cTabela))
		// Enquanto n�o for fim da tabela e for o mesmo �ndice
		While ! SIX->(EoF()) .And. SIX->INDICE == cTabela
			// Se tiver o mesmo apelido, j� existe o �ndice
			If Alltrim(SIX->NICKNAME) == Alltrim(cNickName)
				lExist := .T.
			EndIf
			cSequen := SIX->ORDEM
			SIX->(DbSkip())
		EndDo
		cSequen := Soma1(cSequen)
	EndIf

	RestArea(aAreaSIX)

Return lExist


/*/{Protheus.doc} zCriaSxb
	( Fun��o necess�ria para criar registros na tabela de consulta padr�o din�mmicamente, normalmente
	utilizada em montagem de ambiente para customiza��es propriet�rias em MVC )
	@author Houston Santos
	@type User
	@since 31/03/2020
	@version 1.0
	 @param cIndice, Caracter, �ndice para verificar igualdade de registro
	 @param aFields, Array, Campos com as informa��es � serem inseridas na tabela
	 @return lSxbCriada, Retorna a confirma��o de cria��o do registro
	@see (https://tdn.totvs.com/pages/viewpage.action?pageId=24347041)
/*/

User Function zCriaSxb(cIncide, aFields)

    Local aArea := GetArea()
    Local aAreaXB := SXB->(aArea)
    Local lSxbCriada := .F.

    SXB->(dbSetOrder(1)) 
    If ! SXB->(DbSeek(cIncide))

        RecLock("SXB", .T.)
			SXB->XB_ALIAS := aFields[01]
			SXB->XB_TIPO := aFields[02]
			SXB->XB_SEQ := aFields[03]
			SXB->XB_COLUNA := aFields[04]
			SXB->XB_DESCRI := aFields[05]
			SXB->XB_DESCSPA	:= aFields[06]
			SXB->XB_DESCENG	:= aFields[07]
			SXB->XB_CONTEM := aFields[08]
			SXB->XB_WCONTEM	:= aFields[09]
		SXB->(MsUnlock())

        lSxbCriada := .T.

    EndIf

Return lSxbCriada


/*/{Protheus.doc} zCriaSx7
	( Fun��o necess�ria para criar registros na tabela de gatilhos din�mmicamente, normalmente
	   utilizada em montagem de ambiente para customiza��es propriet�rias em MVC )
	@author Houston Santos
	@type User
	@since 31/03/2020
	@version 1.0
	 @param cIndice, Caracter, �ndice para verificar igualdade de registro
	 @param aFields, Array, Campos com as informa��es � serem inseridas na tabela
	 @return lSx7Criada, Retorna a confirma��o de cria��o do registro
	 @example
	@see (https://tdn.totvs.com/pages/viewpage.action?pageId=24347041)
/*/

User Function zCriaSx7(cIndice, aFields)

    Local aArea      := GetArea()
    Local aAreaX7    := SX7->(aArea)
    Local lSx7Criada := .F.

    SX7->(dbSetOrder(1)) 
    If ! SX7->(DbSeek(cIndice))

        RecLock("SX7", .T.)
			SX7->X7_CAMPO := aFields[01]
			SX7->X7_SEQUENC := aFields[02]
			SX7->X7_REGRA := aFields[03]
			SX7->X7_CDOMIN	:= aFields[04]
			SX7->X7_TIPO := aFields[05]
			SX7->X7_SEEK := aFields[06]
			SX7->X7_ALIAS := aFields[07]
			SX7->X7_ORDEM := aFields[08]
			SX7->X7_CHAVE := aFields[09]    
            SX7->X7_CONDIC := aFields[10]
			SX7->X7_PROPRI := aFields[11]    
		SX7->(MsUnlock())

        lSx7Criada := .T.

    EndIf

Return lSx7Criada
