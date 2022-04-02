#include 'protheus.ch'


/*/{Protheus.doc} FTMSREL
    (Permite adicionar chaves para incluir na chamada a fun��o MsDocument que abre uma tela de conhecimento.
    Com isso, � poss�vel adicionar a funcionalidade de conhecimento para uma customiza��o propriet�ria)
    @type User Function
    @author Houston Santos
    @since 22/04/2020
    @version 1
    @param none
    @return Array
    @see (https://tdn.totvs.com/display/public/PROT/FTMSREL)
/*/

User Function FTMSREL()
 
    Local aRet := {}
    AAdd(aRet, {"ZPS", {"ZPS_FILIAL", "ZPS_CODIGO"}, {||ZPS->ZPS_CODIGO + ZPS->ZPS_NOME}})

Return aRet
