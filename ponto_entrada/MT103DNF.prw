#include "protheus.ch"


/*/{Protheus.doc} MT103DNF
    (Ponto de entrada responsável por validar as informações da aba "Informações DANFE"
    da rotina MATA103 - Documentos de Entrada)
    @type User
    @author Houston Santos
    @since 20/05/2020
    @version 1
    @return lRet (lógico)
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=6085666)
/*/

User Function MT103DNF()

    Local lRet := .T.
    Local cEsp := AllTrim(CESPECIE)
    Local cChvNFE := AllTrim(aNFEDanfe[13])

    If (cEsp == "SPED" .And. (Empty(cChvNFE) .Or. Len(cChvNFE) != 44 .Or. !IsNumeric(cChvNFE) .Or. !ValidarDv(cChvNFE)))
        lRet := .F.
        MsgInfo("O Campo CHAVE NFE não foi informado ou está incorreto.", "Alerta")
    EndIf

Return lRet


/*/{Protheus.doc} ValidarDv
    (Função que auxilia o ponto de entrada para validar se 
    o digito verificador está correto.)
    @type Static
    @author Houston Santos
    @since 20/05/2020
    @version 1
    @param cChvNFE (caractere)
    @return lRet (lógico)
    @see 
/*/

Static Function ValidarDv(cChvNFE)

    Local lRet := .F.
    Local nPos := 43
    Local nMultpl := 2
    Local nSoma := 0
    Local aChvNFE := StrToArr(cChvNFE)
    Local nDv := Val(IIf(Len(cChvNFE) == 44, aChvNFE[44], "0"))

    While nPos > 0
        nMultpl := IIf(nMultpl > 9, 2, nMultpl)
        nSoma += Val(aChvNFE[nPos]) * nMultpl
        nMultpl++
        nPos--
    EndDo

    lRet := IIf(nDv == 0, Mod(nSoma, 11)  == 0 .Or. Mod(nSoma, 11)  == 1, 11 - Mod(nSoma, 11)  == nDv)

Return lRet


/*/{Protheus.doc} IsNumeric
    (Função que auxilia na verificação do preenchimento da CHAVE NFE
    valida se todos os caracteres digitados são numéricos)
    @type Static
    @author Houston Santos
    @since 20/05/2020
    @version 1
    @param cParam (caractere)
    @return lRet (lógico)
    @see 
/*/

Static Function IsNumeric(cParam)

    Local lRet := .T.
    Local aParam := StrToArr(cParam)
    Local nPos := 1

    For nPos := 1 To Len(aParam)
        If(!IsDigit(aParam[nPos]))
            lRet := .F.
        EndIf
    Next

Return lRet 


/*/{Protheus.doc} StrToArr
    (Função que auxilia na transformação de uma string em array sem delimitadores.)
    @type Static
    @author Houston Santos
    @since 20/05/2020
    @version 1
    @param cParam (caractere)
    @return aRet (array)
    @see 
/*/

Static Function StrToArr(cParam)

    Local aRet := {}
    Local nPos := 1

    For nPos := 1 To Len(cParam)
        AAdd(aRet, SubStr(cParam, nPos, 1))
    Next

Return aRet
