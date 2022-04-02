#include "protheus.ch"
#define CTRF Chr(13) + Chr(10) 


/*/{Protheus.doc} SetCtNat
    (Definindo a conta contábil do lançamento de acordo com ED_CONTA)
    @type Function
    @author Houston Santos
    @since 02/09/2019
    @version 1
    @param none
    @return cContaContabil
    @see (links_or_references)
/*/

User Function SetCtNat()
    
    Local aArea := GetArea()
    Local cContaContabil := NIL
    Local cFornece := SF1->F1_FORNECE
    Local cDoc := SF1->F1_DOC

    // Executando query buscando natureza do título.
    BeginSql Alias "SQL_SE2"   
        SELECT 
            E2_NATUREZ
        FROM 
            %table:SE2% SE2 
        WHERE 
            E2_FILIAL = %xFilial:SE2%
            AND SE2.E2_NUM = %exp:cDoc% AND SE2.E2_FORNECE = %exp:cFornece% 
            AND SE2.D_E_L_E_T_ <> "*"
    EndSql

    // Abrindo área SED.
    DbSelectArea("SED")
    SED->(DbGoTop())
    
    // Verificando se há natureza de acordo com a query acima.
    If DBSeek(xFilial("SED") + AllTrim(SQL_SE2->E2_NATUREZ))
        // Recupera conta contábil da natureza
		cContaContabil := ED_CONTA
    EndIf
    
    // Fecha área.
    SQL_SE2->(DbCloseArea())
    RestArea(aArea)

Return cContaContabil


/*/{Protheus.doc} ntaf2
    (Definindo a conta contábil com base na natureza para o contas a receber)
    @type Function
    @author Houston Santos
    @since 08/07/2020
    @version 1
    @param 
    @return aContNat
    @see (links_or_references)
/*/

User Function ContNat(cMod)

    Local cNomNat
    Local cNaturez
    Local cContNat
    Local aArea := GetArea()
     
    // Abrindo área SED.
    //DbSelectArea("SED")
    //SED->(DbGoTop())

    Do Case
		Case cMod == "F"
			cNaturez := Posicione("SC5", 1, xFilial("SD2") + SD2->D2_PEDIDO, "C5_NATUREZ")
			cContNat := Posicione("SED", 1, xFilial("SED") + cNaturez, "ED_CONTA")

            If Empty(cContNat)
                cNomNat := Posicione("SED", 1, xFilial("SED") + cNaturez, "ED_DESCRIC")
                MsgInfo('Conta contabil não informanda para natureza' + CTRF + cNaturez + ' - ' + cNomNat, 'Atenção')
            EndIf

		Case cMod == "C"
            cNaturez := Posicione("SE2", 1, xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC, "E2_NATUREZ")
            cContNat := Posicione("SED", 1, xFilial("SED") + SA2->A2_NATUREZ, "ED_CONTA")

            If Empty(cContNat)
                cContNat := Posicione("SED", 1, xFilial("SED") + cNaturez, "ED_CONTA")
            ElseIf Empty(cContNat)
                cNomNat := Posicione("SED", 1, xFilial("SED") + cNaturez, "ED_DESCRIC")
                MsgInfo('Conta contabil não informanda para natureza' + CTRF + cNaturez + ' - ' + cNomNat, 'Atenção')
            EndIf

		OtherWise
			Alert("Empresa não encontrada!")
	EndCase

    // Fecha área.
    //SED->(DbCloseArea())
    RestArea(aArea)

Return cContNat


/*/{Protheus.doc} CtPorEmp
    (Captura o vetor de contas e retorna a conta contabil de acordo com LP em parametro, empresa selecionada e filial em processamento)
    @type Function
    @author Houston Santos
    @since 03/09/2019
    @version 1
    @param cLPNome (EXP => "650_004")
    @return cContaCtbl
    @see (links_or_references)
/*/

User Function CtPorEmp(cLPNome)

    Local aArea := GetArea()
    Local aGrpEmp := u_GetMatLp()
    Local iCodEmp := Val(FWCodEmp())
    Local iCodFilial := Val(FWxFilial()) + 1
    Local cContaCtbl := ""

    // Captura a conta contabil de acordo com a empresa, filial e LP. Regra de captura seguindo a lógica em que a matriz foi estruturada.
    cContaCtbl := aGrpEmp[iCodEmp][iCodFilial][AScan(aGrpEmp[iCodEmp][iCodFilial], {|x|AllTrim(x[1]) == AllTrim(cLPNome)})][2]

    RestArea(aArea)

Return cContaCtbl


/*/{Protheus.doc} GetMatLp
    (Função alimenta o vetor de grupos de empresas. a regra das contas por empresa, filial e LP ficará neste método)
    @type Function
    @author Houston Santos
    @since 03/09/2019
    @version 1
    @param none
    @return aGrpEmp
    @see (links_or_references)
/*/

User Function GetMatLp()

    // Cada posição deste vetor armazena um grupo de empresa... 
    // Lembrando de sempre seguir a ordenação definida no protheus. 
    // EX: ÍNDICE 01 -> SUAPE, ÍNDICE 02 -> MCP...
    Local aGrpEmp := {}

    // Cada matriz faz referência a um grupo de empresas.
    Local aLanPadSuape := {}
    Local aLanPadMCP := {}
    Local aLanPadFast := {}
    Local aLanPadJSA := {}
    Local aLanPadGPS := {}
    Local aLanPadGSP := {}
    
    //  Matriz de regras por empresas adicionadas ao array aGrpEmp seu índice de acordo com o código da empresa
    //  definido uma estrutura tridimensional para esta matriz, qualquer mudança de estrutura implicara no funcionamento do programa
    
    //  Regra para SUAPE LP e conta por filial em linha.
    aLanPadSuape := { /*FILIAL 00*/ {{"650_001", "1106010001"}, {"660_003", "1103010007"}},;
                      /*FILIAL 01*/ {{"650_001", "1106010008"}, {"660_003", "1103010014"}},;
                      /*FILIAL 02*/ {{"650_001", "1106010009"}, {"660_003", "1103010015"}},;
                      /*FILIAL 03*/ {{"650_001", "1106010012"}, {"660_003", "1103010017"}},;
                      /*FILIAL 04*/ {{"650_001", "1106010014"}, {"660_003", "1103010019"}},;
                      /*FILIAL 05*/ {{"650_001", "1106010016"}, {"660_003", "1103010020"}}}

    //  Regra para MCP LP e conta por filial em linha.
    aLanPadMCP :=   { /*FILIAL 00*/ {{"610_011", "4101010002"}, {"610_023", "2104010005"}},;
                      /*FILIAL 01*/ {{"610_011", "4101010001"}, {"610_023", "2104010004"}},;
                      /*FILIAL 02*/ {{"610_011", "4101010003"}, {"610_023", "2104010008"}},;
                      /*FILIAL 03*/ {{"610_011", "4101010005"}, {"610_023", "2104010009"}},;
                      /*FILIAL 04*/ {{"610_011", "4101010006"}, {"610_023", "2104010009"}}}

    // Aqui deverá conter o restante dos LP's por empresa abedecendo o mesmo formato da matriz acima.
    //...\/

    // [INDEX 01] - SUAPE
    aAdd(aGrpEmp, aLanPadSuape)
    // [INDEX 02] - MCP   
    aAdd(aGrpEmp, aLanPadMCP)
    // [INDEX 03] - FAST  
    aAdd(aGrpEmp, aLanPadFast)
    // [INDEX 04] - JSA   
    aAdd(aGrpEmp, aLanPadJSA)
    // [INDEX 05] - GPS
    aAdd(aGrpEmp, aLanPadGPS)
    // [INDEX 06] - GSP
    aAdd(aGrpEmp, aLanPadGSP)

Return aGrpEmp
