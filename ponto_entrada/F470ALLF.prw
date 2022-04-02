#include 'protheus.ch'


/*/{Protheus.doc} F470ALLF
    (Permite vizualizar extrato bancário de forma consolidada para usuários 
    que não tenham permissão nas empresas e que tenham o saldo compartilhado SE8)
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
