#include "protheus.ch"
#define ENTER Chr(10) + Chr(13)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261BCHOI ºAutor  ³Microsiga           º Data ³  09/27/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function M261BCHOI()
	
	Local _aRet := {}
	AAdd(_aRet,{"VERNOTA" ,{ || _fTransTr("1") },"Ordens de Producao"})

Return(_aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261BCHOI ºAutor  ³Microsiga           º Data ³  09/27/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _fTransTr(_cParam)
	Local _cArea  := GetArea()
	Local _cOPDe  := CriaVar("D3_OP",.F.)
	Local _cOPAt  := CriaVar("D3_OP",.F.)
	Local _cLocDe := CriaVar("D3_LOCAL",.F.)
	Local _cLocAt := CriaVar("D3_LOCAL",.F.)
	Local _cTipo
	Local _cUM
	Local _lPA := .f.
	Local lInverte := .F.
	Local oDlg1
	Local _nOpca := 2
	Local _lContinua := .f.
	Local aSemSld := {}
	Local _aCols261 := aClone(aCols)
	Local aSldLote := {}
	Local _nSldLote := 0
	Local cMask := "Arquivos Texto (*.TXT) |*.txt|"
	Local cFile	:=	""
	Private cMarca := GetMark()

	DEFINE MSDIALOG _oDlg TITLE "Informar as OPs" FROM C(178), C(263) TO C(300), C(600) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(021), C(099) MsGet oOPDe Var _cOPDe F3 "SC2" Valid ExistCpo("SC2",_cOPDe,1) Size C(040),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(022), C(041) Say "Ordem de Producao de:"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(037), C(099) MsGet oOPAt Var _cOPAt F3 "SC2" Valid ExistCpo("SC2",_cOPAt,1) Size C(040), C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(038), C(042) Say "Ordem de Producao Ate:" Size C(051), C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(053), C(099) MsGet oLocDe Var _cLocDe F3 "SC2" Valid ExistCpo("NNR",_cLocDe,1) Size C(040), C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(054), C(041) Say "Almoxarifado de:"  Size C(050), C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(069), C(099) MsGet oLocAt Var _cLocAt F3 "NNR" Valid ExistCpo("NNR",_cLocAt,1) Size C(040), C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	// @ C(070), C(042) Say "Almoxarifado Ate:" Size C(051), C(008) COLOR CLR_BLACK PIXEL OF _oDlg

	@ C(040), C(045) BUTTON "Confirma"   SIZE 30,12 PIXEL OF _oDlg ACTION (_lContinua := .t., _oDlg:End())
	@ C(040), C(099) BUTTON "Cancela" 	SIZE 30,12 PIXEL OF _oDlg ACTION Close(_oDlg)

	ACTIVATE MSDIALOG _oDlg CENTERED

	If !_lContinua .or. Empty(_cOPDe)
		Alert("Selecao Cancelada")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os campos do arquivo de trabalho com as disciplinas do professor  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampoTRB := {{ "TRB_OK"    	,"C", 2, 0},;
	{ "TRB_OP"	  , "C", TamSX3("D3_OP")[1], 0},;
	{ "TRB_COD"	  , "C", TamSX3("B2_COD")[1], 0},;
	{ "TRB_DESC"  , "C", TamSX3("B1_DESC")[1], 0},;
	{ "TRB_LOCAL" , "C", TamSX3("B2_LOCAL")[1], 0},;
	{ "TRB_QTDE"  , "N", TamSX3("D3_QUANT")[1], TamSX3("D3_QUANT")[2]},;
	{ "TRB_QUJE"  , "N", TamSX3("D3_QUANT")[1], TamSX3("D3_QUANT")[2]}}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o Arquivo de Trabalho que tera as Outras Grades Curriculares.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cArqTRB := CriaTrab(aCampoTRB, .T.)
	DbUseArea(.T.,, _cArqTRB, "TRB", .F.)

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSeek(xFilial()+_cOPDe)
	
	_cTipo := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_TIPO")
	_cUM := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_UM")
	_lPA := IIF(_cTipo == "PA" .and. _cUM == "CX", .T., .F.)

	If _lPA
		_cOPAt := Substr(_cOPDe, 1, 8) + Soma1(Substr(_cOPDe, 9, 3)) + Substr(_cOPDe, 12)
	Else
		_cOPAt := _cOPDe
	Endif

	_cQuery := ""
	_cArqTMP := CriaTrab(nil, .f.)

	_cQuery := "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_LOCAL, C2_QUANT, C2_QUJE "
	_cQuery += "FROM "+RetSqlName("SC2")+" SC2 "
	_cQuery += "WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
	_cQuery += "AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD >= '"+_cOPDe+"' "
	_cQuery += "AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD <= '"+_cOPAt+"' "
	_cQuery += "AND C2_DATRF = '        '
	_cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
	_cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN"

	DbUseArea(.T., "TOPCONN", TCGenQry(,, _cQuery), _cArqTMP, .t., .t.)
	//TcSetField(_cArqTMP,"VALIDADE","D")

	(_cArqTMP)->(DbGoTop())
	While (_cArqTMP)->(!Eof())
		RecLock("TRB", .T.)
		TRB_OK := "  "
		TRB_OP := (_cArqTMP)->(C2_NUM + C2_ITEM + C2_SEQUEN)
		TRB_COD	:= (_cArqTMP)->C2_PRODUTO
		TRB_DESC := Posicione("SB1", 1, xFilial("SB1") + (_cArqTMP)->C2_PRODUTO, "B1_DESC")
		TRB_LOCAL := (_cArqTMP)->C2_LOCAL
		TRB_QTDE := (_cArqTMP)->C2_QUANT
		TRB_QUJE := (_cArqTMP)->C2_QUJE
		TRB->(MsUnlock())
		(_cArqTMP)->(DbSkip())
	Enddo

	// Apagando a query pois meu TRB já está carregado
	(_cArqTMP)->(DbCloseArea())
	TRB->(DbGoTop())

	If !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as colunas que serão exibidas na MarkBrowse                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		aCpoBrw :=  {{"TRB_OK"		, , " "," "},;
		{ "TRB_OP" 	  , , "OP" 		  , PesqPict("SD3", "D3_OP"	  )},;
		{ "TRB_COD"   , , "Produto"   , PesqPict("SB2", "B2_COD"  )},;
		{ "TRB_DESC"  , , "Descrição" , PesqPict("SB1", "B1_DESC" )},;
		{ "TRB_LOCAL" , , "Local" 	  , PesqPict("SB2", "B2_LOCAL")},;
		{ "TRB_QTDE"  , , "Quantidade", PesqPict("SD3", "D3_QUANT")},;
		{ "TRB_QUJE"  , , "Produzido" , PesqPict("SC2", "C2_QUJE" )} }
		
		_nOpca := 1
	
		// confirmou com itens selecionados
		If _nOpca == 1 
			_aHeader := aClone(aHeader)
			_nCodOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_COD"})
			_aHeader[_nCodOri,2] := ""
			_nDesOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_DESCRI"})
			_aHeader[_nDesOri,2] := ""
			_nUMOri  := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_UM"})
			_aHeader[_nUMOri,2] := ""
			_nLocOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOCAL"})
			_aHeader[_nLocOri,2] := ""
			_nLotOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOTECTL"})
			_aHeader[_nLotOri,2] := ""
			_nVldOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_DTVALID"})
			_aHeader[_nVldOri,2] := ""
			_nEndOri := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOCALIZ"})
			_aHeader[_nEndOri,2] := ""
			_nPosQtd := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_QUANT"})
			_nCodDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_COD"})
			_nDesDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_DESCRI"})
			_nUMDes  := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_UM"})
			_nLocDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOCAL"})
			_nLotDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOTECTL"})
			_nVldDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_DTVALID"})
			_nEndDes := Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_LOCALIZ"})
			TRB->(DbGoTop())

			While TRB->(!Eof())
				If Len(aCols) > 0 .and. Empty(aCols[1, Ascan(_aHeader, {|x| Alltrim(x[2]) == "D3_COD"})])
					ADEL(aCols, 1)
					ASIZE(aCols, Len(aCols) - 1)
				EndIf

				// inicia produto no armazem destino, caso nao exista
				_cOP := TRB->TRB_OP
				DbSelectArea("SD4")
				DbSetOrder(2)
				DbSeek(xFilial()+_cOP)
				While !Eof() .and. xFilial("SD4") + _cOP == SD4->(D4_FILIAL + D4_OP)

					_cLocDes := SD4->D4_LOCAL

					If SD4->D4_QUANT <= 0
						DbSkip()
						Loop
					Endif

					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1") + SD4->D4_COD))

					If SB1->B1_TIPO == "PI"
						DbSelectArea("SD4")
						DbSkip()
						Loop
					Endif
				
					If SB1->B1_LOCPAD == SD4->D4_LOCAL
						DbSelectArea("SD4")
						DbSkip()
						Loop
					Endif
				
					If SD4->D4_OPORIG == _cOPAt 				
						DbSelectArea("SD4")
						DbSkip()
						Loop
					Endif

					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek(xFilial("SB2") + SD4->D4_COD + _cLocDes))
						CriaSb2(SD4->D4_COD, _cLocDes)
					EndIf

					If Rastro(SD4->D4_COD)
						DbSelectArea("SG1")
						DbSetOrder(1)
						If Empty(SD4->D4_LOTECTL)
							SB1->(DbSetOrder(1))
							SB1->(DbSeek(xFilial("SB1") + SD4->D4_COD))
							DbSelectArea("NNR")
							DbSeek(xFilial() + SD4->D4_LOCAL)
							aSldLote := SldPorLote(SD4->D4_COD,SB1->B1_LOCPAD,SD4->D4_QUANT,SD4->D4_QTSEGUM,/*SD4->D4_LOTECTL*/,/*SD4->D4_NUMLOTE*/,NIL,;
													NIL,NIL,.F.,SB1->B1_LOCPAD,NIL,NIL,.F.,dDataBase)
							_nSldLote := 0
							For nH:=1 to Len(aSldLote)					 	
								AADD(aCols,Array(Len(aHeader) + 1))
								_nAcols := Len(aCols)
								For nx:=1 to Len(aHeader)
									cCampo:=Alltrim(aHeader[nx, 2])
									If cCampo == "D3_ALI_WT"
										aCols[_nAcols][nx] := "SD3"
									ElseIf cCampo == "D3_REC_WT"
										aCols[_nAcols][nx] := 0
									Else
										aCols[_nAcols][nx] := CriaVar(cCampo, .F.)
									Endif
								Next nx
								aCOLS[_nAcols][Len(aHeader) + 1] := .F.
								// Preenche campos especificos
								aCols[_nAcols, _nCodOri] := SD4->D4_COD
								aCols[_nAcols, _nDesOri] := SB1->B1_DESC
								aCols[_nAcols, _nUMOri]  := SB1->B1_UM
								aCols[_nAcols, _nLocOri] := SB1->B1_LOCPAD
								GDFieldPut("D3_SEGUM", SB1->B1_SEGUM, _nAcols)
								GDFieldPut("D3_QUANT", aSldLote[nH, 5], _nAcols)
								aCols[_nAcols, _nCodDes] := SD4->D4_COD
								aCols[_nAcols, _nDesDes] := SB1->B1_DESC
								aCols[_nAcols, _nUMDes]  := SB1->B1_UM
								aCols[_nAcols, _nLocDes] := _cLocDes
								If Localiza(SD4->D4_COD)
									DbSelectArea("SBE")
									DbSetOrder(1)
									If DbSeek(xFilial() + _cLocDes)
										aCols[_nAcols, _nEndDes] := SBE->BE_LOCALIZ
									Endif
								Endif
								aCols[_nAcols, _nLotOri] := aSldLote[nH, 1]
								aCols[_nAcols, _nVldOri] := aSldLote[nH, 7]
								aCols[_nAcols, _nLotDes] := aSldLote[nH, 1]
								aCols[_nAcols, _nVldDes] := aSldLote[nH, 7]
							Next
						Endif
					Else
						Verif_Sld(SD4->D4_COD, SB1->B1_LOCPAD, SD4->D4_QUANT, @aSemSld)
						If Len(aSemSld) == 0
							AADD(aCols,Array(Len(aHeader) + 1))
							_nAcols := Len(aCols)
							For nx:=1 to Len(aHeader)
								cCampo:=Alltrim(aHeader[nx, 2])
								If cCampo == "D3_ALI_WT"
									aCols[_nAcols][nx] := "SD3"
								ElseIf cCampo == "D3_REC_WT"
									aCols[_nAcols][nx] := 0
								Else
									aCols[_nAcols][nx] := CriaVar(cCampo, .F.)
								Endif
							Next nx
							aCOLS[_nAcols][Len(aHeader) + 1] := .F.
							// Preenche campos especificos
							aCols[_nAcols, _nCodOri] := SD4->D4_COD
							aCols[_nAcols, _nDesOri] := SB1->B1_DESC
							aCols[_nAcols, _nUMOri]  := SB1->B1_UM
							aCols[_nAcols, _nLocOri] := SB1->B1_LOCPAD
							GDFieldPut("D3_SEGUM", SB1->B1_SEGUM, _nAcols)
							GDFieldPut("D3_QUANT", SD4->D4_QUANT, _nAcols)
							aCols[_nAcols, _nCodDes] := SD4->D4_COD
							aCols[_nAcols, _nDesDes] := SB1->B1_DESC
							aCols[_nAcols, _nUMDes]  := SB1->B1_UM
							aCols[_nAcols, _nLocDes] := _cLocDes
							If Localiza(SD4->D4_COD)
								DbSelectArea("SBE")
								DbSetOrder(1)
								If DbSeek(xFilial() + _cLocDes)
									aCols[_nAcols, _nEndDes] := SBE->BE_LOCALIZ
								Endif
							Endif
						Else
							Exit
						Endif
					Endif
					DbSelectArea("SD4")
					SD4->(DbSkip())
				Enddo
				If Len(aSemSld) > 0
					Exit
				Endif
				DbSelectArea("TRB")
				TRB->(DbSkip())
			End
			If Len(aCols) > 1
				aSort(aCols,,,{|x, y|x[_nCodOri] < y[_nCodOri]})
			Endif
			If Len(aSemSld) > 0
				_cMens := "Itens sem Saldo: " + ENTER
				For nB := 1 to Len(aSemSld)
					_cMens += "Item: " + aSemSld[nB,1] + " - " + Alltrim(Posicione("SB1", 1, xFilial("SB1") + aSemSld[nB, 1], "B1_DESC")) + ENTER
				Next

				DEFINE FONT oFont NAME "Mono AS" SIZE 6,15   
				DEFINE MSDIALOG oDlg TITLE "Itens Sem Saldos em Estoque" From 3,0 to 340,717 PIXEL
				@ 5,5 GET oMemo  VAR _cMens MEMO SIZE 350,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask, ""), If(cFile = "" ,.t. ,MemoWrite(cFile,_cMens))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

				ACTIVATE MSDIALOG oDlg CENTER
				aCols := aClone(_aCols261)
			Endif
		EndIf
	Else
		Alert("Nao encontrado registros")
	Endif
	TRB->(DbCloseArea())
	RestArea(_cArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261BCHOI ºAutor  ³Microsiga           º Data ³  09/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _f261Inverte(cMarca)

	_nRecno := TRB->(Recno())
	TRB->(DbGoTop())

	While TRB->(!Eof())
		RecLock("TRB", .F.)
		IF TRB_OK == cMarca
			TRB->TRB_OK := "  "
		Else
			TRB->TRB_OK := cMarca
		Endif
		TRB->(MsUnlock())
		TRB->(DbSkip())
	Enddo
	TRB->(DbGoTo(_nRecno))
	oMark:oBrowse:Refresh(.t.)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261BCHOI ºAutor  ³Microsiga           º Data ³  09/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _fVldBtn(cMarca)

	Local _lRet := .F.

	_nRecno := TRB->(Recno())
	TRB->(DbGoTop())
	While TRB->(!Eof())
		IF TRB_OK == cMarca
			_lRet := .T.
			Exit
		ENDIF
		TRB->(DbSkip())
	Enddo
	TRB->(DbGoTo(_nRecno))

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)

	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261BCHOI ºAutor  ³Microsiga           º Data ³  10/21/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Verif_Sld(_cCodPro, _cLocOri, _nQuantOri, aSemSld)

	Local _aArea := GetArea()
	Local lRastroL  := Rastro(_cCodPro, 'L')
	Local lRastroS  := Rastro(_cCodPro, 'S')
	Local lLocalizO := Localiza(_cCodPro)
	Local lLocalizD := Localiza(_cCodPro)
	Local lPermNegat  := GetMV('MV_ESTNEG') == 'S'
	Local lDigita := .T.
	Local lContinua := .t.
	Local lSaldoSemR := Nil

	If !lPermNegat .And. (!(lRastroL .Or. lRastroS) .And. (!lLocalizO .And. !lLocalizD) .Or. IntDL(_cCodPro))
		If aScan(aSemSld,{|x| x[1] == _cCodPro}) == 0
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial('SB2') + _cCodPro + _cLocOri, .F.))
				aadd(aSemSld,{_cCodPro, _cLocOri})
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
			If lContinua
				//-- Subtrai a Reserva do Saldo a ser Retornado?
				nSaldo := SaldoMov(Nil, Nil, Nil, If(mv_par03 == 1, .F., Nil), Nil, Nil, lSaldoSemR, If(Type('dA261Data') == "D", dA261Data, dDataBase))
				If QtdComp(nSaldo) < QtdComp(_nQuantOri)
					aadd(aSemSld, {_cCodPro , _cLocOri})
					lRet		:= .F.
					lContinua	:= .F.
				EndIf
			EndIf
		Endif
	EndIf
	RestArea(_aArea)

Return
