#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'


/*/{Protheus.doc} CredFin
    (Aglutina valores por centro de custo e integra com o fonte CredFunc.)
    @type Function
    @author Houston Santos
    @since 03/04/2018
    @version 1
    @param aRemessa
    @return lvalida
    @see (links_or_references)
/*/

User Function CredFin(aRemessa)

	Local aCab := {}
	Local aAuxEv := {}
	Local aRatEvEz := {}
	Local aAuxEz := {}
	Local aRatEz := {}
	Local aCc := {}
	Local nValAx := 0
	Local nTitulo := 0
	Local cTit := ""
	Local lvalida := .F.
	Local i
	Local j
	
	Private lMsErroAuto := .F.

	//Aadd(aRemessa, {'GPE','100000001','FOL','410105    ','000023','01',"20180430","20180430",'033001',10})

	aCc := aClone(aRemessa)

	For i := 1 to Len(aRemessa)
		For j := 1 to Len(aCc)
			If (aRemessa[i,8] == aCc[j,8])
				nValAx += aCc[j,9]
				aCc[j,8] := nil
			EndIf
		Next

		If (cValToChar(nValAx) != "0")
			nTitulo := nTitulo++
			cTit := aRemessa[i,2] + "0" + cValtoChar(nTitulo)
		
			Aadd(aCab, {"E2_PREFIXO" , aRemessa[i,1]   , Nil })         
			Aadd(aCab, {"E2_NUM"     , cValtoChar(cTit), Nil }) 
			Aadd(aCab, {"E2_TIPO"    , aRemessa[i,3]   , Nil })
			Aadd(aCab, {"E2_NATUREZ" , aRemessa[i,4]   , Nil }) 
			Aadd(aCab, {"E2_FORNECE" , aRemessa[i,5]   , Nil }) 
			Aadd(aCab, {"E2_LOJA"    , '01'		       , Nil })
			Aadd(aCab, {"E2_EMISSAO" , aRemessa[i,6]   , Nil })
			Aadd(aCab, {"E2_VENCTO"  , aRemessa[i,7]   , Nil })
			Aadd(aCab, {"E2_VALOR"   , nValAx		   , Nil })		  
			Aadd(aCab, {"E2_MULTNAT" , '1'		       , Nil })

			Aadd(aAuxEv, {"EV_NATUREZ" , PadR(aRemessa[i,4], tamsx3("EV_NATUREZ")[1]), Nil})
			Aadd(aAuxEv, {"EV_VALOR"   , nValAx , Nil})	 
			Aadd(aAuxEv, {"EV_PERC"    , "100"  , Nil})
			Aadd(aAuxEv, {"EV_RATEICC" , "1"    , Nil})

			aAuxEz := {}
			Aadd(aAuxEz, {"EZ_CCUSTO" , aRemessa[i,8], Nil})
			Aadd(aAuxEz, {"EZ_VALOR"  , nValAx   	  ,Nil})
			Aadd(aRatEz, aAuxEz)

			Aadd(aAuxEv, {"AUTRATEICC", aRatEz, Nil})
			Aadd(aRatEvEz, aAuxEv)
			Aadd(aCab, {"AUTRATEEV", aRatEvEz, Nil})

			MSExecAuto({|x,y,z|FINA050(x,y,z)}, aCab,,3)

			If (lMsErroAuto)
				MostraErro()
			Else
				lvalida := .T.
			EndIf

			aCab := {}
			aAuxEv := {}
			aRatEvEz := {}
			aAuxEz := {}
			aRatEz := {}
		EndIf
		nValAx := 0
	Next

Return lvalida
