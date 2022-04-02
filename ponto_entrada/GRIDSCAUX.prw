#include "protheus.ch"
#define CTRF Chr(13) + Chr(10) // Quebra de linha da string


User Function CallGrdSC() 
    
    Private cTitulo := "Grupos x Compradores"
    Private aFields	:= {"MGRUPOS", "MPRODUTOS"} // Variável contendo o campo editável no Grid
    Private aBotoes := {}         // Variável onde será incluido o botão para a legenda
    Private Width := 180
    Private Height := 750

    Private oLista := Nil         // Declarando o objeto do browser
    Private aData  := {}          // Estrutura de dados para armazn as info do grid

    Private aHeaderEx := {}       // Variavel que montará o aHeader do grid
    Private aColsEx := {}         // Variável que receberá os dados
    PRivate aCompr := {}          // Variável que receberá os compradores relacionados aos grupos de produto

    //Declarando os objetos de cores para usar na coluna de status do grid
    Private oVerde := LoadBitmap( GetResources(), "BR_VERDE")
    Private oCinza := LoadBitmap( GetResources(), "BR_CINZA")

    U_DataGrdSC()
    Show()

Return


Static Function Show()


    DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 000, 000  TO Width, Height  PIXEL
        //chamar a função que cria a estrutura do aHeaderEx
        CriaCabec(DimmGrid(aData))

        //Monta o browser com inclusão, remoção e atualização
        oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aFields,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

        //Carregar os itens que irão compor o conteudo do grid
        Refresh()

        CCADASTRO := cTitulo

        //Alinho o grid para ocupar todo o meu formulário
        oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
        //Ao abrir a janela o cursor está posicionado no meu objeto
        oLista:oBrowse:SetFocus()

        //Crio o menu que irá aparece no botão Ações relacionadas
        aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})

        EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBotoes, /*nRecno*/, /*cAlias*/, .F./*lMashups*/, .F./*lImpCad*/, .F./*lPadrao*/, .F./*lHasOk*/, .F./*lWalkThru*/, "TESTET"/*cProfileID*/)

    ACTIVATE MSDIALOG oDlg CENTERED

Return Nil


Static Function CriaCabec(aDimmGrd)

    Aadd(aHeaderEx, {;
                  "",;          //X3Titulo()
                  "IMAGEM",;    //X3_CAMPO
                  "@BMP",;	    //X3_PICTURE
                  3,;		    //X3_TAMANHO
                  0,;		    //X3_DECIMAL
                  ".F.",;	    //X3_VALID
                  "",;		    //X3_USADO
                  "C",;		    //X3_TIPO
                  "",; 		    //X3_F3
                  "V",;		    //X3_CONTEXT
                  "",;		    //X3_CBOX
                  "",;		    //X3_RELACAO
                  "",;		    //X3_WHEN
                  "V"})		    //

    Aadd(aHeaderEx, {;
                  "Cód.",;      //X3Titulo()
                  "MY1_COD",;   //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aHeaderEx, {;
                  "Nome",;      //X3Titulo()
                  "MY1_NOME",;  //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  IIf(aDimmGrd <> Nil .And. Len(aDimmGrd) > 0, aDimmGrd[1], 40),; //X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aHeaderEx, {;
                  "E-mail",;	//X3Titulo()
                  "MY1_EMAIL",; //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  IIf(aDimmGrd <> Nil .And. Len(aDimmGrd) > 0, aDimmGrd[2], 40),; //X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "SB1",;		//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aHeaderEx, {;
                  "Telefone",;	//X3Titulo()
                  "MY1_TEL",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  IIf(aDimmGrd <> Nil .And. Len(aDimmGrd) > 0, aDimmGrd[3], 15),; //X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aHeaderEx, {;
                  "Itens da SC",;	//X3Titulo()
                  "MPRODUTOS",;  	//X3_CAMPO
                  "@!",;		    //X3_PICTURE
                  10,;              //X3_TAMANHO
                  0,;			    //X3_DECIMAL
                  "",;			    //X3_VALID
                  "",;			    //X3_USADO
                  "M",;			    //X3_TIPO
                  "",;			    //X3_F3
                  "R",;			    //X3_CONTEXT
                  "",;			    //X3_CBOX
                  "",;			    //X3_RELACAO
                  ""})			    //X3_WHEN
    
    Aadd(aHeaderEx, {;
                  "Grupos x Comprador",;	//X3Titulo()
                  "MGRUPOS",;  	            //X3_CAMPO
                  "@!",;		            //X3_PICTURE
                  10,;                      //X3_TAMANHO
                  0,;			            //X3_DECIMAL
                  "",;			            //X3_VALID
                  "",;			            //X3_USADO
                  "M",;			            //X3_TIPO
                  "",;			            //X3_F3
                  "R",;			            //X3_CONTEXT
                  "",;			            //X3_CBOX
                  "",;			            //X3_RELACAO
                  ""})			            //X3_WHEN

Return


Static Function Refresh()

    Local oLeg := Nil
    oLeg := IIf(Len(aData) > 1, oCinza, oVerde) 

    If aData <> Nil .And. Len(aData) > 0

        For i := 1 To Len(aData)

            cStrGrupo    := ""
            cStrProdutos := ""

            For z := 1 To Len(aData[i][5])
                cStrProdutos += aData[i][5][z][1] + " - " + aData[i][5][z][2] + CTRF
            Next

            For z := 1 To Len(aData[i][6])
                cStrGrupo += aData[i][6][z][1] + " - " + aData[i][6][z][2] + CTRF
            Next

            aAdd(aColsEx, { oLeg,  aData[i][1], aData[i][2], aData[i][3], aData[i][4], cStrProdutos, cStrGrupo, .F.})

        Next

    Else
        aAdd(aColsEx, { oLeg,  "", "", "", "", "", .F.})
    EndIf

    //Setar array do aCols do Objeto.
    oLista:SetArray(aColsEx,.T.)

    //Atualizo as informações no grid
    oLista:Refresh()

Return


Static function Legenda()

    Local aLegenda := {}
    AADD(aLegenda,{"BR_CINZA" ,"   Você precisa dividir a SC" })
    AADD(aLegenda,{"BR_VERDE" ,"   Autorizado" })

    BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil


Static Function DimmGrid(aData)

    Local aRet := {}
    Local nMaxParam1 := 1
    Local nMaxParam2 := 1
    Local nMaxParam3 := 1

    For i := 1 To Len(aData)

        nMaxParam1 := IIf(Len(aData[i][1]) > nMaxParam1, Len(aData[i]), nMaxParam1)
        nMaxParam2 := IIf(Len(aData[i][2]) > nMaxParam2, Len(aData[i]), nMaxParam2)
        nMaxParam3 := IIf(Len(aData[i][3]) > nMaxParam3, Len(aData[i]), nMaxParam3)

    Next

    aRet := { nMaxParam1, nMaxParam2, nMaxParam3 }

Return aRet


User Function  DataGrdSC()

    Local aCompr := {} // Retornara os compradores 
    Local aColsExx := {} // Recupera apenas os itens que não estejam deletados do grid
   
    Private aProdsSC := {} // Recuperar os produtos do grid da SC
    
    //aColsExx := aFilter(aCols, {|x| x[1] == "CAMPO" })
    aEval(aCols, {|x| IIf(x[Len(x)] == .F., aAdd(aProdsSC, x[GDFieldPos("C1_PRODUTO")]), "") })  // Recupera o código dos Produtos da SC
    aEval(aProdsSC, {|cPrd| Agrupar(cPrd, @aCompr) })                // Realiza um distinct nos grupos dos produtos para não se repetirem;

    aData := aCompr

Return aCompr


Static Function Agrupar(cPrd, aCompr)

    //Captura o grupo do produto
    Local cGrupo := AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + cPrd, "B1_GRUPO"))
    Local cCompr := AllTrim(POSICIONE("SBM", 1, xFilial("SBM") + cGrupo, "BM_XCOMPRA"))
    Local aGrupos := {}
    Local aProdutos := {}
    Local cFilter := ""
	Local lHas := .F. // Valida se já existe o grupo no array para n duplicar
	
    // Validação de existência no array de grupos
	lHas := IIf(aScan(aCompr, {|x| x[1] == cCompr })  > 0, .T., .F.)

    // Somente adiciona no array caso ainda não existe e <> Vazio()
	If(!lHas .And. !Empty(cCompr))
        
        SY1->(DbSelectArea("SY1"))
        POSICIONE("SY1", 1, xFilial("SY1") + cCompr, "")

        cCod   := AllTrim(SY1->Y1_COD)
        cNome  := AllTrim(SY1->Y1_NOME)
        cEmail := AllTrim(SY1->Y1_EMAIL)
        cTel   := AllTrim(SY1->Y1_TEL)

        SY1->(DbCloseArea())
        SBM->(DbSelectArea("SBM"))

        cFilter := "SBM->BM_FILIAL == '" + xFilial('SBM') + "' .AND. "
        cFilter := "SBM->BM_XCOMPRA == '" + cCompr + "'"
        
        SBM->(DbSetFilter( {|| &cFilter }, cFilter ))
        SBM->(DbGoTop())

        While SBM->(!Eof())
            aAdd(aGrupos, { AllTrim(SBM->BM_GRUPO), AllTrim(SBM->BM_DESC) })
            SBM->(DbSkip())
        End

        SBM->(DbClearFilter())
        SBM->(DbCloseArea())

        For i := 1 To Len(aProdsSC)
            SB1->(DbSelectArea('SB1'))
            cGrupoSC := AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + aProdsSC[i], "B1_GRUPO"))
            If (aScan(aGrupos, { |x| AllTrim(x[1]) == AllTrim(cGrupoSC) }) > 0)
                aAdd(aProdutos, { AllTrim(SB1->B1_COD), AllTrim(SB1->B1_DESC) })
                SB1->(DbCloseArea())
            EndIf
        Next

        aAdd(aCompr, {cCod, cNome, cEmail, cTel, aProdutos, aGrupos})

	EndIf

Return Nil
