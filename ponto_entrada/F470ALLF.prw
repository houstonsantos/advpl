#include 'protheus.ch'


/*/{Protheus.doc} F470ALLF
    (Permite vizualizar extrato banc�rio de forma consolidada para usu�rios 
    que n�o tenham permiss�o nas empresas e que tenham o saldo compartilhado SE8)
    @type Function
    @author Houston Santos
    @since 01/07/2019
    @version version
    @return return
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6071573)
/*/

User Function F470ALLF()

    Local lAllFil := ParamIxb[1]

Return(.T.)
