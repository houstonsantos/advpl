//Bibliotecas
#include "Protheus.ch"
  

/*--------------------------------------------------------------------------------------------------------------*
| P.E.:  MT110TEL                                                                                              |
| Desc:  Ponto de Entrada para adicionar campos no cabeçalho da solicitação de compras                         |
| Link:  http://tdn.totvs.com/display/public/mp/MT110TEL                                                       |
*--------------------------------------------------------------------------------------------------------------*/

User Function MT110TEL()

    Local aArea     := GetArea()            // Recupera a área
    Local nOpcx     := PARAMIXB[3]          // Recupera o tipo de operação nOpc (3 = 'Inclusão', 4 = 'Alteração', '5' = Exclusão)
    Local lEdit     := IIF(nOpcx == 3 .Or.; // Continua na linha de baixo...
    nOpcx == 4 .Or. nOpcx ==  9, .T., .F.)  // Somente será editável, na Inclusão, Alteração e Cópia
    Local oDlg      := PARAMIXB[1]          // Recupera o objeto referente a tela do formulário, vindo do PE
    Local aPosGet   := PARAMIXB[2]          // Recipera o posicionamento dos elementos existentes.
    Local nRecPC    := PARAMIXB[4]          // Recupera o R_E_C_N_O_
    Local aOpc      := { "Não", "Sim" }     // Alimenta o array de opções do combobox.
    Local oXEmgAux  := Nil                  // Obj de referência para guardar a instância do comboBox "Emergencial?"
    Local nSayPosX  := 065                  // Posicionamento da label "Emergencial?" na vertical 
    Local nComPosX  := 063                  // Posicionamento do combobox "Emergencial?" na vertical
    Local nSayPosY  := aPosGet[1,01]        // Posicionamento da label "Emergencial?" na horizontal
    Local nComPosY  := aPosGet[1,02]        // Posicionamento do combobox "Emergencial?" na horizontal

    Public cXEmgAux := ""

    //Define o conteúdo para os campos
    SC1->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXEmgAux := CriaVar("C1_XEMERGE",.F.)
    Else
        cXEmgAux := IIf(Upper(SC1->C1_XEMERGE) == "S", "Sim", "Não")
    EndIf

    //Adicionando o campo de emergencial? no formulário oDlg
    @ nSayPosX, nSayPosY SAY Alltrim(RetTitle("C1_XEMERGE")) OF oDlg PIXEL SIZE 050, 009
    @ nComPosX, nComPosY MSCOMBOBOX oXEmgAux VAR cXEmgAux ITEMS aOpc SIZE 035, 013 OF oDlg PIXEL COLORS 0, 16777215

    // Adiciona o helper para o campo customizado
    oXEmgAux:bHelp := {|| ShowHelpCpo( "C1_XEMERGE", {GetHlpSoluc("C1_XEMERGE")[1]}, 5  )}
 
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXEmgAux:lActive := .F.
    EndIf
 
    RestArea(aArea)

Return
