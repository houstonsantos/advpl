#include 'protheus.ch'


/*/{Protheus.doc} MT103SE2
    (Ponto de entrada para adicionar ao aCols do titulo SE2, este ponto deve ser usando em conjunto com MT100GE2)
    @type  Function
    @author Houston Santos
    @since 12/07/2019
    @version version
    @return array
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6085675)
/*/

User Function MT103SE2()

    Local aRet := {}
    // Adicinando o campo E2_CCD ao aCols.
    If  MsSeek("E2_CCD")   
        aadd(aRet, GetSx3('E2_CCD'))
    EndIf

    // Adicinando o campo E2_CODBAR ao aCols.
    If  MsSeek("E2_CODBAR")
        aadd(aRet, GetSx3('E2_CODBAR'))
    EndIf

Return (aRet)

/*/{Protheus.doc} GetSx3
    (Retorna o array com a estrutura dos campos E2_CCD e E2_CODBAR definidos na SX3)
    @type Static Function
    @author Houston Santos
    @since 06/11/2019
    @version version
    @param cField
    @return array
    @example
/*/

Static Function GetSx3(cField)

    Local Ix := 0  // Utilizada para controle de posicionamento na iteração da expressão 'FOR'
    Local aRet := {}
    Local aFieldsSx3 := GetSx3Fields()

    Aadd(aRet, Trim(GetSx3Cache(cField, 'X3_TITULO')))

    For Ix := 1 To Len(aFieldsSx3)
        // Validação de usuário para o campo E2_CCD
        Iif(aFieldsSx3[Ix] == "X3_VLDUSER", Aadd(aRet, IIF(cField == "E2_CCD", "Ctb105CC() .And. A103VldCC()", "")), Aadd(aRet, GetSx3Cache(cField, aFieldsSx3[Ix])))
    Next

    Aadd(aRet, ".T.")

Return aRet


/*/{Protheus.doc} GetSx3Fields
    (Auxilia o método GetSx3 com as colunas da SX3 que vão ser retornadas para o array.)
    @type Static Function
    @author Houston Santos
    @since 06/11/2019
    @version version
    @param none
    @return array
/*/

Static Function GetSx3Fields()

    Local aRet := {}

    Aadd(aRet, 'X3_CAMPO')
    Aadd(aRet, 'X3_PICTURE')
    Aadd(aRet, 'X3_TAMANHO')
    Aadd(aRet, 'X3_DECIMAL')
    Aadd(aRet, 'X3_VLDUSER')
    Aadd(aRet, 'X3_USADO')
    Aadd(aRet, 'X3_TIPO')
    Aadd(aRet, 'X3_F3')
    Aadd(aRet, 'X3_CONTEXT')
    Aadd(aRet, 'X3_CBOX')
    Aadd(aRet, 'X3_RELACAO')

Return aRet
