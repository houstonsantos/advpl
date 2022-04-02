#include "protheus.ch"
#include "parmtype.ch"


Static cSource := "FichaTecMvc"
Static nIncluir := 3
Static nAlterar := 4
Static nExcluir := 5
Static MB_ICONASTERISK := 64
Static BrokenLine      := Chr(13) + Chr(10)

/*/{Protheus.doc} AbrirFichaTecnica
    (Realiza o controle de abertura da tela de ficha t�cnica de acordo com a opera��o selecionada
    e validando se o produto tem ficha ou n�o em opera��es de altera��o e exclus�o )
    @type User Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return Nil
    @see (links_or_references)
/*/

User Function AbrirFichaTecnica()

    Local nOperation := Iif(INCLUI, nIncluir, Iif(ALTERA, nAlterar, nExcluir))

    If (! ProdutoBloqueado() .AND. VerificarAmbiente())
        ExecView(cSource, nOperation)
    EndIf

Return Nil


/*/{Protheus.doc} ValidaOperacao
    (Antes de abrir o modal, o sistema valida se o produto selecionado 
    tem informa��o suficiente para realizar a a��o selecionada.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param nOperation
    @return .F. or .T. 
    @example
     nOperation := 3 INSERIR / 4 nAlterar / nExcluir
     ValidaOperacao(nOperation)
    @see (links_or_references)
/*/

Static Function ValidaOperacao(nOperation)

    If ((nOperation == nIncluir .And. ! ExisteFichaTecnica(AllTrim(SB1->B1_COD))) .Or. ((nOperation == nAlterar .Or. nOperation == nExcluir) .And. ExisteFichaTecnica(AllTrim(SB1->B1_COD))))
        Return .T.
    EndIf

Return .F.


/*/{Protheus.doc} ProdutoBloqueado
    ( Valida se o produto selecionado encontra-se com o status de bloqueado no banco de dados.  )
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return .F. or .T.
    @example
     Iif (ProdutoBloqueado(), MsgInfo('BLOQUEADO'), MsgInfo('HABILITADO'))
    @see (links_or_references)
/*/

Static Function ProdutoBloqueado()

    Local aAreaSB1 := SB1->(GetArea())
    Local lRet := .F.

    If(AllTrim(SB1->B1_MSBLQL) == "1")
        MsgAlert(OemToAnsi("O produto selecionado encontra-se bloqueado e n�o pode ser manipulado."), "Aten��o")
        lRet := .T.
    EndIf

    RestArea(aAreaSB1)

Return lRet


/*/{Protheus.doc} MostrarMensagemValidacao
    ( Exibe uma caixa de dialogo de acordo com a opera��o 
    selecionada pelo usu�rio no menu ficha tec do Browse)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param cSource, nOperation
    @return .F. or .T.
    @example
     MostrarMensagemValidacao(cSource, nOperation)
    @see (links_or_references)
/*/

Static Function MostrarMensagemValidacao(cSource, nOperation)

    Local cMessage := "N�o existe ficha t�cnica registrada para este produto, deseja nIncluir um novo registro?"

    If (nOperation == nIncluir)
        cMessage := "J� existe ficha tecnica registrada para este produto, deseja realizar sua altera��o?"
    EndIf
    
Return ApMsgYesNo(OemToAnsi(cMessage))


/*/{Protheus.doc} ExecView
    (Executa a view ou exibe caixa de dialogo de acordo com os par�metros enviados.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param cSource, nOperation
    @return none
    @example
     ExecView(cSource, nOperation)
    @see (links_or_references)
/*/

Static Function ExecView(cSource, nOperation)

    If (ValidaOperacao(nOperation))       

        oExecView := FWViewExec():New()
        oExecView:setTitle(GetTituloView(nOperation))
        oExecView:setSource(cSource)
        oExecView:setButtons(GetBotoesFicha())
        oExecView:setOperation(nOperation)
        oExecView:setModal(.T.)               
        oExecView:openView(.T.)

    ElseIf MostrarMensagemValidacao(cSource, nOperation)
        ExecView(cSource, Iif(nOperation == nAlterar .OR. nOperation == nExcluir, nIncluir, nAlterar))
    EndIf

Return 


/*/{Protheus.doc} GetTituloView
    (Retorna o t�tulo da view de acordo com a opera��o selecionada.)
    @type Static Function
    @author Houston Santos
    @since 23/10/2019
    @version version
    @param nOperation
    @return cTitle
    @see (links_or_references)
/*/

Static Function GetTituloView(nOperation)

    Local cTitle := "Ficha T�cnica - "
    cTitle += Iif(nOperation == nIncluir, "Inclus�o", Iif(nOperation == nAlterar, "Modifica��o", "Exclus�o"))

Return OemToAnsi(cTitle)

/*/{Protheus.doc} GetBotoesFicha
    (Retorna quais bot�es v�o aparecer no formul�rio de ficha t�cnica.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return aButtons
    @see (links_or_references)
/*/

Static Function GetBotoesFicha()

    Local aButtons := {}
    aButtons := {{.F., Nil},; // 01 - Copiar
                 {.F., Nil},; // 02 - Recortar
                 {.F., Nil},; // 03 - Colar
                 {.F., Nil},; // 04 - Calculadora
                 {.F., Nil},; // 05 - Spool
                 {.F., Nil},; // 06 - Imprimir
                 {.T., Nil},; // 07 - Confirmar
                 {.T., Nil},; // 08 - Cancelar
                 {.F., Nil},; // 09 - WalkTrhough
                 {.F., Nil},; // 10 - Ambiente
                 {.F., Nil},; // 11 - Mashup
                 {.F., Nil},; // 12 - Help
                 {.F., Nil},; // 13 - Formul�rio HTML
                 {.F., Nil}}  // 14 - ECM

Return aButtons


/*/{Protheus.doc} ExisteFichaTecnica
    (Verifica se h� registro na tabela de ficha para o produto selecionado.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param cZFT_CODPRO|CHARACTER
    @return lRet|L�GICO
    @example
     ExisteFichaTecnica(cZFT_CODPRO)
    @see (links_or_references)
/*/

Static Function ExisteFichaTecnica(cZFT_CODPRO)

    Local lRet := .F.

    DbSelectArea("ZFT")                                	
    ZFT->(DbSetOrder(1))

    If (DbSeek(xFilial("ZFT") + cZFT_CODPRO))
        lRet := .T.
    EndIf

Return lRet


/*/{Protheus.doc} VerificarAmbiente
    (Verifica se a empresa tem as tabelas necess�rias para a rotina e caso contr�rio 
    o sistema monta o, ambiente criando a estrutura de tabelas e dic necess�rio.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return lRet
    @see (links_or_references)
/*/

Static Function VerificarAmbiente()

    Local lRet := .T.

    If(ChkFile('ZFT') .And. ChkFile('ZIN') .And. ChkFile('ZPR'))
        Return lRet
    Else
        MsgRun("Preparando o ambiente.", "Aguarde...",  {|| lRet := MontarAmbiente() })
        If lRet
            MsgInfo("Todas as depend�ncias foram resolvidas com sucesso.", "Prepara��o do ambiente")
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} MontarAmbiente
    (Cria a estrutura de tabelas e registros no dicion�rio necess�rios para a rotina funcionar.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return .F. or .T.
    @see (links_or_references)
/*/

Static Function MontarAmbiente()

    Local nPosicao    := 0 // Utilizada para itera��o do For
    Local cErrorDesc  := ""
    Local cErrorStack := ""
    Local cError      := "Ocorreu um erro durante a prepara��o do ambiente para a rotina de ficha t�cnica."
    Local oLastError  := ErrorBlock({|e| cErrorDesc := e:Description, cErrorStack := e:ErrorStack})
    Local aTabelas    := GetTabelas()

    For nPosicao := 1 to Len(aTabelas)

        u_zCriaTab(aTabelas[nPosicao][2]/*Table TOPCONN*/,;
                   aTabelas[nPosicao][3]/*SX2*/,;
                   aTabelas[nPosicao][4]/*SX3*/,;
                   aTabelas[nPosicao][5]/*SIX*/, {}/*SXA*/)
    
        If  (! Empty(cErrorDesc) .OR. ! Empty(cErrorStack))

            ErrorBlock(oLastError)
            FwLogMsg("ERROR", /*cTransactionId*/, "FICHA", FunName(), "", "01", cError + BrokenLine + BrokenLine + cErrorStack, 0, 0, {}) // nStart � declarada no inicio da fun��o
            MsgStop(cError + BrokenLine + BrokenLine + "ERROR: " + cErrorDesc + BrokenLine + "STACKTRACE" + cErrorStack, "TOTVS")

            Return .F.
        EndIf
    Next

Return .T.


/*/{Protheus.doc} GetTabelas
    (Define a estrutura de campos, �ndices e dicion�rios das tabelas customizadas ZFT e ZIN.)
    @type Static Function
    @author Houston Santos
    @since 15/10/2019
    @version version
    @param none
    @return aTabelas
    @see (links_or_references)
/*/

Static Function GetTabelas()

    // ZFT - Campos - NOME | TIPO | TAMANHO | DECIMAIS
    Local aTabZFT := {{'ZFT_FILIAL', 'C', 02 , 0 },;
                      {'ZFT_CODPRO', 'C', 15 , 0 },;
                      {'ZFT_GLUTEM', 'C', 01 , 0 },;
                      {'ZFT_LACTOS', 'C', 01 , 0 },;
                      {'ZFT_INTEGR', 'C', 01 , 0 },;
                      {'ZFT_VEGANO', 'C', 01 , 0 },;
                      {'ZFT_LIGHT' , 'C', 01 , 0 },;
                      {'ZFT_DIET'  , 'C', 01 , 0 },;
                      {'ZFT_PREPAR', 'C', 02 , 0 },;
                      {'ZFT_DICAS' , 'M', 999, 0 },;
                      {'ZFT_RECEIT', 'M', 999, 0 },;
                      {'ZFT_QRCODE', 'C', 150, 0 },;
                      {'ZFT_DESCRI', 'C', 50 , 0 }}

    // ZFT - Manuten��o de Arquivo | SX2
    Local aSX2ZFT := {'ZFT', 'Ficha T�cnica Produto', 'C', 'C', 'C'}

    // ZFT - Manuten��o de Campos | SX3
    Local aSX3ZFT := {{'ZFT_FILIAL', '', '02' , '0', 'C', 'Filial'        , 'Filial do sistema'     , '@!', '1', '', '', ''   , ''   , '' , '' , 'N', '' , ''                                            , '', '', ''},;
                      {'ZFT_CODPRO', '', '15' , '0', 'C', 'C�d. Produto'  , 'C�digo do produto'     , '@!', '0', '', '', ''   , 'SB1', 'V', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_GLUTEM', '', '01' , '0', 'C', 'Gl�tem'        , 'Cont�m gl�tem'         , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_LACTOS', '', '01' , '0', 'C', 'Lactose'       , 'Cont�m lactose'        , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_INTEGR', '', '01' , '0', 'C', 'Integral'      , 'Produto integral'      , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_VEGANO', '', '01' , '0', 'C', 'Vegano'        , 'Produto vegano'        , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_LIGHT' , '', '01' , '0', 'C', 'Light'         , 'Produto light'         , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_DIET'  , '', '01' , '0', 'C', 'Diet'          , 'Produto diet'          , '@!', '0', '', '', '"N"', ''   , 'A', 'R', 'N', '�', 'S=Sim;N=N�o'                                 , '', '', ''},;
                      {'ZFT_DICAS' , '', '10' , '0', 'M', 'Dicas'         , 'Dicas de comb e harm'  , ''  , '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_RECEIT', '', '10' , '0', 'M', 'Receitas'      , 'Receitas com o produto', ''  , '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_INGRED', '', '10' , '0', 'M', 'Ingredientes'  , 'Ingredientes p/ ficha' , ''  , '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_ALERGI', '', '10' , '0', 'M', 'Al�rgicos'     , 'Al�rgicos p/ ficha'    , ''  , '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_QRCODE', '', '150', '0', 'C', 'QR Code'       , 'C�digo QR'             , '@!', '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''},;
                      {'ZFT_DESCRI', '', '50' , '0', 'C', 'T�tulo'        , 'Nome comercial'        , '@!', '0', '', '', ''   , ''   , 'A', 'R', 'N', '�', ''                                            , '', '', ''}}
                        
    // ZFT - �ndices dos Arquivos | SIX
    Local aSIXZFT := {{'ZFT', '1', 'ZFT_FILIAL+ZFT_CODPRO', 'C�d. Produto', 'U', '', 'N'}}

    // ZIN - Campos - NOME | TIPO | TAMANHO | DECIMAIS
    Local aTabZIN := {{'ZIN_FILIAL', 'C', 02 , 0},; 
                      {'ZIN_CODPRO', 'C', 15 , 0},;
                      {'ZIN_DESC'  , 'C', 200, 0},;
                      {'ZIN_QTDPOR', 'C', 20 , 0},;
                      {'ZIN_VD'    , 'C', 5  , 0}} 

    // ZIN - Manuten��o de Arquivo | SX2
    Local aSX2ZIN := {'ZIN', 'Informa�oes Nutricionais', 'C', 'C', 'C'}

    // ZIN - Manuten��o de Campos | SX3
    Local aSX3ZIN := {{'ZIN_FILIAL', '', '02' , '0', 'C', 'Filial'      , 'Filial do Sistema'    , '@!', '1', '', '', '' , ''   , '' , '' , 'N', '' , '' , '', '', '1'},;
                      {'ZIN_CODPRO', '', '15' , '0', 'C', 'C�d. Produto', 'C�digo do produto'    , '@!', '0', '', '', '' , 'SB1', 'V', 'R', 'N', '�', '' , '', '', '1'},;
                      {'ZIN_DESC'  , '', '200', '0', 'C', 'Descri��o'   , 'Descri��o'            , '@!', '0', '', '', '' , ''   , 'A', 'R', 'N', '�', 'VALOR ENERG�TICO;CARBOIDRATOS;PROTE�NAS;GORDURAS TOTAIS;GORDURAS SATURADAS;GORDURAS TRANS;FIBRA ALIMENTAR;S�DIO' , '', '', '1'},;
                      {'ZIN_QTDPOR', '', '20' , '0', 'C', 'Qtd. Por�ao' , 'Quantidade por Por�ao', '@!', '0', '', '', '' , ''   , 'A', 'R', 'N', '�', '' , '', '', '1'},;
                      {'ZIN_VD'    , '', '05' , '0', 'C', '%V.D (*)'    , '%V.D (*)'             , '@!', '0', '', '', '' , ''   , 'A', 'R', 'N', '�', '' , '', '', '1'}}

    // ZIN - �ndices dos Arquivos | SIX
    Local aSIXZIN := {{'ZIN', '1', 'ZIN_FILIAL+ZIN_CODPRO', 'C�d. Produto', 'U', '', 'N'}}

    // ZPR - Campos - NOME | TIPO | TAMANHO | DECIMAIS
    Local aTabZPR := {{'ZPR_FILIAL', 'C', 02 , 0},; 
                      {'ZPR_CODPRO', 'C', 15 , 0},;
                      {'ZPR_FORMA' , 'C', 200, 0},;
                      {'ZPR_TEMPO' , 'C', 20 , 0},;
                      {'ZPR_GRAUS' , 'C', 20 , 0}} 

    // ZPR - Manuten��o de Arquivo | SX2
    Local aSX2ZPR := {'ZPR', 'Formas de Preparo', 'C', 'C', 'C'}

    // ZPR - Manuten��o de Campos | SX3
    Local aSX3ZPR := {{'ZPR_FILIAL', '', '02' , '0', 'C', 'Filial'      , 'Filial do Sistema'    , '@!', '1', '', '', '', ''   , '' , '' , 'N', '' , '' , '', '', '1'},;
                      {'ZPR_CODPRO', '', '15' , '0', 'C', 'C�d. Produto', 'C�digo do produto'    , '@!', '0', '', '', '', 'SB1', 'V', 'R', 'N', '�', '' , '', '', '1'},;
                      {'ZPR_FORMA' , '', '200', '0', 'C', 'Preparo'     , 'Descri��o do preparo' , '@!', '0', '', '', '', ''   , 'A', 'R', 'N', '�', 'FORNO COMBINADO;FORNO MICRO-ONDAS;FOG�O;FERMENTAR;FRITAR;ASSAR;', '', '', ''},;
                      {'ZPR_TEMPO' , '', '20' , '0', 'C', 'Tempo'       , 'Tempo de preparo'     , '@!', '0', '', '', '', ''   , 'A', 'R', 'N', '�', '' , '', '', '1'},;
                      {'ZPR_GRAUS' , '', '20' , '0', 'C', 'Temperatura' , 'Temperatura adequada' , '@!', '0', '', '', '', ''   , 'A', 'R', 'N', '�', '' , '', '', '1'}}

    // ZPR - �ndices dos Arquivos | SIX 
    Local aSIXZPR := {{'ZPR', '1', 'ZPR_FILIAL+ZPR_CODPRO', 'C�d. Produto', 'U', '', 'N'}}

    // ALIAS | TOPCONN | SX2 | SX3 | SIX | SXA 
    Local aTabelas := {{'ZFT', aTabZFT, aSX2ZFT, aSX3ZFT, aSIXZFT},; // ZFT - Ficha T�cnica
                       {'ZIN', aTabZIN, aSX2ZIN, aSX3ZIN, aSIXZIN},; // ZIN - Informa��es Nutricionais
                       {'ZPR', aTabZPR, aSX2ZPR, aSX3ZPR, aSIXZPR}}  // ZPR - Formas de Preparo

Return aTabelas
