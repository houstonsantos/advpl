#include "protheus.ch"
#include "topconn.ch"
#define nPos 0                 // Contador para o For...
#define CTRF Chr(13) + Chr(10) // Quebra de linha da string


User Function MT110TOK()

    Local lRet := .F. // Retorno
    Local aCompr := {}  // Armazena os compradores dos grupos relacionados aos produtos selecionados
    Local cComprador := ""
    Local lOutroComp := .F.

    aCompr := U_DataGrdSC() // Fun��o armazenada no font GRIDSCAUD.prw | Carrega os compradores respectivos aos grupos de produto
    
    If Len(aCompr) > 1
        MsgInfo("Os grupos dos produtos selecionados n�o combinam com a atua��o de apenas 1 comprador." + CTRF + ;
        "Voc� deve dividir a sua solicita��o.", "Alerta")
    ElseIf(Len(aCompr) == 1 )
        cComprador := aCompr[1][1]
        lRet := .T.
    Else

        Private lConfirm := .F.
        Private aParams  := {}
        aAdd(aParams, { 1, "Comprador", Space(3), "@!", "(!Vazio() .And. EXISTCPO('SY1', MV_PAR01,1))", "SBMSY1", "", 3, .T. })

        If (!Empty(CCODCOMPR) .And. ALTERA)
            lOutroComp := MsgYesNo("Deseja selecionar um comprador diferente?", "Aten��o")
            lConfirm   := !lOutroComp
        EndIf

        While !lConfirm
        
            MV_PAR01 := "   "
            If ParamBox(aParams,"Selecione o comprador")
                If !Empty(MV_PAR01)
                    cComprador := MV_PAR01
                    lConfirm := .T.
                    lRet := .T.
                EndIf
            Else
                lConfirm := IIf(Aviso("Aten��o",;
                "N�o � permitida a cria��o de SC sem comprador associado" + CTRF +;
                "Voc� deve selecionar um comprador.", {"Selecionar", "Fechar"}, 1) == 2, .T., .F.)
            EndIf
        End
        
    EndIf

    CCODCOMPR := IIf(!Empty(CCODCOMPR) .And. ALTERA, IIf(!lOutroComp, CCODCOMPR, cComprador), cComprador)

Return lRet
