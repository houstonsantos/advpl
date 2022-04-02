#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} BlokFin
    (Rotina destinada ao bloqueio de lançamentos financeiros. SIGAFIN - Atualizaçõeses/Gestão Financeira/Fechamento Financeiro)
    @type Class
    @author Houston Santos
    @since 29/03/2019
    @version 1
    @return none
    @see (links_or_references)
/*/

Class BlokFin 
	
	Data cDataFim
	Data cBaixFim
	Data cMvCodUs
	Data cCodUser
	
	Method New() Constructor 
	Method Blok()

EndClass


/*/{Protheus.doc} BlokFin
    (Metodo Construtor)
    @type Method
    @author Houston Santos
    @since 29/03/2019
    @version 1
    @param none
    @return Self
    @see (links_or_references)
/*/

Method New() Class BlokFin

	::cDataFim := GetMv("MV_DATAFIN")
	::cBaixFim := GetMv("MV_BXDTFIN")
	::cMvCodUs := GetMv("MV_BLOKFIN")
	::cCodUser := RetCodUsr()

Return Self


/*/{Protheus.doc} Blok
    (Metodo Blok)
    @type Method
    @author Houston Santos
    @since 29/03/2019
    @version 1
    @param cDataFim, cBaixFim
    @return none
    @see (links_or_references)
/*/

Method Blok(cDataFim, cBaixFim) Class BlokFin
	
	Local cTitulo := "Bloqueio de Movimento Financeiro"
	Local aItems:= {"1 = Permite","2 = Não Permite"}
	Local nCombo  := Val(cBaixFim)
	Local lHasButton := .T.
	Local dGet := cDataFim
	
	// Tela onde será informado a data para fechamento financeiro.
	oDlg := MSDialog():New(10,10,230,470,cTitulo,,,,,,,,,.T.)

	oTSay := TSay():New(22,10,{||'Movimentos bloqueados anteriores a:'    },oDlg,,,,,,.T.,,,100,20)	
	oTGet := TGet():New(020,150,{|u|If(PCount() > 0,dGet := u,dGet)},oDlg,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dGet",,,,lHasButton)
	
	oTSay := TSay():New(41,10,{||'Baixas P/R anteriores a data do bloqueio?'    },oDlg,,,,,,.T.,,,100,20)
	oComb := TComboBox():New(038,150,{|u|if(PCount() > 0,nCombo := u,nCombo)},aItems,060,15,oDlg,,{||},,,,.T.,,,,,,,,,'nCombo')

	oBtn1 := TBtnBmp2():New(150,340,50,50,'OK',,,,{||PutMv("MV_DATAFIN",dGet) .And. PutMv("MV_BXDTFIN",nCombo), oDlg:End()},oDlg,,,.T.)
	oBtn2 := TBtnBmp2():New(150,390,50,50,'Cancel',,,,{||Alert("Operação cancelada!"), oDlg:End()},oDlg,,,.T.)

	oDlg:Activate(,,,.T.,{||},,)
	
Return


/*/{Protheus.doc} Blofin
    (Metodo Blok)
    @type Function
    @author Houston Santos
    @since 01/04/2019
    @version 1
    @param none
    @return none
    @see (links_or_references)
/*/

User Function Blofin()
	
	Local oBloqueio := BlokFin():New()
	
	// Verifica se o usuário e o administrador do sistema estão autorizados. 
	If  ! AllTrim(oBloqueio:cCodUser) $ oBloqueio:cMvCodUs 
		Alert("Somente o administrador ou usuários autorizados podem executar esta rotina.")
		Return
	Else
		oBloqueio:Blok(oBloqueio:cDataFim, oBloqueio:cBaixFim)
	EndIf
	
Return
