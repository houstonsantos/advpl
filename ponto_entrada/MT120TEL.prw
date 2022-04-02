#include "protheus.ch"


User Function MT120TEL()

    Local aArea := GetArea()                // Recupera a �rea
    Local nOpcx := PARAMIXB[4]              // Recupera o tipo de opera��o nOpc (3 = 'Inclus�o', 4 = 'Altera��o', '5' = Exclus�o)
    Local lEdit := IIF(nOpcx == 3 .Or.;     // Continua na linha de baixo...
    nOpcx == 4 .Or. nOpcx ==  9, .T., .F.)  // Somente ser� edit�vel, na Inclus�o, Altera��o e C�pia
    Local oDlg := PARAMIXB[1]               // Recupera o objeto referente a tela do formul�rio, vindo do PE
    Local aPosGet := PARAMIXB[2]            // Recipera o posicionamento dos elementos existentes.
    Local nRecPC := PARAMIXB[5]             // Recupera o R_E_C_N_O_
    Local aOpc := { "N�o", "Sim" }          // Alimenta o array de op��es do combobox.
    Local oXEmgAux := Nil                   // Obj de refer�ncia para guardar a inst�ncia do comboBox "Emergencial?"
    Local nSayPosX := 062                   // Posicionamento da label "Emergencial?" na vertical 
    Local nComPosX := 060                   // Posicionamento do combobox "Emergencial?" na vertical
    Local nSayPosY := aPosGet[01,08] -12    // Posicionamento da label "Emergencial?" na horizontal
    Local nComPosY := aPosGet[01,08] +50    // Posicionamento do combobox "Emergencial?" na horizontal

    Public cXEmgAux := ""

    //Define o conte�do para os campos
    SC1->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXEmgAux := CriaVar("C1_XEMERGE",.F.)
    Else
        cXEmgAux := IIf(Upper(SC1->C1_XEMERGE) == "S", "Sim", "N�o")
    EndIf

    //Adicionando o campo de emergencial? no formul�rio oDlg
    @ nSayPosX, nSayPosY SAY Alltrim(RetTitle("C1_XEMERGE")) OF oDlg PIXEL SIZE 050, 009
    @ nComPosX, nComPosY MSCOMBOBOX oXEmgAux VAR cXEmgAux ITEMS aOpc SIZE 035, 013 OF oDlg PIXEL COLORS 0, 16777215

    // Adiciona o helper para o campo customizado
    oXEmgAux:bHelp := {|| ShowHelpCpo( "C1_XEMERGE", {GetHlpSoluc("C1_XEMERGE")[1]}, 5  )}
 
    //Se n�o houver edi��o, desabilita os gets
    If !lEdit
        oXEmgAux:lActive := .F.
    EndIf
 
    RestArea(aArea)

Return Nil
