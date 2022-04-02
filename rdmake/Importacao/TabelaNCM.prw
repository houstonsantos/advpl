#include "rwmake.ch"     
#include "protheus.ch"
#include "topconn.ch"
#define CTRF   CHR ( 13 ) + CHR ( 10 )
#define aCabec  { "Sim", "Não" }
#define STR0001 "Importacao de arquivo CSV. Tabela SYD (NCM)."
#define STR0002 "Parametrizacao utilizada:"
#define STR0003 "Local do arquivo: "
#define STR0004 "Ocorreu um erro durante a importação do arquivo CSV."

User Function CSV_NCM

    Local cErrorDesc := ""
    Local cErrorStack := ""
    Local cError := STR0004
    Local oLastError := ErrorBlock({|e| cErrorDesc := e:Description, cErrorStack := e:ErrorStack})
    Local aSays := {}
    Local aButtons := {}
    Local lRet := {}
    Local nOpcA := 0

    RpcSetEnv('06')

    Private cCadastro := OemToAnsi(STR0001) // "Importação de arquivo CSV. Tabela SYD (NCM)."
    Private aArea := GetArea()

    aAdd(aSays, OemToAnsi("Esta rotina foi criada para a importacao de arquivos CSV"))
    aAdd(aSays, OemToAnsi("realizando um merge na tabela de NCM - SYD de acordo."))
    aAdd(aSays, OemToAnsi("com o que foi enviado. "))
    aAdd(aSays, OemToAnsi("Sera necessario a selecao de um arquivo CSV com o caracter delimitador ; (ponto e virgula)"))
    aAdd(aSays, OemToAnsi("que determinara o ponto de parada de cada celula."))

    aAdd(aButtons, { 5 ,.T.,{||  IIf(ParamBox(fGetParamBox(),"Selecione o arquivo CSV",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.T.), Nil, Nil) } } )
    aAdd(aButtons, { 1 ,.T.,{|o| nOpcA := 1,IF( fConfirm(),FechaBatch(),nOpcA:=0) }} )
    aAdd(aButtons, { 2 ,.T., {|| FechaBatch()}})
    
    FormBatch( cCadastro, aSays, aButtons )

    If nOpcA == 1
        Processa({|lEnd| lRet := fFileImport(AllTrim(MV_PAR01), IIf(ValType(MV_PAR02) == 'N', aCabec[MV_PAR02], MV_PAR02)), cCadastro })
    EndIf

    If lRet == .T.
        MsgInfo("Importação do arquivo concluída com sucesso.", "Atenção")
    EndIf

    RestArea( aArea )

    RpcClearEnv()

Return Nil


Static Function fFileImport(cArq, cTemCab)

    Local lRet := .T.
    Local cLinha := ""
    Local lPrim := .T.
    Local aCampos := {}
    Local aDados := {}
    
    FT_FUSE(cArq)
    ProcRegua(FT_FLASTREC())
    FT_FGOTOP()
    
    While !FT_FEOF()
        cLinha := FT_FREADLN()
    
        If lPrim
            aCampos := Separa(cLinha,";",.T.)
            lPrim := .F.
        Else
            AADD(aDados,Separa(cLinha,";",.T.))
        EndIf
    
        FT_FSKIP()
    EndDo

Return lRet



Static Function fGetParamBox()

    Local aParamBox := {}
    aAdd(aParamBox,{6, "Buscar por arq CSV", Space(50), "", "", "", 50, .F., "Todos os arquivos (*.CSV) |*.CSV"})
    aAdd(aParamBox,{3, "Minha planilha tem cabeçalho", 1, aCabec, 50, "", .F.})

Return aParamBox


Static Function fConfirm()

	Local lRet := .T.
	Local cMsgYesNo	:= ""
	Local cTitLog := ""

		cMsgYesNo := OemToAnsi(;
									"Esta rotina realiza a manipulação e inclusão de registros na tabela SYD - (NCM)" + CTRF +;
									"Você tem certeza que deseja executar esta ação?" ;
								)
		cTitLog	:= OemToAnsi( "Atenção" )	// Atencao!"
		lRet :=  MsgYesNo( OemToAnsi( cMsgYesNo ) ,  OemToAnsi( cTitLog ) ) 
	
Return( lRet )
