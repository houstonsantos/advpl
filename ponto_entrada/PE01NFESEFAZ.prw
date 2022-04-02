#include "protheus.ch"
#define MAXMENLIN 088
#define CTRF Chr(13) + Chr(10)


/*/{Protheus.doc} PE01NFESEFAZ
    (Ponto de Entrada para manipulação do xml da nota os campos F2_MENNOTA e C5_MENNOTA devem ficar iguais com tamanho 250)
    @type  Function
    @author Houston Santos, Lailson Santos 
    @since 02/10/2013
    @version version
    @return return
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=274327446 
		  https://tdn.totvs.com/pages/releaseview.action?pageId=238028227)
/*/

User Function PE01NFESEFAZ()

	Local aProd := PARAMIXB[1]
	Local cMensCli := PARAMIXB[2]
	Local cMensFis := PARAMIXB[3]
	Local aDest := PARAMIXB[4] 
	Local aNota := PARAMIXB[5]
	Local aInfoItem	:= PARAMIXB[6]
	Local aDupl := PARAMIXB[7]
	Local aTransp := PARAMIXB[8]
	Local aEntrega := PARAMIXB[9]
	Local aRetirada	:= PARAMIXB[10]
	Local aVeiculo := PARAMIXB[11]
	Local aReboque := PARAMIXB[12]
	Local aNfVincRur := PARAMIXB[13]
	Local aEspVol := PARAMIXB[14]
	Local aNfVinc := PARAMIXB[15]
	Local aRetorno := {}
	Local cMsg := ""
	
	Aadd(aRetorno, aProd)
	Aadd(aRetorno, U_XMLInfAdic(cMensCli, aProd))
	Aadd(aRetorno, cMensFis)
	Aadd(aRetorno, aDest)
	Aadd(aRetorno, aNota)
	Aadd(aRetorno, aInfoItem)
	Aadd(aRetorno, aDupl)
	Aadd(aRetorno, aTransp)
	Aadd(aRetorno, aEntrega)
	Aadd(aRetorno, aRetirada)
	Aadd(aRetorno, aVeiculo)
	Aadd(aRetorno, aReboque)
	Aadd(aRetorno, aNfVincRur)
	Aadd(aRetorno, aEspVol)
	Aadd(aRetorno, aNfVinc)
	
Return aRetorno


/*/{Protheus.doc} PE01NFESEFAZ
    (Manipulação das informações complementares.)
    @type  Function
    @author Alexandre Gomes, Lailson Santos, Houston Santos
    @since 02/10/2013
    @version version
	@param cMensCli, aProd
    @return cMTrans
    @example
    (examples)
    @see (links_or_references)
/*/

User Function XMLInfAdic(cMensCli, aProd)
	
	Local ix := 0 // Utilizada para controle de posicionamento na iteração da expressão 'FOR'
	Local nTotImp := 0
	Local nTotNota := 0
	Local cMTrans := ""

	// Se houver texto.
	If ! Empty(cMensCli)
		// Enquanto o tamnho for maior que o máximo da linha, vai quebrando. 
		While Len(cMensCli) > MAXMENLIN
			cMTrans += Substr(cMensCli, 1, Rat(" ", Substr(cMensCli, 1, MAXMENLIN)) - 1) + CTRF
            cMensCli := Substr(cMensCli, Rat(" ", Substr(cMensCli, 1, MAXMENLIN)), Len(cMensCli))
		EndDo
		
		// Se restou texto, incrementa.
		If (cMensCli) != ""
			cMTrans += cMensCli
		EndIf	
	EndIf

	/*
	For ix := 1 to len(aProd)
	   If AllTrim( aProd[ix][27] ) == "530"
	      // Valor do imposto
	      nValImp := (aProd[ix][10] / 0.82) * 0.18
	      nTotImp += nValImp
	      
	      // Valor dos itens com o TES especifico
	      nTotNota += (aProd[ix][10] / 0.82)
	      
		  If ix == 1
		      cMTrans += SubStr(AllTrim(Str(ix,2)) + "o. ITEM VALOR DISPENSADO R$ " + AllTrim(Transform(nValImp, "@E 999,999,999.99")) + Space(90), 1, 90)
		  Else
		      cMTrans += SubStr(AllTrim(Str(ix,2)) + "o. ITEM VALOR DISPENSADO R$ " + AllTrim(Transform(nValImp, "@E 999,999,999.99")) + Space(90), 1, 90)
		  EndIf     
	   EndIf
	Next
	
	If AllTrim(cMTrans) <> ""
	   cMTrans += " DESCONTO DO ICMS, CONFORME CONVÊNIO DE ICMS N° 73/2004 E DECRETO LEI N° 14876/91 E DECRETO N° 27541/2005, VALOR R$ " + AllTrim(Transform(nTotNota, "@E 999,999,999.99")) + ", DESCONTO DE R$ " + AllTrim(Transform(nTotImp, "@E 999,999,999.99")) + " "
	EndIf 
	*/
	
Return cMTrans
