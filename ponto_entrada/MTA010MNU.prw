#include "protheus.ch"


/*/{Protheus.doc} MTA010MNU
    (Ponto de entrada referente ao momento de montagem do browser de produto SB1|ROTINA: MATA010
    a implementação adiciona mais uma opção de menu com submenu referente a ficha técnica e impressão das etiquetas.)
    @type User Function | PE
    @author Houston Santos
    @since 15/10/2019
    @version version
    @return return
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=370617549)
/*/

User Function MTA010MNU()

    Local FichaTecnica := GetMV("MV_FICHAPR")
    Local aRotinaSub := {}

    If (FichaTecnica)
        AAdd(aRotinaSub, {"Incluir", "U_AbrirFichaTecnica", 0, 3, 0, Nil})
        AAdd(aRotinaSub, {"Alterar", "U_AbrirFichaTecnica", 0, 4, 0, Nil})
        AAdd(aRotina,    {OemToAnsi("Ficha Técnica"), aRotinaSub, 0, 2})
        AAdd(aRotina,    {"Imprimir Etiqueta", "U_EtiqRotina", 0, 2, 0, Nil})
    EndIf

Return Nil
