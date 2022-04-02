#include "rwmake.ch"
#include "protheus.ch"


/*/{Protheus.doc} FA560BRW
    (Permite adicionar botões ao array na tela de movimentações do caixinha FINA560,nossa implementação está adicionando 
    um botão com a chamada para a tela de conhecimento não foi necessária a adição da chave da rotina no PE FTMSREL pois já existe...)
    @type  Function
    @author Houston Santos
    @since 28/09/2020
    @version 1
    @return return
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=167313546)
/*/

User Function FA560BRW()

    Local aButtons := ParamIxb[1]
    Aadd(aButtons, {"Conhecimento", "U_Conhecimento('SEU', 'FINA560', 4)", 0, 4, 0, Nil})   

Return aButtons
