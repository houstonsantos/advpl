#include "rwmake.ch"
#include "protheus.ch"


/*/{Protheus.doc} FA560BRW
    (Permite adicionar bot�es ao array na tela de movimenta��es do caixinha FINA560,nossa implementa��o est� adicionando 
    um bot�o com a chamada para a tela de conhecimento n�o foi necess�ria a adi��o da chave da rotina no PE FTMSREL pois j� existe...)
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
