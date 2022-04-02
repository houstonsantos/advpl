#include "Protheus.ch"
 
/*-----------------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT110GRV                                                                                                      |
 | Desc:  Ponto de Entrada para gravar informa��es na solicita��o de compra para cada item (usado junto com MT110TEL)   |
 | Link:  https://tdn.totvs.com/display/public/PROT/MT110GRV                                                            |
 *---------------------------------------------------------------------------------------------------------------------*/

User Function MT110GRV ()

    Local aArea := GetArea()
    //Atualiza a descri��o, com a vari�vel p�blica criada no ponto de entrada MT110TEL
    SC1->C1_XEMERGE := IIf(Upper(cXEmgAux) == "SIM", "S", "N") 
    RestArea(aArea)

Return Nil
