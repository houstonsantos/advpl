#include "protheus.ch"     
#include "tbiconn.ch" 
#include "fwlibversion.ch"

//-----------------------------------------------------------------------
/*/{Protheus.doc} nfseXMLEnv
Função que monta o XML único de envio para NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	cTipo		Tipo do documento.
@param	dDtEmiss	Data de emissão do documento.
@param	cSerie		Serie do documento.
@param	cNota		Número do documento.
@param	cClieFor	Cliente/Fornecedor do documento.
@param	cLoja		Loja do cliente/fornecedor do documento.
@param	cMotCancela	Motivo do cancelamento do documento.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
user function nfseXMLEnv( cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela,aAIDF )
	
	Local nX        := 0
	Local nW		:= 0
	Local nZ		:= 0
		   	
	Local cString    := ""
	Local cAliasSE1  := "SE1"
	Local cAliasSD2  := "SD2"
	local cCFPS      := ""
	Local cNatOper   := ""
	Local cModFrete  := ""
	Local cScan      := ""
	Local cEspecie   := ""
	Local cMensCli   := ""
	Local cMensFis   := ""
	Local cNFe       := ""
	Local cMV_LJTPNFE:= SuperGetMV("MV_LJTPNFE", ," ")
	Local cMVSUBTRIB := IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), SuperGetMv("MV_SUBTRIB"))
	Local cLJTPNFE	 := ""
	Local cLJPRF	 :=	SuperGetMv("MV_LJPREF", ," ")
	Local cWhere	 := ""
	Local cMunISS	 := ""
	Local cTipoPcc   := "PIS','COF','CSL','CF-','PI-','CS-"
	Local cCodCli 	 := ""
	Local cLojCli 	 := "" 
	Local cDescMunP	 := ""
	local cMunPSIAFI := ""
	local cMunPrest  := ""
	Local cDescrNFSe := ""
	Local cDiscrNFSe := ""
	Local cField     := "" 
	Local cMVBENEFRJ := AllTrim(GetNewPar("MV_BENEFRJ"," ")) 
	Local cF4Agreg	:= ""
	Local cFieldMsg  	:= ""
	Local cTpPessoa	:= ""
	Local cCamSC5		:= SuperGetMV("MV_NFSECOM", .F., "") // Parametro que aponta para o campo do SC5 com a data da competencia
	Local lMvNFSEIR		:= SuperGetMV("MV_NFSEIR", .F., .F.) // Pramentro para buscar o IRRF gravado n SD2 e não considerar apenas o acumulado

	Local aObra		 := &(SuperGetMV("MV_XMLOBRA", ,"{,,,,,,,,,,,,,,}"))
	Local cLogradOb  := "" //Logradouro para Obra
	Local cCompleOb  := "" //Complemento para obra
	Local cNumeroOb  := "" // Numero para Obra
	Local cBairroOb  := "" // Bairro para Obra
	Local cCepOb     := "" // Cep para Obra
	Local cCodMunob  := "" // Cod do Municipio para Obra
	Local cNomMunOb	 := "" // Nome do municipio para Obra
	Local cUfOb		 := "" // UF para Obra
	Local cCodPaisOb := "" // Codigo do Pais para Obra
	Local cNomPaisOb := "" // Nome do Pais para Obra
	Local cNumArtOb  := "" // Numero Art para Obra
	Local cNumCeiOb  := "" // Numero CEI para Obra
	Local cNumProOb  := "" // Numero Projeto para Obra
	Local cNumMatOb  := "" // Numero de Mtricula para Obra
	Local cNumEncap  := "" // NumeroEncapsulamento
	Local cNatPCC		:= GetNewPar("MV_1DUPNAT","SA1->A1_NATUREZ") //-- Natureza considerada para retencao de PIS, COF, CSLL 
	Local cObsDtc	 := "" // Observacao DTC TMS
	Local cFntCtrb	:= ""
	Local cCondPag   := "" // Condição de pagamento E4_COND
	Local cObsDtc	 := "" // Observacao DTC TMS
	local cCST_SFT	 := "" // Codigo CST para ISS (FT_CSTISS)
	local cOrigemSB1 := "" // Codigo Origem do Produto (B1_ORIGEM)
	local cMsgSX5	 := ""
	local cLibVersion := allTrim( FwLibVersion() )
	Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
		
	Local dDateCom 	:= Date()	
		
	Local nRetPis	:= 0
	Local nRetCof	:= 0
	Local nRetCsl	:= 0
	Local nPosI		:= 0
	Local nPosF	    := 0
	Local nAliq	    := 0
	Local nCont		:= 0
	Local nDescon	:= 0
	Local nScan		:= 0
	Local nRetDesc	:= 0
	Local nValTotPrd := 0
	
	Local lQuery    := .F.
	Local lCalSol	:= .F.
	Local lEECFAT	:= SuperGetMv("MV_EECFAT")
	Local lNatOper  := GetNewPar("MV_NFESERV","1") == "1"
	Local lAglutina := AllTrim(GetNewPar("MV_ITEMAGL","N")) == "S"
	Local lNFeDesc  := GetNewPar("MV_NFEDESC",.F.)
	Local lNfsePcc  := GetNewPar("MV_NFSEPCC",.F.)	
	Local lRecIrrf  := .T.
	Local lLJPRF	:= .T.
	Local aNota     := {}
	Local aDupl     := {}
	Local aDest     := {}
	Local aEntrega  := {}
	Local aProd     := {}
	Local aICMS     := {}
	Local aICMSST   := {}
	Local aIPI      := {}
	Local aPIS      := {}
	Local aCOFINS   := {}
	Local aPISST    := {}
	Local aCOFINSST := {}
	Local aISSQN    := {}
	Local aISS      := {}
	Local aCST      := {}
	Local aRetido   := {}
	Local aTransp   := {}
	Local aVeiculo  := {}
	Local aReboque  := {}
	Local aEspVol   := {}
	Local aNfVinc   := {}
	Local aPedido   := {}
	Local aTotal    := {0,0,""}
	Local aOldReg   := {}
	Local aOldReg2  := {}
	Local aMed		:= {}
	Local aArma		:= {}
	Local aveicProd	:= {}
	Local aIEST		:= {}
	Local aDI		:= {}
	Local aAdi		:= {}
	Local aExp		:= {}
	Local aPisAlqZ	:= {}
	Local aCofAlqZ	:= {} 
	Local aDeducao  := {} 
	Local aDeduz	:= {}
	Local aConstr	:= {}
	Local aInterm	:= {}
	Local aRetISS	:= {}
	Local aRetPIS	:= {}
	Local aRetCOF	:= {}
	Local aRetCSL	:= {}
	Local aRetIRR	:= {}
	Local aRetINS	:= {}
	Local aLeiTrp	:= {}
	Local aRetSX5	:= {}
	Local nCamPrcv := TamSx3("D2_PRCVEN")[2]	//casa decimal do campo D2_PRCVEN
	Local nCamQuan := TamSx3("D2_QUANT")[2]	//casa decimal do campo D2_QUANT 
	Local nCamTot  := TamSx3("D2_TOTAL")[2]	//casa decimal do campo D2_TOTAL
	Local lIntegHtl := SuperGetMv("MV_INTHTL",, .F.) //Integracao via Mensagem Unica - Hotelaria
	Local lUsaColab	:= UsaColaboracao("3") //Utiliza Colaboração.
		
	Private aUF     	:= {}         
	Private cMvMsgTrib	:= SuperGetMV("MV_MSGTRIB",,"1")
	Private lDuplLiq	:= SuperGetMV("MV_DUPLLIQ",,.F.)
	Private cMvFntCtrb	:= SuperGetMV("MV_FNTCTRB",," ")
	Private cMvFisCTrb	:= SuperGetMV("MV_FISCTRB",,"1")     
	Private lCrgTrib 	:= GetNewPar("MV_CRGTRIB",.F.)	
	Private lMvEnteTrb	:= SuperGetMV("MV_ENTETRB",,.F.)	// Valor dos tributos por Ente Tributante: Federal, Estadual e Municipal
	Private lMvded		:= SuperGetMV("MV_NFSEDED",,.F.)	// Habilita/Desabilita as Deducoes da NFSE
	Private lMvred		:= SuperGetMV("MV_NFSERED",,.F.)	// Habilita/Desabilita as Reducoes da NFSE
	Private lMvDescInc	:= SuperGetMV("MV_NFSEDIN",,.F. )	// Habilita/Desabilita os Descontos Incondicionados da NFSE
	    
	Private cTpCliente	:= ""
	
	Private nAbatim 	:= 0
	Private nTotalCrg	:= 0
	Private nTotFedCrg	:= 0	// Ente Tributante Federal
	Private nTotEstCrg	:= 0	// Ente Tributante Estadual
	Private nTotMunCrg	:= 0	// Ente Tributante Municipal
	private nCountSF3		:= 0
	
	//DEFAULT cCodMun := PARAMIXB[1]
	DEFAULT cTipo   := PARAMIXB[2]
	DEFAULT cSerie  := PARAMIXB[4]
	DEFAULT cNota   := PARAMIXB[5]
	DEFAULT cClieFor:= PARAMIXB[6]
	DEFAULT cLoja   := PARAMIXB[7]
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³Preenchimento do Array de UF                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	//-----------------------------------------------------------------------------------
	// - Verifica a necessidade de atualizacao de LIB para utilizar o comando FWGetSX5
	//-----------------------------------------------------------------------------------
	if( cLibVersion < "20170511" )
		cMsgSX5 := "Para obter as descrições corretas da tabela SX5, por favor, atualize a LIB." + chr( 13 ) + chr( 10 )
		cMsgSX5 += "Versão atual: " + cLibVersion + chr( 13 ) + chr( 10 )
		cMsgSX5 += "Versão mínima necessária: 20170511"
		
		msgAlert( cMsgSX5,"Necessário atualização de LIB" )
		cMsgSX5 := ""
	EndIf
	
	If cTipo == "1" .And. Empty(cMotCancela)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona NF                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF2")
		dbSetOrder(1)// F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, R_E_C_N_O_, D_E_L_E_T_
		DbGoTop()
		If DbSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)	

			aadd(aNota,IIF(lUsaColab .And. cCodMun == "3526902","NFSL",SF2->F2_SERIE))
			aadd(aNota,IIF(Len(SF2->F2_DOC)==6,"000","")+SF2->F2_DOC)
			aadd(aNota,SF2->F2_EMISSAO)
			aadd(aNota,cTipo)
			aadd(aNota,SF2->F2_TIPO)
			aadd(aNota,"1")
			If SF2->(FieldPos("F2_NFSUBST"))<>0 
				aadd(aNota,IIF(Len(SF2->F2_DOC)==6 .And. !Empty(SF2->F2_NFSUBST),"000","")+SF2->F2_NFSUBST)
			Endif
			If SF2->(FieldPos("F2_SERSUBS"))<>0
				aadd(aNota,SF2->F2_SERSUBS)
			Endif
			aadd(aNota,AllTrim(SF2->F2_HORA) + ":" + SUBSTR(Time(), 7, 2))
			dbSelectArea("SE4")
			dbSetOrder(1)			
			If DbSeek(xFilial("SE4")+SF2->F2_COND)
					aadd(aNota,SE4->E4_DESCRI)
					cCondPag := SE4->E4_COND
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona cliente ou fornecedor                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If !SF2->F2_TIPO $ "DB" 
				If IntTMS()
					DT6->(DbSetOrder(1)) 
					If DT6->(DbSeek(xFilial("DT6")+SF2->(F2_FILIAL+F2_DOC+F2_SERIE)))
						cCodCli := DT6->DT6_CLIDEV
						cLojCli := DT6->DT6_LOJDEV
					Else
						cCodCli := SF2->F2_CLIENTE
						cLojCli := SF2->F2_LOJA
					EndIf
				Else
					cCodCli := SF2->F2_CLIENTE
					cLojCli := SF2->F2_LOJA
				EndIf
			
			    dbSelectArea("SA1")
				dbSetOrder(1)
				DbSeek(xFilial("SA1")+cCodCli+cLojCli)
				
				aadd(aDest,AllTrim(SA1->A1_CGC))
				aadd(aDest,SA1->A1_NOME)
				aadd(aDest,myGetEnd(SA1->A1_END,"SA1")[1])
				aadd(aDest,convType(IIF(myGetEnd(SA1->A1_END,"SA1")[2]<>0,myGetEnd(SA1->A1_END,"SA1")[3],"SN")))
				aadd(aDest,IIF(SA1->(FieldPos("A1_COMPLEM")) > 0 .And. !Empty(SA1->A1_COMPLEM),SA1->A1_COMPLEM,myGetEnd(SA1->A1_END,"SA1")[4]))
				aadd(aDest,SA1->A1_BAIRRO)
				If !Upper(SA1->A1_EST) == "EX"
					aadd(aDest,SA1->A1_COD_MUN)
					aadd(aDest,SA1->A1_MUN)				
				Else
					aadd(aDest,"99999")
					aadd(aDest,"EXTERIOR")
				EndIf
				aadd(aDest,Upper(SA1->A1_EST))
				aadd(aDest,SA1->A1_CEP)
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP"))) 
				aadd(aDest,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
				aadd(aDest,SA1->A1_DDD+SA1->A1_TEL)
				aadd(aDest,vldIE(SA1->A1_INSCR,IIF(SA1->(FIELDPOS("A1_CONTRIB"))>0,SA1->A1_CONTRIB<>"2",.T.)))
				aadd(aDest,SA1->A1_SUFRAMA)
				aadd(aDest,SA1->A1_EMAIL)          
				aadd(aDest,SA1->A1_INSCRM) 
				aadd(aDest,SA1->A1_CODSIAF)
				aadd(aDest,SA1->A1_NATUREZ)            
				aadd(aDest,Iif(!Empty(SA1->A1_SIMPNAC),SA1->A1_SIMPNAC,"2"))
				aadd(aDest,Iif(SA1->(FieldPos("A1_INCULT"))> 0 , Iif(!Empty(SA1->A1_INCULT),SA1->A1_INCULT,"2"), "2"))
				aadd(aDest,SA1->A1_TPESSOA)
				aadd(aDest,SF2->F2_DOC)
				aadd(aDest,SF2->F2_SERIE)
				aadd(aDest,Iif(SA1->(FieldPos("A1_OUTRMUN"))> 0 ,SA1->A1_OUTRMUN,""))	//25							
				aadd(aDest,Iif(SA1->(FieldPos("A1_PFISICA"))> 0 ,SA1->A1_PFISICA,""))	//26
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona Natureza                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				//Para uso no Turismo é necessário verificar se a nota foi gerada por pedido ou pelo módulo de turismo antes de definir a natureza.
				If SuperGetMV("MV_INTTUR",,.F.)
					aAreaAux := GetArea()
					
					dbSelectArea("SD2")
					dbSetOrder(3)
					dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
					
					dbSelectArea("SC5")
					dbSetOrder(1)
					If !(dbSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO))
						cNatBusc := GetTitNat(cNota, cSerie, cClieFor, cLoja)
					Else
						cNatBusc := NatPCC ( aDest , cNatPCC )
					EndIf
					RestArea(aAreaAux)
				Else
					cNatBusc := NatPCC ( aDest , cNatPCC )
				EndIf
				DbSelectArea("SED")
				DbSetOrder(1)
				DbSeek(xFilial("SED")+ cNatBusc )  			
				
				If SF2->(FieldPos("F2_CLIENT"))<>0 .And. !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT) .And. SF2->F2_CLIENT+SF2->F2_LOJENT<>SF2->F2_CLIENTE+SF2->F2_LOJA
				    dbSelectArea("SA1")
					dbSetOrder(1)
					DbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)
					
					aadd(aEntrega,SA1->A1_CGC)
					aadd(aEntrega,myGetEnd(SA1->A1_END,"SA1")[1])
					aadd(aEntrega,convType(IIF(myGetEnd(SA1->A1_END,"SA1")[2]<>0,myGetEnd(SA1->A1_END,"SA1")[3],"SN")))
					aadd(aEntrega,myGetEnd(SA1->A1_END,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRRO)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUN)
					aadd(aEntrega,Upper(SA1->A1_EST))
					
				EndIf
						
			Else
			    dbSelectArea("SA2")
				dbSetOrder(1)
				DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)	
		
				aadd(aDest,AllTrim(SA2->A2_CGC))
				aadd(aDest,SA2->A2_NOME)
				aadd(aDest,myGetEnd(SA2->A2_END,"SA2")[1])
				aadd(aDest,convType(IIF(myGetEnd(SA2->A2_END,"SA2")[2]<>0,myGetEnd(SA2->A2_END,"SA2")[3],"SN")))
				aadd(aDest,IIF(SA2->(FieldPos("A2_COMPLEM")) > 0 .And. !Empty(SA2->A2_COMPLEM),SA2->A2_COMPLEM,myGetEnd(SA2->A2_END,"SA2")[4]))				
				aadd(aDest,SA2->A2_BAIRRO)
				If !Upper(SA2->A2_EST) == "EX"
					aadd(aDest,SA2->A2_COD_MUN)
					aadd(aDest,SA2->A2_MUN)				
				Else
					aadd(aDest,"99999")
					aadd(aDest,"EXTERIOR")
				EndIf			
				aadd(aDest,Upper(SA2->A2_EST))
				aadd(aDest,SA2->A2_CEP)
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_SISEXP")))
				aadd(aDest,IIF(Empty(SA2->A2_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR")))
				aadd(aDest,SA2->A2_DDD+SA2->A2_TEL)
				aadd(aDest,vldIE(SA2->A2_INSCR))
				aadd(aDest,"")//SA2->A2_SUFRAMA
				aadd(aDest,SA2->A2_EMAIL)
				aadd(aDest,SA2->A2_INSCRM) 
				aadd(aDest,SA2->A2_CODSIAF)
				aadd(aDest,SA2->A2_NATUREZ)	  
				aadd(aDest,SA2->A2_SIMPNAC)	  
				aadd(aDest,"")//A1_INCULT
				aadd(aDest,"")//A1_TPESSOA				  
				aadd(aDest,"")//Nota para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")//Serie para empresa hospitalar utilizar apenas com SF2
				aadd(aDest,"")//A1_OUTRMUN
				aadd(aDest,Iif(SA2->(FieldPos("A2_PFISICA"))> 0 ,SA2->A2_PFISICA,""))//26
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona Natureza                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SED")
				DbSetOrder(1)
				DbSeek(xFilial("SED")+SA2->A2_NATUREZ) 
				
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona transportador                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SF2->F2_TRANSP)
				dbSelectArea("SA4")
				dbSetOrder(1)
				DbSeek(xFilial("SA4")+SF2->F2_TRANSP)
				
				aadd(aTransp,AllTrim(SA4->A4_CGC))
				aadd(aTransp,SA4->A4_NOME)
				aadd(aTransp,SA4->A4_INSEST)
				aadd(aTransp,SA4->A4_END)
				aadd(aTransp,SA4->A4_MUN)
				aadd(aTransp,Upper(SA4->A4_EST)	)
		
				If !Empty(SF2->F2_VEICUL1)
					dbSelectArea("DA3")
					dbSetOrder(1)
					DbSeek(xFilial("DA3")+SF2->F2_VEICUL1)
					
					aadd(aVeiculo,DA3->DA3_PLACA)
					aadd(aVeiculo,DA3->DA3_ESTPLA)
					aadd(aVeiculo,"")//RNTC
					
					If !Empty(SF2->F2_VEICUL2)
					
						dbSelectArea("DA3")
						dbSetOrder(1)
						DbSeek(xFilial("DA3")+SF2->F2_VEICUL2)
					
						aadd(aReboque,DA3->DA3_PLACA)
						aadd(aReboque,DA3->DA3_ESTPLA)
						aadd(aReboque,"") //RNTC
						
					EndIf					
				EndIf
			EndIf
			dbSelectArea("SF2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volumes                                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cScan := "1"
			While ( !Empty(cScan) )
				cEspecie := Upper(FieldGet(FieldPos("F2_ESPECI"+cScan)))
				If !Empty(cEspecie)
					nScan := aScan(aEspVol,{|x| x[1] == cEspecie})
					If ( nScan==0 )
						aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F2_VOLUME"+cScan)) , SF2->F2_PLIQUI , SF2->F2_PBRUTO})
					Else
						aEspVol[nScan][2] += FieldGet(FieldPos("F2_VOLUME"+cScan))
					EndIf
				EndIf
				cScan := Soma1(cScan,1)
				If ( FieldPos("F2_ESPECI"+cScan) == 0 )
					cScan := ""
				EndIf
			EndDo  
							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura duplicatas                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Query específica para registros do Loja, devido a regras de parametrização
			//o prefixo é gravado diferente entre SE1 e SF2 para a mesma venmda assitida
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SF2->F2_DUPL)			
             				
				cLJTPNFE := (StrTran(cMV_LJTPNFE," ,"," ','"))+" "
				cWhere := cLJTPNFE
				If cLJPRF != "SF2->F2_SERIE"
					lLJPRF := .F.
				EndIf

				dbSelectArea("SE1")
				dbSetOrder(1)	
				#IFDEF TOP
					lQuery  := .T.
					cAliasSE1 := GetNextAlias()
					If lLJPRF
						BeginSql Alias cAliasSE1
							COLUMN E1_VENCORI AS DATE
							SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCORI,E1_VALOR,E1_ORIGEM,E1_CSLL,E1_COFINS,E1_PIS,E1_PIS,E1_IRRF,E1_INSS,E1_ISS,E1_MOEDA,E1_CLIENTE,E1_LOJA
							FROM %Table:SE1% SE1
							WHERE
							SE1.E1_FILIAL = %xFilial:SE1% AND
							SE1.E1_PREFIXO = %Exp:SF2->F2_PREFIXO% AND 
							SE1.E1_NUM = %Exp:SF2->F2_DUPL% AND 
							((SE1.E1_TIPO = %Exp:MVNOTAFIS%) OR
							SE1.E1_TIPO IN (%Exp:cTipoPcc%) OR
							(SE1.E1_ORIGEM = 'LOJA701' AND SE1.E1_TIPO IN (%Exp:cWhere%))) AND
							SE1.%NotDel%
							ORDER BY %Order:SE1%
						EndSql
					else
						BeginSql Alias cAliasSE1
							COLUMN E1_VENCORI AS DATE
							SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCORI,E1_VALOR,E1_ORIGEM,E1_CSLL,E1_COFINS,E1_PIS,E1_PIS,E1_IRRF,E1_INSS,E1_ISS,E1_MOEDA,E1_CLIENTE,E1_LOJA
							FROM %Table:SE1% SE1
							WHERE
							SE1.E1_FILIAL = %xFilial:SE1% AND
							SE1.E1_NUM = %Exp:SF2->F2_DUPL% AND 
							((SE1.E1_TIPO = %Exp:MVNOTAFIS%) OR
							SE1.E1_TIPO IN (%Exp:cTipoPcc%) OR
							(SE1.E1_ORIGEM = 'LOJA701' AND SE1.E1_TIPO IN (%Exp:cWhere%))) AND
							SE1.%NotDel%
							ORDER BY %Order:SE1%
						EndSql
					EndIf
				#ELSE
					DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
				#ENDIF
				
				While !Eof() .And. xFilial("SE1") == (cAliasSE1)->E1_FILIAL .And.SF2->F2_DUPL == (cAliasSE1)->E1_NUM .AND.;
					(SF2->F2_PREFIXO == (cAliasSE1)->E1_PREFIXO .Or. !lLJPRF) 
					If 	(cAliasSE1)->E1_TIPO = MVNOTAFIS .OR. ((cAliasSE1)->E1_ORIGEM = 'LOJA701' .AND. (cAliasSE1)->E1_TIPO $ cWhere)
						If lDuplLiq
							nAbatim := SomaAbat((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,"R",(cAliasSE1)->E1_MOEDA,dDataBase,(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA)
							// Função SomaAbat: Calcula todas as retenções na geração do Titulo
						EndIf
						aadd(aDupl,{(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_VENCORI,(cAliasSE1)->(E1_VALOR)- nAbatim,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_NUM})
					EndIf  
					//Tratamento para saber se existem titulos de retenção de PIS,COFINS e CSLL
					If lNfsePcc
						If Alltrim((cAliasSE1)->E1_TIPO) $ "NF"
							nRetCsl += (cAliasSE1)->E1_CSLL 
							nRetCof	+= (cAliasSE1)->E1_COFINS
							nRetPis += (cAliasSE1)->E1_PIS
						EndIf	
					Else
						If 	(cAliasSE1)->E1_TIPO $ cTipoPcc
							If (cAliasSE1)->E1_TIPO $ "PIS,PI-"
								nRetPis	+= 	(cAliasSE1)->E1_VALOR
							ElseIf (cAliasSE1)->E1_TIPO $ "COF,CF-"
								nRetCof	+= 	(cAliasSE1)->E1_VALOR						
							ElseIf (cAliasSE1)->E1_TIPO $ "CSL,CS-"
								nRetCsl	+= 	(cAliasSE1)->E1_VALOR
							EndIf				 							
						EndIf
					EndIf	
					dbSelectArea(cAliasSE1)
					dbSkip()
			    EndDo
			    If lQuery
			    	dbSelectArea(cAliasSE1)
			    	dbCloseArea()
			    	dbSelectArea("SE1")
			    EndIf
			Else
				aDupl := {}
			EndIf  
			
			dbSelectArea("SF3")
			dbSetOrder(4)
			If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se recolhe ISS Retido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF3->(FieldPos("F3_RECISS"))>0
					If SF3->F3_RECISS $"1S"       
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pega retencao de ISS por item ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SFT->(dbSetOrder(1))
						SFT->(dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
						While !SFT->(EOF()) .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
							aAdd(aRetISS,SFT->FT_VALICM)
							SFT->(dbSkip())
						EndDo

						dbSelectArea("SD2")
						dbSetOrder(3)
	   					dbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)
						
						aadd(aRetido,{"ISS",0,SF3->F3_VALICM,SD2->D2_ALIQISS,val(SF3->F3_RECISS),aRetISS})
			   		Endif
				EndIf 
					
		  	        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega as deduções ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				  If SF3->(FieldPos("F3_ISSSUB"))>0  .And. SF3->F3_ISSSUB > 0
				  	If len(aDeducao) > 0
	                	aDeducao [len(aDeducao)] := SF3->F3_ISSSUB  
				 	Else
				  		aadd(aDeducao,{SF3->F3_ISSSUB})
				  	EndIF
				  EndIf
			
				  If SF3->(FieldPos("F3_ISSMAT"))>0 .And. SF3->F3_ISSMAT > 0 
					If len(aDeducao) > 0
				        	for nW := 1 To len(aDeducao)
				        		aDeducao[nW][1] += SF3->F3_ISSMAT
			   					exit
				    		next nW 						    				    					  	
					Else
					   	aadd(aDeducao,{SF3->F3_ISSMAT})
					EndIf
				  EndIf
			 EndIf
			 	  
			//Verifica fonte carga tributária
		            	            
           If cMvMsgTrib $ "1-3"
               If lIntegHtl //Integracao Hotelaria
                   cFntCtrb := SF2->F2_LTRAN
               Else
                   If cMvFisCTrb =="1"
                	   If FindFunction("AlqLeiTran")		            		
                	       cFntCtrb := AlqLeiTran("SB1","SBZ" )[2]			            		
                	   EndIf
                	   If Empty(cFntCtrb) .And. !Empty(cMvFntCtrb).And. !cFntCtrb $ "IBPT"
                 	      cFntCtrb := cMvFntCtrb
                	   EndIf 
            	   Else
            		  If Empty(cFntCtrb) .And. !Empty(cMvFntCtrb)
             		     cFntCtrb := cMvFntCtrb
            		  EndIf 
            	   EndIf
                EndIf
            EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analisa os impostos de retencao                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	
			aadd(aRetido,{"PIS",0,nRetPis,SED->ED_PERCPIS,aRetPIS})
			
			aadd(aRetido,{"COFINS",0,nRetCof,SED->ED_PERCCOF,aRetCOF})
			
			aadd(aRetido,{"CSLL",0,nRetCsl,SED->ED_PERCCSL,aRetCSL})
			
			If SF2->(FieldPos("F2_VALIRRF"))<>0 .and. (SF2->F2_VALIRRF>0 .Or. lMvNFSEIR)
				aadd(aRetido,{"IRRF",SF2->F2_BASEIRR,SF2->F2_VALIRRF,SED->ED_PERCIRF,aRetIRR})
			EndIf	
			If SF2->(FieldPos("F2_BASEINS"))<>0 .and. SF2->F2_BASEINS>0
				aadd(aRetido,{"INSS",SF2->F2_BASEINS,SF2->F2_VALINSS,SED->ED_PERCINS,aRetINS})
			EndIf      
			
			// Total Carga Tributária 
			If SF2->(FieldPos("F2_TOTIMP"))<>0 .and. SF2->F2_TOTIMP>0
				nTotalCrg := SF2->F2_TOTIMP
			EndIf
			
			//Não será destacado o valor do IRRF no xml (valir) se o recolhimento do IRRF for feito pelo:  
			//2-Emitente do Documento ou  3-Conforme Cad.Cliente (A1_RECIRRF  =2).

			If  SED->(FieldPos("ED_RECIRRF"))<>0  .and. ( SED->ED_RECIRRF == "2") .or. SED->(FieldPos("ED_RECIRRF"))<>0  .and. (SED->ED_RECIRRF == "3"  .and. SA1->A1_RECIRRF  == "2")
				lRecIrrf:= .F.
			EndIf

			//----------------------------------------------
			// Total Carga Tributária por Ente Tributante
			//----------------------------------------------
			
			// Ente Federal
			If SF2->(FieldPos("F2_TOTFED"))<>0 .and. SF2->F2_TOTFED>0
				nTotFedCrg := SF2->F2_TOTFED
			EndIf

			// Ente Estadual
			If SF2->(FieldPos("F2_TOTEST"))<>0 .and. SF2->F2_TOTEST>0
				nTotEstCrg := SF2->F2_TOTEST
			EndIf
			
			// Ente Municipal
			If SF2->(FieldPos("F2_TOTMUN"))<>0 .and. SF2->F2_TOTMUN>0
				nTotMunCrg := SF2->F2_TOTMUN
			EndIf
			
			//Verifica tipo do cliente.
			cTpCliente := Alltrim(SF2->F2_TIPOCLI)
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa itens de nota                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			//////INCLUSAO DE CAMPOS NA QUERY////////////
			
			cField := "%"
			
			If SD2->(FieldPos("D2_TOTIMP"))<>0
			   cField  +=",D2_TOTIMP"				    
			EndIf			 
			
			If SD2->(FieldPos("D2_DESCICM"))<>0
			   cField  +=",D2_DESCICM"				    
			EndIf
			
			If SD2->(FieldPos("D2_TOTFED"))<>0
			   cField  +=",D2_TOTFED"				    
			EndIf
			
			If SD2->(FieldPos("D2_TOTEST"))<>0
			   cField  +=",D2_TOTEST"				    
			EndIf
			
			If SD2->(FieldPos("D2_TOTMUN"))<>0
			   cField  +=",D2_TOTMUN"				    
			EndIf
			
			cField += "%"
			
			
			dbSelectArea("SD2")
			dbSetOrder(3)	
			#IFDEF TOP
				lQuery  := .T.
				cAliasSD2 := GetNextAlias()
				BeginSql Alias cAliasSD2
					SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
						D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
						D2_CLASFIS,D2_PRCVEN,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_BASEISS,D2_VALIMP1,D2_VALIMP2,D2_VALIMP3,D2_VALIMP4,D2_VALIMP5,D2_PROJPMS %Exp:cField%,
						D2_VALPIS,D2_VALCOF,D2_VALCSL,D2_VALIRRF,D2_VALINS,D2_ORIGLAN,D2_VALICM	
					FROM %Table:SD2% SD2
					WHERE
					SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_SERIE = %Exp:SF2->F2_SERIE% AND 
					SD2.D2_DOC = %Exp:SF2->F2_DOC% AND 
					SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND 
					SD2.D2_LOJA = %Exp:SF2->F2_LOJA% AND 
					SD2.%NotDel%
					ORDER BY %Order:SD2%
				EndSql
					
			#ELSE
				DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			#ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na Construção Cilvil                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty((cAliasSD2)->D2_PROJPMS)
				dbSelectArea("AF8")
				dbSetOrder(1)
				DbSeek(xFilial("AF8")+((cAliasSD2)->D2_PROJPMS))
				If !Empty(AF8->AF8_ART)
					aadd(aConstr,(AF8->AF8_PROJET))
					aadd(aConstr,(AF8->AF8_ART))
					aadd(aConstr,(AF8->AF8_TPPRJ))
				EndIf
						
			Else
				dbSelectArea("SC5")
				SC5->( dbSetOrder(1) )
				If SC5->( MsSeek( xFilial("SC5") + (cAliasSD2)->D2_PEDIDO) )
				 	If ( SC5->(FieldPos("C5_OBRA")) > 0 .And. !Empty(SC5->C5_OBRA) ) .And. SC5->(FieldPos("C5_ARTOBRA")) > 0
						aadd(aConstr,(SC5->C5_OBRA))
						aadd(aConstr,(SC5->C5_ARTOBRA))
					EndIf
					If SC5->(FieldPos("C5_TIPOBRA")) > 0 .And. !Empty(SC5->C5_TIPOBRA)
						If Len(aConstr) == 0
							aadd(aConstr,"")
							aadd(aConstr,"")
						EndIf
						aadd(aConstr,(SC5->C5_TIPOBRA))
					EndIf				

					// Dados do intermediário de serviço
					If SC5->(FieldPos("C5_CLIINT")) > 0 .And. SC5->(FieldPos("C5_CGCINT")) > 0 .And. SC5->(FieldPos("C5_IMINT")) > 0;
					   .And. !Empty(SC5->C5_CLIINT) .And. !Empty(SC5->C5_CGCINT) .And. !Empty(SC5->C5_IMINT)
					   						
						aadd(aInterm,(SC5->C5_CLIINT))
						aadd(aInterm,(SC5->C5_CGCINT))
						aadd(aInterm,(SC5->C5_IMINT))
						
					EndIf
				EndIf
			EndIf

			If Len(aConstr) < 3
				For nX := 1 To 3
					If Len(aConstr) < 3 
						aadd(aConstr,"")							
					EndIf
				Next nX
			EndIf	
			If Len(aObra) < 15
				For nX := 1 To 15
					If Len(aObra) < 15 
						aadd(aObra,"")							
					EndIf
				Next nX
			EndIf
			If ValType(aObra) <> "U"
				cLogradOb  := AllTrim(If(!Empty(aObra[01]) .And. SC5->(FieldPos(aObra[01])) > 0 , &(aObra[01]),"")) //Logradouro para Obra
				cCompleOb  := AllTrim(If(!Empty(aObra[02]) .And. SC5->(FieldPos(aObra[02])) > 0 , &(aObra[02]),"")) //Complemento para obra
				cNumeroOb  := AllTrim(If(!Empty(aObra[03]) .And. SC5->(FieldPos(aObra[03])) > 0 , &(aObra[03]),"")) // Numero para Obra
				cBairroOb  := AllTrim(If(!Empty(aObra[04]) .And. SC5->(FieldPos(aObra[04])) > 0 , &(aObra[04]),"")) // Bairro para Obra
				cCepOb     := AllTrim(If(!Empty(aObra[05]) .And. SC5->(FieldPos(aObra[05])) > 0 , &(aObra[05]),"")) // Cep para Obra
				cCodMunob  := AllTrim(If(!Empty(aObra[06]) .And. SC5->(FieldPos(aObra[06])) > 0 , &(aObra[06]),"")) // Cod do Municipio para Obra
				cNomMunOb  := AllTrim(If(!Empty(aObra[07]) .And. SC5->(FieldPos(aObra[07])) > 0 , &(aObra[07]),"")) // Nome do municipio para Obra
				cUfOb 	   := AllTrim(If(!Empty(aObra[08]) .And. SC5->(FieldPos(aObra[08])) > 0 , &(aObra[08]),"")) // UF para Obra
				cCodPaisOb := AllTrim(If(!Empty(aObra[09]) .And. SC5->(FieldPos(aObra[09])) > 0 , &(aObra[09]),"")) // Codigo do Pais para Obra
				cNomPaisOb := AllTrim(If(!Empty(aObra[10]) .And. SC5->(FieldPos(aObra[10])) > 0 , &(aObra[10]),"")) // Nome do Pais para Obra
				cNumArtOb  := AllTrim(If(!Empty(aObra[11]) .And. SC5->(FieldPos(aObra[11])) > 0 , &(aObra[11]),"")) // Numero Art para Obra
				cNumCeiOb  := AllTrim(If(!Empty(aObra[12]) .And. SC5->(FieldPos(aObra[12])) > 0 , &(aObra[12]),"")) // Numero CEI para Obra
				cNumProOb  := AllTrim(If(!Empty(aObra[13]) .And. SC5->(FieldPos(aObra[13])) > 0 , &(aObra[13]),"")) // Numero Projeto para Obra
				cNumMatOb  := AllTrim(If(!Empty(aObra[14]) .And. SC5->(FieldPos(aObra[14])) > 0 , &(aObra[14]),"")) // Numero de Mtricula para Obra
				cNumEncap  := AllTrim(If(!Empty(aObra[15]) .And. SC5->(FieldPos(aObra[15])) > 0 , &(aObra[15]),"")) // NumeroEncapsulamento
			EndIf
			If(!Empty(cLogradOb),aadd(aConstr,(cLogradOb)),aadd(aConstr,"") ) //Logradouro para Obra
			If(!Empty(cCompleOb),aadd(aConstr,(cCompleOb)),aadd(aConstr,"") ) //Complemento para obra
			If(!Empty(cNumeroOb),aadd(aConstr,(cNumeroOb)),aadd(aConstr,"") ) // Numero para Obra
			If(!Empty(cBairroOb),aadd(aConstr,(cBairroOb)),aadd(aConstr,"") ) // Bairro para Obra
			If(!Empty(cCepOb),aadd(aConstr,(cCepOb)),aadd(aConstr,"") ) // Cep para Obra
			If(!Empty(cCodMunob),aadd(aConstr,(cCodMunob)),aadd(aConstr,"") ) // Cod do Municipio para Obra
			If(!Empty(cNomMunOb),aadd(aConstr,(cNomMunOb)),aadd(aConstr,"") ) // Nome do municipio para Obra
			If(!Empty(cUfOb),aadd(aConstr,(cUfOb)),aadd(aConstr,"") ) // UF para Obra
			If(!Empty(cCodPaisOb),aadd(aConstr,(cCodPaisOb)),aadd(aConstr,"") ) // Codigo do Pais para Obra
			If(!Empty(cNomPaisOb),aadd(aConstr,(cNomPaisOb)),aadd(aConstr,"") ) // Nome do Pais para Obra
			If(!Empty(cNumArtOb),aadd(aConstr,(cNumArtOb)),aadd(aConstr,"") ) // Numero Art para Obra
			If(!Empty(cNumCeiOb),aadd(aConstr,(cNumCeiOb)),aadd(aConstr,"") ) // Numero CEI para Obra
			If(!Empty(cNumProOb),aadd(aConstr,(cNumProOb)),aadd(aConstr,"") ) // Numero Projeto para Obra
			If(!Empty(cNumMatOb),aadd(aConstr,(cNumMatOb)),aadd(aConstr,"") ) // Numero de Mtricula para Obra
			If(!Empty(cNumEncap),aadd(aConstr,(cNumEncap)),aadd(aConstr,"") ) // NumeroEncapsulamento
			
			SF4->(dbSetOrder(1))
			
			While !(cAliasSD2)->(Eof()) .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
				SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
				SF2->F2_DOC == (cAliasSD2)->D2_DOC
				
				SF4->(dbSeek(xFilial('SF4')+(cAliasSD2)->D2_TES))
				
				nCont++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a natureza da operacao                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC5")
				dbSetOrder(1)
				If DbSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
					lSC5 := .T.
				Else
					lSC5 := .F.			
				EndIf	
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega retencoes por item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aRetPIS,Iif(nRetPis > 0, (cAliasSD2)->D2_VALPIS, 0))
				nScan := aScan(aRetido,{|x| x[1] == "PIS"})
				If nScan > 0
					aRetido[nScan][5] := aRetPIS
				EndIf

				aAdd(aRetCOF,Iif(nRetCof > 0, (cAliasSD2)->D2_VALCOF, 0))
				nScan := aScan(aRetido,{|x| x[1] == "COFINS"})
				If nScan > 0
					aRetido[nScan][5] := aRetCOF
				EndIf

				aAdd(aRetCSL,Iif(nRetCsl > 0, (cAliasSD2)->D2_VALCSL, 0))
				nScan := aScan(aRetido,{|x| x[1] == "CSLL"})
				If nScan > 0
					aRetido[nScan][5] := aRetCSL
				EndIf

				aAdd(aRetIRR,Iif(SF2->(FieldPos("F2_VALIRRF")) <> 0 .and. SF2->F2_VALIRRF > 0, (cAliasSD2)->D2_VALIRRF, 0))
				nScan := aScan(aRetido,{|x| x[1] == "IRRF"})
				If nScan > 0
					If lMvNFSEIR
						If nCont == 1 .And. aRetido[nScan][2] > 0
							aRetido[nScan][3] := 0
						EndIf
						aRetido[nScan][3] += (cAliasSD2)->D2_VALIRRF
					EndIf
					aRetido[nScan][5] := aRetIRR
				EndIf

				aAdd(aRetINS,Iif(SF2->(FieldPos("F2_BASEINS")) <> 0 .and. SF2->F2_BASEINS > 0, (cAliasSD2)->D2_VALINS, 0))
				nScan := aScan(aRetido,{|x| x[1] == "INSS"})
				If nScan > 0
					aRetido[nScan][5] := aRetINS
				EndIf

				//TRATAMENTO - INTEGRACAO COM TMS-GESTAO DE TRANSPORTES
				If IntTms()
					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6")+SF2->(F2_FILIAL+F2_DOC+F2_SERIE)))
						cModFrete := DT6->DT6_TIPFRE
						
						SA1->(DbSetOrder(1))
						If SA1->(DbSeek(xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES)))
							cMunPSIAFI := SA1->A1_CODSIAF
						EndIf
						
						If DUY->(FieldPos("DUY_CODMUN")) > 0
							DUY->(DbSetOrder(1))
							If DUY->(DbSeek(xFilial("DUY")+DT6->DT6_CDRDES))
								nPosUF:=aScan(aUF,{|X| X[1] == DUY->DUY_EST})
								If nPosUF > 0 
									cMunPrest:=aUF[nPosUF][2]+AllTrim(DUY->DUY_CODMUN)
		    					Else
			    					cMunPrest:=DUY->DUY_CODMUN
		    					EndIf
							EndIf							
						Else
							SA1->(DbSetOrder(1))
							If SA1->(DbSeek(xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES)))
								cMunPrest := SA1->A1_COD_MUN
							EndIf
						EndIf					
					Else
						If lSC5 .And. SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
							//Quando for preenchido os campos C5_ESTPRES e C5_MUNPRES concatena as informacoes
							If ( len(Alltrim(SC5->C5_MUNPRES)) == 5 .AND. !empty(SC5->C5_ESTPRES) )
								
								For nZ := 1 to len(aUf)
									If Alltrim(SC5->C5_ESTPRES) == aUf[nZ][1]
										cMunPrest := Alltrim(aUf[nZ][2] + Alltrim(SC5->C5_MUNPRES))
										exit
									EndIf
								Next
							Else
								cMunPrest := SC5->C5_MUNPRES
							EndIf
							
							cDescMunP := SC5->C5_DESCMUN
							
						Else
							If Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )) == "5208707" //Goiania
								cMunPrest := Alltrim(aDest[25])
								cDescMunP := aDest[08] 
							Else
								If ((cAliasSD2)->D2_ORIGLAN $ "LO")
									cMunPrest := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
								Elseif ((cAliasSD2)->D2_ORIGLAN $ "VD")
									cMunPrest := aDest[07]
									If Empty(cMunPrest)
										cMunPrest := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
									EndIf
						   		Else
									cMunPrest := aDest[07]
								Endif
								cDescMunP := aDest[08]
							Endif
						EndIf
					EndIf
				ElseIf SuperGetMV("MV_INTTUR",,.F.) .AND. Empty( (cAliasSD2)->D2_PEDIDO )			
					cMunPrest := SM0->M0_CODMUN
					cDescMunP := Alltrim(SM0->M0_CIDCOB)	
				Else
					If lSC5 .And. SC5->(FieldPos("C5_MUNPRES")) > 0 .And. !Empty(SC5->C5_MUNPRES)
						//Quando for preenchido os campos C5_ESTPRES e C5_MUNPRES concatena as informacoes
						If ( len(Alltrim(SC5->C5_MUNPRES)) == 5 .AND. !empty(SC5->C5_ESTPRES) )
							
							For nZ := 1 to len(aUf)
								If Alltrim(SC5->C5_ESTPRES) == aUf[nZ][1]
									cMunPrest := Alltrim(aUf[nZ][2] + Alltrim(SC5->C5_MUNPRES))
									exit
								EndIf
							Next
						Else
							cMunPrest := SC5->C5_MUNPRES
						EndIf
						
						cDescMunP := SC5->C5_DESCMUN
						
					ElseIf Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )) == "3507605" .And. SF4->F4_ISSST == '3'			// Bragança Paulista
						cMunPrest := Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ))
						cDescMunP := Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CIDCOB,oSigamatX:M0_CIDCOB ))
					Else
						If Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )) == "5208707" //Goiania
							cMunPrest := Alltrim(aDest[25])
							cDescMunP := aDest[08] 
						Else
							cDescMunP := aDest[08]
							If ((cAliasSD2)->D2_ORIGLAN $ "LO")
								cMunPrest := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
								cDescMunP := Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CIDENT,oSigamatX:M0_CIDENT ))
							Elseif ((cAliasSD2)->D2_ORIGLAN $ "VD")
								cMunPrest := aDest[07]
								If Empty(cMunPrest)
									cMunPrest := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
									cDescMunP := Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CIDENT,oSigamatX:M0_CIDENT ))
								EndIf
					   		Else
								cMunPrest := aDest[07]
							Endif
							
						Endif
					EndIf
					
					If lSC5 .And. SC5->(FieldPos("C5_MUNPRES")) > 0 .And. Empty(SC5->C5_MUNPRES) .And. if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3509502"
					
						SA1->(DbSetOrder(1))
						If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJACLI))
							cMunPSIAFI := SA1->A1_CODSIAF
						EndIf
					
					EndIf
					// Tratamento para notas com data de Competencia
					If ! Empty(cCamSC5)
						If Fieldpos(cCamSC5)>0
							dDateCom := SC5->&(cCamSC5)
						Else
							dDateCom := CToD("")
						Endif
					Endif
				EndIf
	
				dbSelectArea("SF4")
				dbSetOrder(1)
				DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)				
				
				cF4Agreg:= SF4->F4_AGREG
				
				//Pega descricao do pedido de venda-Parametro MV_NFESERV
           		cFieldMsg := GetNewPar("MV_CMPUSR","")
				If !lNFeDesc
					If lNatOper .And. lSC5 .And. nCont == 1 .and. !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
						cNatOper := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
					ElseIf lNatOper .And. lSC5 .And. !Empty(SC5->C5_MENNOTA).And. nCont == 1
						cNatOper += If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
					ElseIf SF2->(FieldPos("F2_MENNOTA")) <> 0 .and. !AllTrim(SF2->F2_MENNOTA) $ cMensCli .and. !Empty(AllTrim(SF2->F2_MENNOTA))
             			cDiscrNFSe +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SF2->F2_MENNOTA)),AllTrim(SF2->F2_MENNOTA))
					EndIf
				Else 
					If lSC5 .And. nCont == 1 .and. !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
						cDiscrNFSe := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
					ElseIf lSC5 .And. !Empty(SC5->C5_MENNOTA).And. nCont == 1
						cDiscrNFSe := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
					ElseIf !Empty(AllTrim(SF2->F2_MENNOTA)) .And. nCont == 1
             			cDiscrNFSe +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SF2->F2_MENNOTA)),AllTrim(SF2->F2_MENNOTA))
					EndIf
				EndIf

				If IntTMS() .And. nCont == 1
					DTC->(DbSetOrder(3))
					If DTC->(MsSeek(xFilial('DTC')+SF2->(F2_FILIAL+F2_DOC+F2_SERIE)))
						cObsDtc := StrTran(MsMM(DTC->DTC_CODOBS,80),Chr(13),". ")
						cNatOper += Iif(!Empty(cObsDtc),cObsDtc+" - ",cObsDtc)
					EndIf
				EndIf
				
				//---------------------------------------
				// - Posiciona no Cadastro de Produtos
				//---------------------------------------
				dbSelectArea( "SB1" )
				dbSetOrder( 1 )
				DbSeek( xFilial( "SB1" ) + ( cAliasSD2 )->D2_COD )

				//---------------------------------------------------------------------------------
				// - Obtem a descricao da tabela SX5
				// - Tabela 60 - Conforme Item da Lista de Servico informado no Cad. de Produtos
				//---------------------------------------------------------------------------------
				dbSelectArea( "SX5" )
				dbSetOrder( 1 )
				aRetSX5 := FWGetSX5( '60',RetFldProd( SB1->B1_COD,"B1_CODISS" ) )
					
				if( !empty( aRetSX5 ) )
					cMsgSX5 := iif( FindFunction( 'CleanSpecChar' ),CleanSpecChar( aRetSX5[ 1 ][ 4 ] ),aRetSX5[ 1 ][ 4 ] )
					cMsgSX5 := allTrim( subStr( cMsgSX5,1,55 ) )
				endIf

				if( nCont == 1 )
					if( !lNFeDesc )
						cNatOper	+= cMsgSX5
					else
						cDescrNFSe	:= cMsgSX5
					endIf
				endIf
    		
				If SF4->(FieldPos("F4_CFPS")) > 0
					cCFPS:=SF4->F4_CFPS
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as notas vinculadas                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSD2)->D2_NFORI) 
					If (cAliasSD2)->D2_TIPO $ "DBN"
						dbSelectArea("SD1")
						dbSetOrder(1)
						If DbSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
							dbSelectArea("SF1")
							dbSetOrder(1)
							DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
							If SD1->D1_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
							EndIf
							
							aadd(aNfVinc,{SD1->D1_EMISSAO,SD1->D1_SERIE,SD1->D1_DOC,IIF(SD1->D1_TIPO $ "DB",IIF(SD1->D1_FORMUL=="S",if( type( "oSigamatX" ) == "U",SM0->M0_CGC,oSigamatX:M0_CGC ),SA1->A1_CGC),IIF(SD1->D1_FORMUL=="S",if( type( "oSigamatX" ) == "U",SM0->M0_CGC,oSigamatX:M0_CGC ),SA2->A2_CGC)),if( type( "oSigamatX" ) == "U",SM0->M0_ESTCOB,oSigamatX:M0_ESTCOB ),SF1->F1_ESPECIE})
						EndIf
					Else
						aOldReg  := SD2->(GetArea())
						aOldReg2 := SF2->(GetArea())
						dbSelectArea("SD2")
						dbSetOrder(3)
						If DbSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
							dbSelectArea("SF2")
							dbSetOrder(1)
							DbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
							If !SD2->D2_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								DbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
							EndIf
							
							aadd(aNfVinc,{SF2->F2_EMISSAO,SD2->D2_SERIE,SD2->D2_DOC,if( type( "oSigamatX" ) == "U",SM0->M0_CGC,oSigamatX:M0_CGC ),if( type( "oSigamatX" ) == "U",SM0->M0_ESTCOB,oSigamatX:M0_ESTCOB ),SF2->F2_ESPECIE})
						EndIf
						RestArea(aOldReg)
						RestArea(aOldReg2)
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem os dados do produto                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				dbSelectArea("SB1")
				dbSetOrder(1)
				DbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD)
				
				dbSelectArea("SB5")
				dbSetOrder(1)
				DbSeek(xFilial("SB5")+(cAliasSD2)->D2_COD)
				//Veiculos Novos
				If AliasIndic("CD9")			
					dbSelectArea("CD9")
					dbSetOrder(1)
					DbSeek(xFilial("CD9")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf			
				//Medicamentos
				If AliasIndic("CD7")			
					dbSelectArea("CD7")
					dbSetOrder(1)
					DbSeek(xFilial("CD7")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf
				// Armas de Fogo
				If AliasIndic("CD8")						
					dbSelectArea("CD8")
					dbSetOrder(1) 
					DbSeek(xFilial("CD8")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM)
				EndIf
				// Msg Zona Franca de Manaus / ALC
				dbSelectArea("SF3")
				If Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )) == "4303905"
					dbSetOrder(5)//F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
					nItem := PadL((cAliasSD2)->D2_ITEM,6,"0")                                                                                                     
					If DbSeek(xFilial("SF3")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+nItem)			
						If !SF3->F3_DESCZFR == 0
							cMensFis := "Total do desconto Ref. a Zona Franca de Manaus / ALC. R$ "+str(SF3->F3_VALOBSE-SF2->F2_DESCONT,13,2)
						EndIf 			
					EndIf
				Else	
					dbSetOrder(4)
					If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)			
						If !SF3->F3_DESCZFR == 0
							cMensFis := "Total do desconto Ref. a Zona Franca de Manaus / ALC. R$ "+str(SF3->F3_VALOBSE-SF2->F2_DESCONT,13,2)
						EndIf 			
					EndIf	
				EndIf			
				
				dbSelectArea("SC6")
				dbSetOrder(1)
				DbSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)
				
           		cFieldMsg := GetNewPar("MV_CMPUSR","")
             	If !Empty(cFieldMsg) .and. SC5->(FieldPos(cFieldMsg)) > 0 .and. !Empty(&("SC5->"+cFieldMsg))
             		//Permite ao cliente customizar o conteudo do campo dados adicionais por meio de um campo MEMO proprio.
             		cMensCli := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(&("SC5->"+cFieldMsg))),&("SC5->"+cFieldMsg))+" "
				ElseIf !AllTrim(SC5->C5_MENNOTA) $ cMensCli
					cMensCli +=If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(SC5->C5_MENNOTA)),AllTrim(SC5->C5_MENNOTA))
				EndIf
				If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
					cMensFis += If(FindFunction('CleanSpecChar'),CleanSpecChar(AllTrim(FORMULA(SC5->C5_MENPAD))),AllTrim(FORMULA(SC5->C5_MENPAD)))
				EndIf
							
				cModFrete := IIF(SC5->C5_TPFRETE=="C","0","1")
				
				If Empty(aPedido)
					aPedido := {"",AllTrim(SC6->C6_PEDCLI),""}
				EndIf
				
				
				dbSelectArea("CD2")
				If !(cAliasSD2)->D2_TIPO $ "DB"
					dbSetOrder(1)
				Else
					dbSetOrder(2)
				EndIf
				If !DbSeek(xFilial("CD2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD)
	
				EndIf
				aadd(aISSQN,{0,0,0,"","",0})
				While !Eof() .And. xFilial("CD2") == CD2->CD2_FILIAL .And.;
					"S" == CD2->CD2_TPMOV .And.;
					SF2->F2_SERIE == CD2->CD2_SERIE .And.;
					SF2->F2_DOC == CD2->CD2_DOC .And.;
					SF2->F2_CLIENTE == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_CODCLI,CD2->CD2_CODFOR) .And.;
					SF2->F2_LOJA == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_LOJCLI,CD2->CD2_LOJFOR) .And.;
					(cAliasSD2)->D2_ITEM == SubStr(CD2->CD2_ITEM,1,Len((cAliasSD2)->D2_ITEM)) .And.;
					(cAliasSD2)->D2_COD == CD2->CD2_CODPRO
										
					Do Case
						Case AllTrim(CD2->CD2_IMP) == "ICM"
							aTail(aICMS) := {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,CD2->CD2_PREDBC,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,0,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "SOL"
							aTail(aICMSST) := {CD2->CD2_ORIGEM,CD2->CD2_CST,CD2->CD2_MODBC,CD2->CD2_PREDBC,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MVA,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
							lCalSol := .T.
						Case AllTrim(CD2->CD2_IMP) == "IPI"
							aTail(aIPI) := {"","",0,"999",CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_QTRIB,CD2->CD2_PAUTA,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_MODBC,CD2->CD2_PREDBC}
						Case AllTrim(CD2->CD2_IMP) == "PS2"
							If (cAliasSD2)->D2_VALISS==0
								aTail(aPIS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
							Else
								If Empty(aISS)
									aISS := {0,0,0,0,0}
								EndIf
								aISS[04]+= CD2->CD2_VLTRIB	
							EndIf
						Case AllTrim(CD2->CD2_IMP) == "CF2"
							If (cAliasSD2)->D2_VALISS==0 
								aTail(aCOFINS) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
							Else
								If Empty(aISS)
									aISS := {0,0,0,0,0}
								EndIf
								aISS[05] += CD2->CD2_VLTRIB	
							EndIf
						Case AllTrim(CD2->CD2_IMP) == "PS3" .And. (cAliasSD2)->D2_VALISS==0
							aTail(aPISST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "CF3" .And. (cAliasSD2)->D2_VALISS==0
							aTail(aCOFINSST) := {CD2->CD2_CST,CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,CD2->CD2_QTRIB,CD2->CD2_PAUTA}
						Case AllTrim(CD2->CD2_IMP) == "ISS"
							If Empty(aISS)
								aISS := {0,0,0,0,0}
							EndIf
							aISS[01] += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
							aISS[02] += CD2->CD2_BC
							aISS[03] += CD2->CD2_VLTRIB
							If !Empty(cMunPrest) .and. (Empty(aDest[01]) .and. Empty(aDest[02]) .and. Empty(aDest[07]) .and. Empty(aDest[09]))
								cMunISS := cMunPrest
							Else
								cMunISS := convType(aUF[aScan(aUF,{|x| x[1] == aDest[09]})][02]+aDest[07])
							EndIf
							If nAliq > 0
								If nAliq == CD2->CD2_ALIQ .And. lAglutina
									aISSQN[1][2] := CD2->CD2_ALIQ
									aISSQN[1][1] += CD2->CD2_BC 
									aISSQN[1][3] += CD2->CD2_VLTRIB
									aISSQN[1][6] += iif( lMvDescInc,( cAliasSD2 )->D2_DESCON,0 ) // NFSE - Desconto Incondicionado
								Else
									lAglutina := .F.	                                                                                                       
									aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,cMunISS,AllTrim((cAliasSD2)->D2_CODISS),(cAliasSD2)->D2_DESCON}
								EndIf
							Else
							    aTail(aISSQN) := {CD2->CD2_BC,CD2->CD2_ALIQ,CD2->CD2_VLTRIB,cMunISS,AllTrim((cAliasSD2)->D2_CODISS),(cAliasSD2)->D2_DESCON}
								nAliq := CD2->CD2_ALIQ
							EndIf	
					EndCase
					dbSelectArea("CD2")
					dbSkip()
				EndDo
				If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "4205407" //florianopolis
					nValTotPrd := IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0)
				Else
					nValTotPrd := IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0)+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)
				EndIf	
				If lAglutina
					If Len(aProd) > 0			
						nX := aScan(aProd,{|x| x[24] == (cAliasSD2)->D2_CODISS .And. x[23] == IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),"")})
						If nX > 0						
							aProd[nX][9] := 1							
							aProd[nx][13]+= (cAliasSD2)->D2_VALFRE // Valor Frete						
							aProd[nx][14]+= (cAliasSD2)->D2_SEGURO // Valor Seguro
							aProd[nx][15]+= ((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR) // Valor Desconto
							aProd[nx][21]+= SF3->F3_ISSSUB                       						
							aProd[nx][22]+= SF3->F3_ISSMAT
							aProd[nx][25]+= a410Arred( (cAliasSD2)->D2_BASEISS, "D2_TOTAL" )
							aProd[nx][26]+= (cAliasSD2)->D2_VALFRE               						

							If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308"									
								aProd[nx][27]+=	a410Arred( IIF(!(cAliasSD2)->D2_TIPO $ "IP",(cAliasSD2)->D2_TOTAL,0), "D2_TOTAL" )
								aProd[nx][10] := aProd[nx][28]+=	a410Arred( IIF(!(cAliasSD2)->D2_TIPO $ "IP",(cAliasSD2)->D2_TOTAL,0) + ((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR), "D2_TOTAL")	//Valor Total						
							Else		
								//----------------------------------------------------------------
								// Realizado ajuste para considerar o somatorio do D2_TOTAL, 
								// caso haja 'desconto' a ser somado, sera validado na 
								// funcao FunValTot, com isso, ficara validacao em um unico lugar.
								// @autor: Douglas Parreja
								// @date: 29/03/2018
								//----------------------------------------------------------------							
								aProd[nx][27]+=	a410Arred( IIF(!(cAliasSD2)->D2_TIPO $ "IP",(cAliasSD2)->D2_PRCVEN,0) * (cAliasSD2)->D2_QUANT, "D2_TOTAL" ) // Valor Liquido
								aProd[nx][10] := aProd[nx][28]+= a410Arred( FunValTot((cAliasSD2)->D2_TIPO,(cAliasSD2)->D2_PRCVEN, (cAliasSD2)->D2_QUANT, getValTotal(nValTotPrd,(cAliasSD2)->D2_TOTAL), (cAliasSD2)->D2_DESCON, (cAliasSD2)->D2_DESCZFR, (cAliasSD2)->D2_VALICM), FuCamArren(nCamPrcv,nCamQuan,nCamTot) ) //Valor Total
								//aProd[nx][10] := aProd[nx][28]+=	a410Arred( IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN,0) * (cAliasSD2)->D2_QUANT+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR), "D2_TOTAL" ) //Valor Total
							EndIf							
							aProd[nx][29]+=	getValDesc(lMvded, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE,(cAliasSD2)->D2_CODISS,(cAliasSD2)->D2_DESCON ) 
							aProd[nx][35]+= IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),0) //35 - Lei transparência
							aProd[nx][38]+= IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTFED"))<>0,(cAliasSD2)->D2_TOTFED,0),0) //38 - Lei transparência
							aProd[nx][39]+= IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTEST"))<>0,(cAliasSD2)->D2_TOTEST,0),0) //39 - Lei transparência
							aProd[nx][40]+= IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTMUN"))<>0,(cAliasSD2)->D2_TOTMUN,0),0) //40 - Lei transparência
						Else
							lAglutina := .F.
						EndIF			                                                                                                                        					
					EndIf	
				EndIF
				If !lAglutina .Or. Len(aProd) == 0
										
					aadd(aProd,	{Len(aProd)+1,;
								(cAliasSD2)->D2_COD,;
								IIf(Val(SB1->B1_CODBAR)==0,"",Str(Val(SB1->B1_CODBAR),Len(SB1->B1_CODBAR),0)),;
								IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI),;
								SB1->B1_POSIPI,;
								SB1->B1_EX_NCM,;
								(cAliasSD2)->D2_CF,;
								SB1->B1_UM,;
								(cAliasSD2)->D2_QUANT,;
								a410Arred( FunValUnit((cAliasSD2)->D2_TIPO, (cAliasSD2)->D2_PRCVEN, (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_VALICM), FuCamArren(nCamPrcv,nCamQuan,nCamTot)),; //IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN,0),; // Valor unitário
								IIF(Empty(SB5->B5_UMDIPI),SB1->B1_UM,SB5->B5_UMDIPI),;
								IIF(Empty(SB5->B5_CONVDIPI),(cAliasSD2)->D2_QUANT,SB5->B5_CONVDIPI*(cAliasSD2)->D2_QUANT),;
								(cAliasSD2)->D2_VALFRE,;
								(cAliasSD2)->D2_SEGURO,;
								((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR),;
								IIF(!(cAliasSD2)->D2_TIPO$"IP",(cAliasSD2)->D2_PRCVEN+IIf(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "4205407",0,(((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/(cAliasSD2)->D2_QUANT)),0),;								
								IIF(SB1->(FieldPos("B1_CODSIMP"))<>0,SB1->B1_CODSIMP,""),; //codigo ANP do combustivel
								IIF(SB1->(FieldPos("B1_CODIF"))<>0,SB1->B1_CODIF,""),; //CODIF
								RetFldProd(SB1->B1_COD,"B1_CNAE"),;
								SF3->F3_RECISS,;
								SF3->F3_ISSSUB,;
								SF3->F3_ISSMAT,;   
								IIF(SB1->(FieldPos("B1_TRIBMUN"))<>0,RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),""),;
								SF3->F3_CODISS,;
								(cAliasSD2)->D2_BASEISS,;
								(cAliasSD2)->D2_VALFRE,;
								a410Arred( IIF(!(cAliasSD2)->D2_TIPO$"IP",IIF(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308",(cAliasSD2)->D2_PRCVEN * (cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_TOTAL),0), FuCamArren(nCamPrcv,nCamQuan,nCamTot) ),; // Valor Liquido
								a410Arred( FunValTot((cAliasSD2)->D2_TIPO,(cAliasSD2)->D2_PRCVEN, (cAliasSD2)->D2_QUANT, getValTotal(nValTotPrd,(cAliasSD2)->D2_TOTAL), (cAliasSD2)->D2_DESCON, (cAliasSD2)->D2_DESCZFR, (cAliasSD2)->D2_VALICM), FuCamArren(nCamPrcv,nCamQuan,nCamTot) ),; //Valor Total
								getValDesc(lMvded, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE,(cAliasSD2)->D2_CODISS,(cAliasSD2)->D2_DESCON ),; //Valor Total de deducoes.
								(cAliasSD2)->D2_VALIMP4,; //30
								(cAliasSD2)->D2_VALIMP5,; //31
								RetFldProd(SB1->B1_COD,"B1_TRIBMUN"),; //32
								IIF(SF4->(FieldPos("F4_CFPS")) > 0,SF4->F4_CFPS,""),;//33 
								IIF(SF4->(FieldPos(cMVBENEFRJ))> 0,SF4->(&(cMVBENEFRJ)),"" ),; // 34 - Código Beneficio Fiscal - NFS-e RJ
								IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTIMP"))<>0,(cAliasSD2)->D2_TOTIMP,0),0),; //35 - Lei transparência
								IIF(lMvred,IIF((cAliasSD2)->D2_BASEISS <> nValTotPrd, nValTotPrd - (cAliasSD2)->D2_BASEISS, (cAliasSD2)->D2_BASEISS),0),;	//Posicao para verifcar se existe reducao de ISS, será criado um campo na SFT para substituir esse calculo
								IIF( SB1->(FieldPos("B1_MEPLES"))<>0, SB1->B1_MEPLES, "" ),; //37 - campo para NFSe Sao Paulo, identifica se eh Dentro do municipio ou fora.
								IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTFED"))<>0,(cAliasSD2)->D2_TOTFED,0),0),; //38 - Lei transparência
								IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTEST"))<>0,(cAliasSD2)->D2_TOTEST,0),0),; //39 - Lei transparência
								IIF(lCrgTrib .And. cTpCliente == "F",IIF((cAliasSD2)->(FieldPos("D2_TOTMUN"))<>0,(cAliasSD2)->D2_TOTMUN,0),0),;  //40 - Lei transparência
								IIF(SC6->(FieldPos("C6_DESCRI")) > 0,AllTrim(SC6->C6_DESCRI),"")	;	//41 - Descricao RPS SC6
					})
				EndIf
				
				If SC6->(FieldPos("C6_TPDEDUZ")) > 0 .And. !Empty(SC6->C6_TPDEDUZ)
		            aadd(aDeduz,{SC6->C6_TPDEDUZ,;
		            			 SC6->C6_MOTDED ,;
		            			 SC6->C6_FORDED ,;
		            			 SC6->C6_LOJDED ,;
		            			 SerieNfId("SC6",2,"C6_SERDED") ,;		            			 		            
		            			 SC6->C6_NFDED  ,;
		            			 SC6->C6_VLNFD  ,;
		            			 SC6->C6_PCDED  ,;
		            			 if ( SC6->C6_VLDED > 0  , SC6->C6_VLDED , ( SC6->C6_ABATISS + SC6->C6_ABATMAT ) ),;
           			 })
	            endif
	
				//----------------------------------------------------------------------
				// Tratamento realizado para buscar o CST do ISS no campo do Livro.
				// Este campo FT_CSTISS nada mais eh conforme a configuracao na TES,
				// no campo F4_CSTISS.
				// Manteremos o legado D2_CLASFIS uma vez que estiver informado, mas
				// caso queira que o campo retorne do ISS, o campo FT_CSTISS precisara
				// estar alimentado.
				//
				// @Date: 07/06/2018
				// @Autor: Douglas Parreja				
				//----------------------------------------------------------------------
				dbSelectArea("SFT")				
				if SFT->( fieldPos("FT_CSTISS") ) > 0
					SFT->( dbSetOrder(1) ) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
					if SFT->( dbSeek( xFilial("SFT") + "S" + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_DOC + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA) )
						cCST_SFT 	:= ""
						cOrigemSB1	:= ""
						if !empty(SFT->(FT_CSTISS))
							cCST_SFT := (SFT->(FT_CSTISS))
							dbSelectArea("SB1")
							SB1->( dbSetOrder(1) )
							if SB1->( dbSeek( xFilial("SB1") + (cAliasSD2)->D2_COD ))
								if !empty(SB1->( B1_ORIGEM) )
									cOrigemSB1 := (SB1->(B1_ORIGEM))
								endif
							endif
						endif
					endif					
				endif 
				//----------------------------------------------------------------------
				// aCST[] - Caso o B1_ORIGEM ou F4_SITTRIB um deles estejam preenchidos, 
				// o campo D2_CLASFIS ficara (b1_origem) "0  ", com isso, faco a validacao
				// do campo FT_CSTISS/B1_ORIGEM para verificar se esta preenchido.								
				//----------------------------------------------------------------------
				aadd(aCST,{IIF(!Empty((cAliasSD2)->D2_CLASFIS) .and. empty(cCST_SFT)	, SubStr((cAliasSD2)->D2_CLASFIS,2,2), iif(!empty(cCST_SFT)		, cCST_SFT		, '50')), ;
				           IIF(!Empty((cAliasSD2)->D2_CLASFIS) .and. empty(cOrigemSB1)	, SubStr((cAliasSD2)->D2_CLASFIS,1,1), iif(!empty(cOrigemSB1)	, cOrigemSB1	, '0' ))})
				aadd(aICMS,{})
				aadd(aIPI,{})
				aadd(aICMSST,{})
				aadd(aPIS,{})
				aadd(aPISST,{})
				aadd(aCOFINS,{})
				aadd(aCOFINSST,{})
				//aadd(aISSQN,{0,0,0,"","",0})
				aadd(aAdi,{})
				aadd(aDi,{})				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para TAG Exportação quando existe a integração com a EEC     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*Alterações TQXWO2
			    Na chamada da função, foram criados dois novos parâmetros: 
				o 3º referente ao código do produto e o 4º referente ao número da nota fiscal + série (chave).
				GetNfeExp(pProcesso, pPedido, cProduto, cChave)
				No retorno da função serão devolvidas as informações do legado, conforme leiaute anterior à versão 3.10 , 
				e as informações dos grupos “I03 - Produtos e Serviços / Grupo de Exportação” e “ZA - Informações de Comércio Exterior”, conforme estrutura da NT20013.005_v1.21.
				As posições 1 e 2 mantém o retorno das informações ZA02 e ZA03, mantendo o legado para os cliente que utilizam versão 2.00
				Na posição 3 passa a ser enviado o agrupamento do ID I50, tendo como filhos os IDs I51 e I52.
				Na posição 4 passa a ser enviado o agrupamento do ZA01, tendo como filhos os IDs ZA02, ZA03 e ZA04.
				Na posição 5 passa a ser enviado informaçãoes para o grupo "BA02 - Chaves Nfe referenciadas" as chaves de notas fiscais de saída de lote de exportação associadas à nota de saída de exportação.
				O array de retorno será multimensional, trazendo na primeira posição o identificador (ID), 
				na segunda posição a tag (o campo) e na terceira posição o conteúdo retornado do processo, 
				podendo ser um outro array com a mesma estrutura caso o ID possua abaixo de sua estrutura outros IDs. 						 				
				*/
				/*Alterações TUSHX4
				Foi incluido o parametro D2_LOTECTL para que a função localize as notas de entrada (produto com lote e endereçamento) amarradas no pedido de exportção e consiga
				retornar o array de exportind de acordo com a quantidade de cada item da SD2, para não ocorrer a rejeição 
				346 Somatório das quantidades informadas na Exportação Indireta não correspondem a quantidade do item.*/

				If lEECFAT .And. !Empty((cAliasSD2)->D2_PREEMB)
					aadd(aExp,(GETNFEEXP((cAliasSD2)->D2_PREEMB,,(cAliasSD2)->D2_COD,(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_PEDIDO,(cAliasSD2)->D2_ITEMPV)))
				Elseif !Empty(SC5->C5_PEDEXP)
					aADD(aExp,(GETNFEEXP(,SC5->C5_PEDEXP,cCodProd,(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_PEDIDO,(cAliasSD2)->D2_ITEMPV)))
				Else
					aadd(aExp,{})
				EndIf
					
				If AliasIndic("CD7")
					aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO})
				Else
					aadd(aMed,{})
	   			EndIf
	   			If AliasIndic("CD8")
					aadd(aArma,{CD8->CD8_TPARMA,CD8->CD8_NUMARMA,CD8->CD8_DESCR})                       
				Else
					aadd(aArma,{})
				EndIf			
				If AliasIndic("CD9")
					aadd(aveicProd,{IIF(CD9->CD9_TPOPER$"03",1,IIF(CD9->CD9_TPOPER$"1",2,IIF(CD9->CD9_TPOPER$"2",3,IIF(CD9->CD9_TPOPER$"9",0,"")))),;
									CD9->CD9_CHASSI,CD9->CD9_CODCOR,CD9->CD9_DSCCOR,CD9->CD9_POTENC,CD9->CD9_CM3POT,CD9->CD9_PESOLI,;
					                CD9->CD9_PESOBR,CD9->CD9_SERIAL,CD9->CD9_TPCOMB,CD9->CD9_NMOTOR,CD9->CD9_CMKG,CD9->CD9_DISTEI,CD9->CD9_RENAVA,;
					                CD9->CD9_ANOMOD,CD9->CD9_ANOFAB,CD9->CD9_TPPINT,CD9->CD9_TPVEIC,CD9->CD9_ESPVEI,CD9->CD9_CONVIN,CD9->CD9_CONVEI,;
					                CD9->CD9_CODMOD})
				Else
				    aadd(aveicProd,{})
				EndIf			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Totaliza todas retencoes por item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRetDesc :=	Iif(nRetPis > 0, (cAliasSD2)->D2_VALPIS, 0) + Iif(nRetCof > 0, (cAliasSD2)->D2_VALCOF, 0) + ;
							Iif(nRetCsl > 0, (cAliasSD2)->D2_VALCSL, 0) + Iif(SF2->(FieldPos("F2_VALIRRF")) <> 0 .and. SF2->F2_VALIRRF > 0, (cAliasSD2)->D2_VALIRRF, 0) + ;
							Iif(SF2->(FieldPos("F2_BASEINS")) <> 0 .and. SF2->F2_BASEINS > 0, (cAliasSD2)->D2_VALINS, 0) + Iif(Len(aRetISS) >= nCont, aRetISS[nCont], 0)
				
				aTotal[01] += (cAliasSD2)->D2_DESPESA
				aTotal[02] += getValTotal(nValTotPrd,(cAliasSD2)->D2_TOTAL)
				aTotal[03] := SF4->F4_ISSST			
				If lCalSol			
					dbSelectArea("SF3")
					dbSetOrder(4)
					If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
						nPosI	:=	At (SF3->F3_ESTADO, cMVSUBTRIB)+2
						nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
						nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
						aAdd (aIEST, SubStr (cMVSUBTRIB, nPosI, nPosF))	//01 - IE_ST
					EndIf
				EndIf
				IF Empty(aPis[Len(aPis)]) .And. SF4->F4_CSTPIS=="06"
					aadd(aPisAlqZ,{SF4->F4_CSTPIS})
				Else
					aadd(aPisAlqZ,{})
				EndIf
				IF Empty(aCOFINS[Len(aCOFINS)]) .And. SF4->F4_CSTCOF=="06"
					aadd(aCofAlqZ,{SF4->F4_CSTCOF})
				Else 
					aadd(aCofAlqZ,{})
				EndIf				
								
				//Tratamento para Calcular o Desconto para  Belo Horizonte			
				nDescon += (cAliasSD2)->D2_DESCICM
				
				If (cAliasSD2)->D2_DESCON > 0 .and. nDescon == 0
					nDescon += (cAliasSD2)->D2_DESCON
				EndIf	
				
				dbSelectArea(cAliasSD2)
				dbSkip()
		    EndDo
	
		    If lQuery
		    	dbSelectArea(cAliasSD2)
		    	dbCloseArea()
		    	dbSelectArea("SD2")
		    EndIf
		
		EndIf
		
		If ExistBlock("XMLENV01")                   

			aParam := {aProd,cMensCli,cMensFis,aDest,aNota,aDupl,aDeduz,aTotal,aISSQN,aAIDF,aInterm,aRetido,aDeducao,aConstr}
		
			aParam := ExecBlock("XMLENV01",.F.,.F.,aParam)
			
			aProd		:= aParam[1]
			cMensCli	:= aParam[2]
			cMensFis	:= aParam[3]
			aDest 		:= aParam[4]
			aNota 		:= aParam[5]
			aDupl		:= aParam[6]  
			aDeduz		:= aParam[7]
			aTotal		:= aParam[8]
			aISSQN		:= aParam[9]
			aAIDF		:= aParam[10]
			aInterm	:= aParam[11]
			aRetido	:= aParam[12]				
			aDeducao	:= aParam[13]
			aConstr	:= aParam[14]
			
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Geracao do arquivo XML                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !empty(aNota)
			if len (aProd) > 0
				cString := '<rps id="rps:' + allTrim( Str( Val( aNota[02] ) ) ) + '" tssversao="2.00">'
				cString	+= assina( aDeduz, aNota, aProd, aTotal, aDest, aDeducao, aCst )
				cString += ident( aNota, aProd, aTotal, aDest, aISSQN, aAIDF, dDateCom, aCst  )
				cString	+= substit( aNota )
				cString	+= canc()
				cString	+= ativ( aProd, aISSQN )
				cString	+= prest()
				cString	+= prestacao( cMunPrest, cDescMunP, aDest, cMunPSIAFI )
				cString	+= intermediario( aInterm )
				cString	+= tomador( aDest )
				cString	+= servicos( aProd, aISSQN, aRetido, cNatOper, lNFeDesc, cDiscrNFSe, aCST, aDest[22], if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ), cF4Agreg ,nDescon,cFntCtrb,@aLeiTrp,lRecIrrf )
				cString	+= valores( aISSQN, aRetido, aTotal, aDest, if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ),aLeiTrp,lRecIrrf )
				cString	+= faturas( aDupl )
				cString	+= pagtos( aDupl,cCondPag )
				cString	+= deducoes( aProd, aDeduz, aDeducao )
				cString	+= infCompl( cMensCli, cMensFis, lNFeDesc, cDescrNFSe)
				cString	+= construcao( aConstr )
				cString += '</rps>' 
			EndIf
			
			If ExistBlock("XMLENV02")
				cString := ExecBlock("XMLENV02",.F.,.F.,cString)
			endif
			
			cString := encodeUTF8( LimpaXml( cString ) )
		endif		
		
	Else 
	
		cString := u_NFseM102( if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ), cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela, {} )[1]
	
	EndIf
	
return { cString, cNfe }

//-----------------------------------------------------------------------
/*/{Protheus.doc} assina
Função para montar a tag de assinatura do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 07.02.2012

@param	aDeduz	Array contendo as informações de deduções.
@param	aNota	Array contendo as informações de identificação sobre a nota.
@param	aProd	Array contendo as informações dos produtos.
@param	aTotal	Array contendo os valores totais do documento.
@param	aDest	Array contendo as informações de destinatário.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function assina( aDeduz, aNota, aProd, aTotal, aDest, aDeducao, aCst )
	
	local	cAssinatura	:= ""
	local	cMVOPTSIMP	:= allTrim( getMV( "MV_OPTSIMP",, "2" ) )
	local	nDeduz			:= 0
	local	nX					:= 0
	
	if( len( aDeduz ) > 0 )
		//-----------------------------------------------------------------------------------
		//- Legado
		//-----------------------------------------------------------------------------------
		for nX := 1 to len( aDeduz )
			if( aDeduz[nX][1] == "1" )				// C6_TPDEDUZ == "1" (Percentual)
				nDeduz += aDeduz[nX][8]
			elseIf( aDeduz[nX][1] == "2" )
				nDeduz += aDeduz[nX][9]				// C6_TPDEDUZ == "2" (Valor)
			else
				nDeduz += 0							// C6_TPDEDUZ == "" (Sem valor de deducao)
			endIf
		next
	else
		//-----------------------------------------------------------------------------------
		//- Provedor DSFNet: Tratamento para considerar o valor das deducoes na assinatura 
		//-----------------------------------------------------------------------------------
		if( alltrim( if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) ) $ Fisa022Cod( "001" ) )
			for nX := 1 to len( aDeducao )
				nDeduz += aDeducao[nX][1]
			next
		endIf
	endIf
	
	cAssinatura	+= strZero( val( if( type( "oSigamatX" ) == "U",SM0->M0_INSCM,oSigamatX:M0_INSCM ) ), 11 ) 
	cAssinatura	+= "NF   "
	cAssinatura	+= strZero( val( aNota[02] ), 12 )       
	cAssinatura	+= dToS( aNota[03] )
	
	if aCST[1][1] =	"05"	
		cAssinatura += "G "	
	Else	
		do case
			case aTotal[3] $ "2" // 2 - Fora, sempre "Nao Incidente no Municipio"
				cAssinatura += "E "			
		    case aTotal[3] $ "3"
				cAssinatura += "C "
			case aTotal[3] $ "4"
				cAssinatura += "F "
		    case aTotal[3] $ "5"
				cAssinatura += "K "
		    case aTotal[3] $ "6"
				cAssinatura += "K "
		    case aTotal[3] $ "7"
				cAssinatura += "N "
		    case aTotal[3] $ "8"
				cAssinatura += "M "		
			otherwise
				if cMVOPTSIMP == "1"
					cAssinatura += "H "
				else
					cAssinatura += "T "
				endif
		endcase
	EndIf
	cAssinatura += "N" 
	cAssinatura += iif( ( aProd[1][20] ) == '1', "S", "N" )
	cAssinatura += strZero( ( aTotal[2] - nDeduz ) * 100, 15 )
	cAssinatura += strZero( nDeduz * 100, 15 )
	
	cAssinatura += allTrim( strZero( val( aProd[1][19] ), 10 ) )
	
	if( !empty( aDest[26] ) .and. empty( aDest[01] ) )
		cAssinatura += "99999999007790"	//Exterior DSFNET
	elseIf( !empty( aDest[01] ) )
		cAssinatura += allTrim( strZero( val( aDest[01] ),14 ) )
	else  
		cAssinatura += "00077777777777"	//consumidor não identificado DSFNET
	endif
	
	cAssinatura := allTrim( lower( sha1( allTrim( cAssinatura ), 2 ) ) )
	cAssinatura := '<assinatura>' + cAssinatura + '</assinatura>'
	
return cAssinatura

//-----------------------------------------------------------------------
/*/{Protheus.doc} ident
Função para montar a tag de identificação do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aNota	Array com informações sobre a nota.
@param	aProd	Array com informações sobre os serviços da nota.
@param	aTotal	Array com informações sobre os totais da nota.
@param	aDest	Array com informações sobre o tomador da nota.
@param	aAIDF	Array com informações sobre o AIDF.
@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function ident( aNota, aProd, aTotal, aDest, aISSQN, aAIDF, dDateCom, aCST )
	
	local	cMVOPTSIMP	:= allTrim( getMV( "MV_OPTSIMP",, "2" ) )
	local	cMVREGIESP	:= getMV( "MV_REGIESP",, "" )
	local	cString		:= ""
	
	cString	:= "<identificacao>"
	
	cString	+= "<dthremissao>" + subStr( dToS( aNota[3] ), 1, 4 ) + "-" + subStr( dToS( aNota[3] ), 5, 2 ) + "-" + subStr( Dtos( aNota[3] ), 7, 2 ) + 'T' + aNota[9] + "</dthremissao>"
	If UsaAidfRps(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ))
		cString	+= "<serierps>" + allTrim( aAIDF[2] ) + "</serierps>"
		cString	+= "<numerorps>" + allTrim( aAIDF[3]) + "</numerorps>"
	ElseIf (if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ "3303401") // Tratamento específico para Nova Friburgo - RJ
		cString	+= "<serierps>" + allTrim( aNota[1] ) + "</serierps>"
		cString	+= "<numerorps>" + allTrim( aNota[2] ) + "</numerorps>"
	Else
		cString	+= "<serierps>" + allTrim( aNota[1] ) + "</serierps>"
		cString	+= "<numerorps>" + allTrim( str( val( aNota[2] ) ) ) + "</numerorps>"
	EndIf
	cString	+= "<tipo>1</tipo>" // Chumbado pois tanto ABRASF como DSFNET, utilizam esta tag como tipo RPS (1)
	cString	+= "<situacaorps>1</situacaorps>" // Chumbado pois tanto ABRASF como DSFNET, utilizam esta tag como Normal (1)
	cString	+= "<tiporecolhe>" + iif( allTrim( aProd[1][20] ) == "1", "2", "1" ) + "</tiporecolhe>"
	
	do case
       case aNota[4] $ "DB" 
       	cString += '<tipooper>4</tipooper>' //Devolução/Simples remessa;
       case aProd[1][29] > 0 
       	cString += '<tipooper>2</tipooper>' //Com dedução/Materiais;
		case aISSQN[1][2] <= 0 
       	cString += '<tipooper>3</tipooper>' //Imune/Isenta de ISSQN;
       otherWise
       	cString += '<tipooper>1</tipooper>' //Sem dedução
    endcase
	
	if aCST[1][1] =	"05"
		cString += "<tipotrib>7</tipotrib>"
	Else
		do case
			case aTotal[3] $ "2" // 2 - Fora do município, mesmo quando cMVOPTSIMP == "1"
				cString += "<tipotrib>2</tipotrib>"
				
		    case aTotal[3] $ "3"	//Isento
		    	cString += "<tipotrib>1</tipotrib>"	    	
	
			case aTotal[3] $ "4"		//Imune
				cString += "<tipotrib>3</tipotrib>"	
		    case aTotal[3] $ "5"
				cString += "<tipotrib>4</tipotrib>"
				
		    case aTotal[3] $ "6"
				cString += "<tipotrib>12</tipotrib>"
		    case aTotal[3] $ "7"
				cString += "<tipotrib>5</tipotrib>"
		    case aTotal[3] $ "8"
				cString += "<tipotrib>11</tipotrib>"
			otherWise
				if cMVOPTSIMP == "1"
					cString += "<tipotrib>8</tipotrib>"
				else
					cString += "<tipotrib>6</tipotrib>"
				EndIf
		endcase
	EndIf
	
	If !empty( alltrim(aProd[1][37]) ) .And. alltrim(aProd[1][37]) == "1" 
		cString += "<localServ>1</localServ>"		// 1 - Dentro do municipio
	else
		cString += "<localServ>2</localServ>"		// 1 - Dentro do municipio
	EndIf

	if !empty(cMVREGIESP)
		cString += "<regimeesptrib>" + cMVREGIESP + "</regimeesptrib>"
	endif
	
	cString += "<formpagto>" + alltrim( aNota[10] ) + "</formpagto>"
	cString += "<deveissmunprestador>" +if(aTotal[3] $ "1","1","2")+ "</deveissmunprestador>"
	
	//-----------------------------------------------------------------------------------------------
	//- Tratamento da DATA DE COMPETENCIA DO RPS
	//- Especifico para os municipios de: Vitoria-ES e Varginha-MG
	//-----------------------------------------------------------------------------------------------
	If (if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ "3205309-3170701")
		IF dDateCom == Date() .Or. Empty(dDateCom)  
			cString += "<competenciarps>"+ subStr( dToS( aNota[3] ), 1, 4 ) + "-" + subStr( dToS( aNota[3] ), 5, 2 ) + "-" + subStr( Dtos( aNota[3] ), 7, 2 ) + "</competenciarps>"
		Else 
			cString += "<competenciarps>"+ subStr( dToS( dDateCom ), 1, 4 ) + "-" + subStr( dToS( dDateCom ), 5, 2 ) + "-" + subStr( Dtos( dDateCom ), 7, 2 ) + "</competenciarps>"
		Endif 		
	Endif
	
	If UsaAidfRps(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ))
		cString += "<codverificacao>" +aAIDF[1]+ "</codverificacao>"		
	Endif

	cString	+= "</identificacao>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} substit
Função para montar a tag de substituição do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aNota	Array com informações sobre a nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function substit( aNota )
	
	local	cString	:= ""
	
	if !empty( allTrim( aNota[8] ) + allTrim( aNota[7] ) )
		
		cString	+= "<substituicao>"
		
		cString	+= "<serierps>" + allTrim(aNota[8]) + "</serierps>"
		cString	+= "<numerorps>" + allTrim(str( val(aNota[7]))) + "</numerorps>"
		cString	+= "<idnfse>" + aNota[8] + allTrim(aNota[7]) + "</idnfse>"
		cString	+= "<tipo>1</tipo>"
		
		cString	+= "</substituicao>"
		
	endif
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} canc
Função para montar a tag de cancelamento do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function canc()
	
	local	cString	:= ""
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} ativ
Função para montar a tag de atividade do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aProd	Array contendo as informações sobre os serviços da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function ativ( aProd, aISSQN )
	
	local	cString	:= ""
	Local nAliq		:= 0
	Local nCont		:= 0
	
	FOR nCont := 1 to len(aISSQN)
		IF(aISSQN[nCont][2] <> 0)
			nAliq := aISSQN[nCont][2]
		ENDIF
	Next nCont
	
	// Tratamento para gerar aliquota quando houver o abtimento total dos itens
	IF(nAliq == 0 .AND. SF3->F3_ISSSUB > 0 .AND. ! EMPTY(SF3->F3_ISSSUB)  )
		nAliq := SF3->F3_ALIQICM
	EndIf
	
	if !empty( allTrim( aProd[1][19] ) ) 
		
		cString	+= "<atividade>"
	
		cString	+= "<codigo>" + allTrim( aProd[1][19] ) + "</codigo>"
		
		cString	+= "<aliquota>" + convType( nAliq, 7, 4) + "</aliquota>"
		
		cString	+= "</atividade>"
		
	endif
	
return cString


//-----------------------------------------------------------------------
/*/{Protheus.doc} prest
Função para montar a tag de prestador do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function prest()
	
	local	aTemp			:= {}
	
	local	cMVINCECUL		:= allTrim( getMV( "MV_INCECUL",, "2" ) )
	local	cMVOPTSIMP		:= allTrim( getMV( "MV_OPTSIMP",, "2" ) )
	local	cMVNUMPROC		:= allTrim( getMV( "MV_NUMPROC",, " " ) )
	Local   cEmail			:= allTrim( getMV( "MV_EMAILPT",, " " ) )
	local	cMVDTINISI		:= allTrim( getMV( "MV_DTINISI",, " " ) )
	local	cString			:= ""
	
	if( type( "oSigamatX" ) == "U" )
		aTemp			:= fisGetEnd( SM0->M0_ENDCOB )
		
		cString	+= "<prestador>"
		cString	+= "<inscmun>" + allTrim( SM0->M0_INSCM ) + "</inscmun>"
		cString	+= "<cpfcnpj>" + allTrim( SM0->M0_CGC )  + "</cpfcnpj>"
		cString	+= "<razao>" + allTrim( SM0->M0_NOMECOM ) + "</razao>"
		cString	+= "<fantasia>" + allTrim( SM0->M0_NOME ) + "</fantasia>"
		cString	+= "<codmunibge>" + allTrim( SM0->M0_CODMUN ) + "</codmunibge>"

		if !Empty(SM0->M0_CIDCOB)
			cString	+= "<cidade>" + allTrim( SM0->M0_CIDCOB ) + "</cidade>"
		endif

		cString	+= "<uf>" + allTrim( SM0->M0_ESTCOB ) + "</uf>"

		if !Empty(cEmail)
			cString	+= "<email>" + cEmail + "</email>"
		endif

		cString	+= "<ddd>" + allTrim( str( fisGetTel( SM0->M0_TEL )[2], 3 ) ) + "</ddd>"
		cString	+= "<telefone>" + allTrim( str( fisGetTel( SM0->M0_TEL )[3], 15 ) ) + "</telefone>"
		cString	+= "<simpnac>" + cMVOPTSIMP + "</simpnac>"
		
		//-------------------------------------------------------------------------------------------
		//- Especifico para o municipio de Varginha-MG
		//- Tratamento no preenchimento da DATA DE ADESAO DO SIMPLES NACIONAL
		//-------------------------------------------------------------------------------------------
		if( !empty( cMVDTINISI ) .and. allTrim( SM0->M0_CODMUN ) $ "3170701" )
			cMVDTINISI := cTOd( cMVDTINISI )
			cMVDTINISI := strZero( year( cMVDTINISI ),4 ) + "-" +;
						  strZero( month( cMVDTINISI ),2 ) + "-" +;
						  strZero( day( cMVDTINISI ),2 ) + "T00:00:00"

			cString	+= "<dtinisi>" + cMVDTINISI + "</dtinisi>"
		endIf
		
		cString	+= "<incentcult>" + cMVINCECUL + "</incentcult>"
		cString	+= "<numproc>" + cMVNUMPROC + "</numproc>"
		cString	+= "<logradouro>" + allTrim( ClearTLogr( allTrim( aTemp[ 1 ] ) ) ) + "</logradouro>"
		cString	+= "<numend>" + allTrim( aTemp[3] ) + "</numend>"

		if !empty( allTrim( aTemp[4] ) )
			cString	+= "<compleend>" + allTrim( aTemp[4] ) + "</compleend>"
		elseif !Empty(SM0->M0_COMPCOB)
			cString	+= "<compleend>" + allTrim( SM0->M0_COMPCOB ) + "</compleend>"	
		endif

		cString	+= "<bairro>" + allTrim( SM0->M0_BAIRCOB ) + "</bairro>"

		If (allTrim( SM0->M0_CODMUN ) $ "3526902") 
			cString    += '<tplogradouro>' + RetTipoLogr(allTrim(aTemp[1])) + '</tplogradouro>' //-- 2-Rua - Nao Obrigat.
		EndIf

		cString	+= "<cep>" + allTrim( SM0->M0_CEPCOB ) + "</cep>"
		cString	+= "</prestador>"
	else
		aTemp			:= fisGetEnd( oSigamatX:M0_ENDCOB )
		
		cString	+= "<prestador>"
		
		cString	+= "<inscmun>" + allTrim( oSigamatX:M0_INSCM ) + "</inscmun>"
		cString	+= "<cpfcnpj>" + allTrim( oSigamatX:M0_CGC )  + "</cpfcnpj>"
		cString	+= "<razao>" + allTrim( oSigamatX:M0_NOMECOM ) + "</razao>"
		cString	+= "<fantasia>" + allTrim( oSigamatX:M0_NOME ) + "</fantasia>"
		cString	+= "<codmunibge>" + allTrim( oSigamatX:M0_CODMUN ) + "</codmunibge>"
		
		if !Empty(oSigamatX:M0_CIDCOB)
			cString	+= "<cidade>" + allTrim( oSigamatX:M0_CIDCOB ) + "</cidade>"
		endif
		
		cString	+= "<uf>" + allTrim( oSigamatX:M0_ESTCOB ) + "</uf>"
		
		if !Empty(cEmail)
			cString	+= "<email>" + cEmail + "</email>"
		endif
		
		cString	+= "<ddd>" + allTrim( str( fisGetTel( oSigamatX:M0_TEL )[2], 3 ) ) + "</ddd>"
		cString	+= "<telefone>" + allTrim( str( fisGetTel( oSigamatX:M0_TEL )[3], 15 ) ) + "</telefone>"
		cString	+= "<simpnac>" + cMVOPTSIMP + "</simpnac>"
		
		if( !empty( cMVDTINISI ) .and. allTrim( SM0->M0_CODMUN ) $ "3170701" )
			cMVDTINISI := cTOd( cMVDTINISI )
			cMVDTINISI := strZero( year( cMVDTINISI ),4 ) + "-" +;
						  strZero( month( cMVDTINISI ),2 ) + "-" +;
						  strZero( day( cMVDTINISI ),2 ) + "T00:00:00"

			cString	+= "<dtinisi>" + cMVDTINISI + "</dtinisi>"
		endIf
		
		cString	+= "<incentcult>" + cMVINCECUL + "</incentcult>"
		cString	+= "<numproc>" + cMVNUMPROC + "</numproc>"
		cString	+= "<logradouro>" + allTrim( ClearTLogr( allTrim( aTemp[ 1 ] ) ) ) + "</logradouro>"
		cString	+= "<numend>" + allTrim( aTemp[3] ) + "</numend>"
		
		if !empty( allTrim( aTemp[4] ) )
			cString	+= "<compleend>" + allTrim( aTemp[4] ) + "</compleend>"
		elseif !Empty(oSigamatX:M0_COMPCOB)
			cString	+= "<compleend>" + allTrim( oSigamatX:M0_COMPCOB ) + "</compleend>"	
		endif
		
		cString	+= "<bairro>" + allTrim( oSigamatX:M0_BAIRCOB ) + "</bairro>"
		
		If (allTrim( oSigamatX:M0_CODMUN ) $ "3526902") 
			cString    += '<tplogradouro>' + RetTipoLogr(allTrim(aTemp[1])) + '</tplogradouro>' //-- 2-Rua - Nao Obrigat.
		EndIf
		
		cString	+= "<cep>" + allTrim( oSigamatX:M0_CEPCOB ) + "</cep>"
		cString	+= "</prestador>"
	endIf
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} prestacao
Função para montar a tag de prestação do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	cMunPrest	Código de município IBGE da prestação do serviço.
@param	cDescMunP	Nome do município da prestação do serviço.
@param	aDest		Array contendo as informações sobre o tomador da nota.
@param	cMunPSIAFI	Código de município SIAFI da prestação do serviço.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function prestacao( cMunPrest, cDescMunP, aDest, cMunPSIAFI )
	
	Local aTabIBGE		:= {}
	Local aMvEndPres	:= &(SuperGetMV("MV_ENDPRES",,"{,,,,,}")) //Parametro que aponta para o campo da SC5 para pegar as informações da prestação do serviço
																	  //informar os campos nesta sequencia (Logradouro,Numero,Complemento,Bairro,Cep)
	Local cString		:= ""
	Local cMvNFSEINC	:= SuperGetMV("MV_NFSEINC", .F., "") // Parametro que aponta para o campo da SC5 com Código do município de Incidência 
	Local cNFSEINC		:= ""
	Local cIbge			:= ""
	Local cLogradPres	:= "" //Logradouro da prestação
	Local cNumEndPres	:= "" //Número do logradouro da prestação
	Local cCompEndPres	:= "" //Complemento do logradouro da prestação
	Local cBairroPres	:= "" //Bairro do logradouro da prestação
	Local cCepPres		:= "" //Cep da prestação
	Local cPaisPres		:= "" //Pais da prestação
	Local cUFPres 		:= "" //Estado da prestação
	Local nScan			:= 0
	Local aEndPres		:= {}
	Local lIsRpsLOJA 	:= .F.
		
	default	cDescMunP	:= ""
	default	cMunPrest	:= ""
	default	cMunPSIAFI	:= ""
	
	aTabIBGE	:= spedTabIBGE()
	
	//Verifica se é NFS-e originada do SIGALOJA (Varejo)
	lIsRpsLOJA := IsRPSLOJA(@aEndPres)
	
	If lIsRpsLOJA
		iIf( !Empty(aEndPres[01]), cLogradPres 	:= aEndPres[01] , Nil ) //01-Logradouro da prestação do serviço
		iIf( !Empty(aEndPres[02]), cNumEndPres 	:= aEndPres[02] , Nil ) //02-Número do logradouro da prestação do serviço
		iIf( !Empty(aEndPres[03]), cCompEndPres := aEndPres[03] , Nil ) //03-Complemento do logradouro da prestação do serviço
		iIf( !Empty(aEndPres[04]), cBairroPres 	:= aEndPres[04] , Nil ) //04-Bairro da prestação do serviço
		iIf( !Empty(aEndPres[05]), cUFPres 		:= aEndPres[05] , Nil ) //05-Estado da prestação do serviço
		iIf( !Empty(aEndPres[06]), cCepPres 	:= aEndPres[06] , Nil ) //06-CEP da prestação do serviço
		iIf( !Empty(aEndPres[07]), cMunPrest 	:= aEndPres[07] , Nil ) //07-Município da prestação do serviço
		iIf( !Empty(aEndPres[08]), cDescMunP 	:= aEndPres[08] , Nil ) //08-Descrição do Município da prestação do serviço
		iIf( !Empty(aEndPres[09]), cPaisPres 	:= aEndPres[09] , Nil ) //09-País da prestação do serviço
	Else
		If aMvEndPres <> nil
			If len(aMvEndPres)== 5
				Aadd(aMvEndPres,"") // Adiciona a 6° posição
			ElseIf len(aMvEndPres) < 5
				aMvEndPres := {,,,,,} // o parâmetro é obrigado a conter 5 posições	no mínimo
			EndIf
		EndIf

		If SC5->(ColumnPos("C5_ESTPRES")) > 0
			cUFPres := IIF( !Empty(SC5->C5_ESTPRES), SC5->C5_ESTPRES, "" )
		EndIf

		If ValType(aMvEndPres) <> "U" // Exemplo de preenchimento do parâmetro {'C5_ENDPRES','C5_NUMPRES','C5_COMPPRE','C5_BAIPRES','C5_CEPPRES','C5_CODPRES'}

			cLogradPres	:= AllTrim(IIf(!Empty(aMvEndPres[01]) .and. SC5->(FieldPos(aMvEndPres[01])) > 0 , SC5->&(aMvEndPres[01]),"")) //Logradouro da prestação
			cNumEndPres	:= AllTrim(IIf(!Empty(aMvEndPres[02]) .and. SC5->(FieldPos(aMvEndPres[02])) > 0 , SC5->&(aMvEndPres[02]),"")) //Número do logradouro da prestação
			cCompEndPres:= AllTrim(IIF(!Empty(aMvEndPres[03]) .and. SC5->(FieldPos(aMvEndPres[03])) > 0 , SC5->&(aMvEndPres[03]),"")) //Complemento do logradouro da prestação
			cBairroPres	:= AllTrim(IIf(!Empty(aMvEndPres[04]) .and. SC5->(FieldPos(aMvEndPres[04])) > 0 , SC5->&(aMvEndPres[04]),"")) //Bairro do logradouro da prestação
			cCepPres	:= AllTrim(IIf(!Empty(aMvEndPres[05]) .and. SC5->(FieldPos(aMvEndPres[05])) > 0 , SC5->&(aMvEndPres[05]),"")) //Cep da prestação
			If len(aMvEndPres) > 5 //parametro padrao tinha 5 posições, verificado tamanho para não dar erro de estouro de array
				cPaisPres	:= AllTrim(IIf(!Empty(aMvEndPres[06]) .and. SC5->(FieldPos(aMvEndPres[06])) > 0 , SC5->&(aMvEndPres[06]),""))//Pais da prestação
			EndIf
		EndIf

	EndIf

	If Len(alltrim(cMunPrest)) <= 5		
		nScan	:= aScan( aTabIBGE, { | x | x[1] == aDest[9] } )
		if nScan <= 0			
			nScan		:= aScan( aTabIBGE, { | x | x[4] == aDest[9] } )			
			cMunPrest	:= aTabIBGE[nScan][1] + cMunPrest			
		else			
			cMunPrest	:= aTabIBGE[nScan][4] + cMunPrest			
		endif		
	EndIf
	
	if empty( cMunPrest )
		cMunPrest	:= allTrim(aDest[7])
	endif

	if empty( cMunPSIAFI )
		cIbge := allTrim(SUBSTR(cMunPrest,3,Len(cMunPrest)))
		CC2->(DbSetOrder(1))  // CC2_FILIAL+CC2_EST+CC2_CODMUN
		If  CC2->(DbSeek(xFilial("CC2")+ allTrim(cUFPres)+ cIbge)) 
		  	cMunPSIAFI	:=	alltrim(CC2->CC2_CDSIAF)
			 
			//aDest[18]	:=	alltrim(CC2->CC2_CDSIAF)
		ElseIf CC2->(DbSeek(xFilial("CC2")+ aDest[9] + cIbge)) 
			cMunPSIAFI	:= alltrim(CC2->CC2_CDSIAF) 
		Elseif aDest[9] =='EX' // caso o cliente não tenha cadastrado EX no campo CC2_EST pega do campo  A1/A2_CODSIAF
		 	cMunPSIAFI	:= allTrim(aDest[18]) 
		Else	
			cMunPSIAFI	:= allTrim(aDest[18]) 
		Endif
	endif
	
	cString	+= "<prestacao>"	
	cString	+= "<serieprest>99</serieprest>"
	cLogradPres := IIf(!Empty(Alltrim(cLogradPres)),Alltrim(cLogradPres),IIf(!Empty(aDest[3]),allTrim(aDest[3]),""))
	If !Empty( alltrim( cLogradPres ) )
		cString	+= "<logradouro>" + allTrim( ClearTLogr( cLogradPres ) ) + "</logradouro>"
	EndIf
	cNumEndPres := IIf(!Empty(Alltrim(cNumEndPres)),Alltrim(cNumEndPres), allTrim(aDest[4]))
	If !Empty( alltrim( cLogradPres ) )
		cString	+= "<numend>" + cNumEndPres + "</numend>"
	EndIf

	If !Empty( alltrim( cCompEndPres ) )
		cString	+= "<complend>" + allTrim( cCompEndPres ) + "</complend>"
	EndIf
	if !empty( allTrim( cMunPrest ) )
		cString	+= "<codmunibge>" + allTrim( cMunPrest ) + "</codmunibge>"
	endif
	if !Empty( allTrim (cMvNFSEINC) ) .And. !lIsRpsLOJA
		If SC5-> ( FieldPos (cMvNFSEINC)  ) > 0 
			cNFSEINC := allTrim(SC5-> & (cMvNFSEINC) )
			cString	+= "<codmunibgeinc>"+ allTrim (cNFSEINC) +"</codmunibgeinc>"
		Endif		
	Else
		if !empty( allTrim (cMunPrest) )
			cString	+= "<codmunibgeinc>"+ allTrim (cMunPrest) +"</codmunibgeinc>"  
		endif		
	Endif	
	if !empty( allTrim( cMunPSIAFI ) )
		cString	+= "<codmunsiafi>" + allTrim( cMunPSIAFI ) + "</codmunsiafi>"
	endif
	if !empty( allTrim( cDescMunP ) )
		cString	+= "<municipio>" + allTrim( cDescMunP ) + "</municipio>"
	Else
		cString	+= "<municipio>" + IIf(!Empty(aDest[8]),allTrim( aDest[8] ),"") + "</municipio>"
	EndIf

	cBairroPres := IIf(!Empty(Alltrim(cBairroPres)),Alltrim(cBairroPres),IIf(!Empty(aDest[6]),allTrim( aDest[6] ),""))
	If !Empty( alltrim( cBairroPres ) )
		cString	+= "<bairro>" + cBairroPres + "</bairro>"
	EndIf
	
	cUFPres := IIF (!Empty(cUFPres), Alltrim(cUFPres), allTrim(aDest[9]) )
	cString	+= "<uf>" + cUFPres + "</uf>" 

	//Se o campo de país não estiver preenchido, a tag é preenchida com o país do tomador
	If ValType(cPaisPres) == 'C' .And. !Empty(cPaisPres)
		If (len(alltrim(cPaisPres)) < 4) // Se estiver preenchido com a consulta padrão da tabela de paises, haverão 3 dígitos, então a função Posicione() pega o código e faz uma busca na tabela SYA retornando o código bacem do país.
			cPaisPres := Posicione("SYA",1,xFilial("SYA")+cPaisPres,"YA_SISEXP")
			cString	+= "<codpais>" + cPaisPres + "</codpais>"
		Else
			cString	+= "<codpais>" + cPaisPres + "</codpais>" //Se o cliente digitar o código BACEN, haverão 4 dígitos, desta maneira será levado o conteúdo do campo.
		EndIf
	Else
		cPaisPres := IIf(!Empty(aDest[11]),allTrim(aDest[11]),"")
		If !Empty( alltrim( cPaisPres ) )
			cString	+= "<codpais>" + cPaisPres + "</codpais>"
		EndIf
	EndIf

	cCepPres := IIf(!Empty(Alltrim(cCepPres)),Alltrim(cCepPres),IIf(!Empty(aDest[10]),allTrim( aDest[10] ),"" ))
	If !Empty( alltrim( cCepPres ) )
		cString	+= "<cep>" + cCepPres + "</cep>"
	EndIf
	
	cTipoLograd := IIf(!Empty(Alltrim(cLogradPres)),RetTipoLogr(Alltrim(cLogradPres)),IIf(!Empty(aDest[3]),RetTipoLogr(allTrim(aDest[3])),"2"))
	If !Empty( alltrim( cTipoLograd ) )
		cString	+= "<tipologr>" + cTipoLograd + "</tipologr>"
	EndIf
	
	cString	+= "</prestacao>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} intermediario
Função para montar a tag de intermediário do XML de envio de NFS-e ao TSS.

@author Karyna Martins
@since 24.04.2015

@param	aInterm	Array com as informações do intermediario da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function intermediario( aInterm )

Local cString	:= "" 

Local lSemInt:= .F.

If len(aInterm) > 0

	If Empty(aInterm[1]) .and. Empty(aInterm[2]) .and. Empty(aInterm[3])
		lSemInt:=.T.
	EndIf
	  
	// Monta a tag de intermediário com as informações do pedido
	If !lSemInt 
	
		cString	+= "<intermediario>"
			cString	+= "<razao>"+aInterm[1]+"</razao>"
			cString	+= "<cpfcnpj>"+aInterm[2]+"</cpfcnpj>"
			cString	+= "<inscmun>"+aInterm[3]+"</inscmun>"	
		cString	+= "</intermediario>"
		
	EndIf

EndIf
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} tomador
Função para montar a tag de tomador do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aDest	Array com as informações do tomador da nota.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
Static Function tomador( aDest )
	
	Local cString	:= "" 
	Local cCodTom	:= ""
	Local lSemTomador:= .F.
	Local aIntermed		:= {}
	local cMunPSIAFI:= ""
	
	If Empty(aDest[1]) .and. Empty(aDest[2])
		lSemTomador:=.T.
	EndIf
	  
	cMunPSIAFI:= aDest[18]
	if empty(cMunPSIAFI)
		cIbge := allTrim(aDest[7])
		CC2->(DbSetOrder(1))  // CC2_FILIAL+CC2_EST+CC2_CODMUN
		If CC2->(DbSeek(xFilial("CC2")+ aDest[9] + cIbge))
			cMunPSIAFI	:=	alltrim(CC2->CC2_CDSIAF)
	   Endif
	Endif			
	cString	+= "<tomador>"
	If !lSemTomador 		
		
		if aDest[17] <> "ISENTO" .And. !empty( allTrim( aDest[17] ) )
			cString	+= "<inscmun>" + allTrim( aDest[17] ) + "</inscmun>"
		else
			cString	+=  "<inscmun></inscmun>"	
		endif
		
		cString	+= "<cpfcnpj>" + allTrim( aDest[1] ) + "</cpfcnpj>"
		If !Empty(allTrim( aDest[26] ))
			cString	+= "<identificador>"+ allTrim( aDest[26] ) +"</identificador>"
			//retirada tag doctomestra pois será descontinuada do TSS, já que a tag identificador tem o mesmo propósito
		Endif
		cString	+= "<razao>" + allTrim( aDest[2] ) + "</razao>"
		
		If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ '3550308-3170701'			
			cString	+= "<tipologr>"+ retTipoLogr( aDest[ 3 ] ) +"</tipologr>"	
		Else
			cString	+= "<tipologr>2</tipologr>"
		EndIf
		cString	+= "<logradouro>" + allTrim( ClearTLogr( aDest[ 3 ] ) ) + "</logradouro>"
		cString	+= "<numend>" + allTrim( aDest[4] ) + "</numend>"
		if !empty( allTrim( aDest[5] ) )
			cString	+= "<complend>" + allTrim( aDest[5] ) + "</complend>"
		endif
		cString	+= "<tipobairro>1</tipobairro>"
		cString	+= "<bairro>" + allTrim( aDest[6] ) + "</bairro>"
		
		If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ "5208707" .And. !empty( allTrim( aDest[25] ) )
			cCodTom := aDest[25] // SA1->A1_OUTRMUN
		Else
			cCodTom := aDest[07] // SA1->A1_COD_MUN
		EndIf
		If Len( cCodTom ) <= 5 .And. (!(cCodTom $ '99999').Or. (cCodTom $ '99999' .And. if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ '3550308|3552205|4205407|3300704|3156700|4115200|4208203|4204202'))
			cCodTom := UfIBGEUni(aDest[09]) + cCodTom
		EndIf
		
		if !empty( allTrim( aDest[7] ) )
			cString	+= "<codmunibge>" + cCodTom + "</codmunibge>"
		endif
		if !empty( allTrim( cMunPSIAFI) )
			cString	+= "<codmunsiafi>" + allTrim( cMunPSIAFI) + "</codmunsiafi>"
		endif
		cString	+= "<cidade>" + allTrim( aDest[8] ) + "</cidade>"
		cString	+= "<uf>" + allTrim( aDest[9] ) + "</uf>"
		cString	+= "<cep>" + allTrim( aDest[10] ) + "</cep>"
		If !Empty(Alltrim(aDest[16]))
			cString	+= "<email>" + allTrim( aDest[16] ) + "</email>"
		EndIf	

		cString	+= "<ddd>" + allTrim( str( fisGetTel( aDest[13] )[2], 3 ) ) + "</ddd>"
		cString	+= "<telefone>" + allTrim( str( fisGetTel( aDest[13] )[3], 15 ) ) + "</telefone>"
		cString	+= "<codpais>" + allTrim( aDest[11] ) + "</codpais>"
		cString	+= "<nomepais>" + allTrim( aDest[12] ) + "</nomepais>"
		cString	+= "<estrangeiro>" + iif( allTrim( aDest[9] ) == "EX", "1", "2" ) + "</estrangeiro>"
		If Empty (aDest[16])
			cString += '<notificatomador>2</notificatomador>'
		Else
			cString += '<notificatomador>1</notificatomador>'
		EndIf
		If !Empty(aDest[14])
			cString	+= "<inscest>" + allTrim( aDest[14] ) + "</inscest>"	
		EndIf
		if SA1->(FieldPos("A1_TPNFSE")) > 0 
			cString += '<situacaoespecial>'+AllTrim(SA1->A1_TPNFSE)+'</situacaoespecial>'
		else
			cString += '<situacaoespecial>0</situacaoespecial>'
		endif
		If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308" .And. Len(aDest) > 21
			If !Empty(aDest[22]) .And. !Empty(aDest[23])
				If FindFunction("HS_NFEINTE")
					aIntermed := HS_NFEINTE(aDest[22],aDest[23])
					If Len(aIntermed) > 0 .And. !Empty(aIntermed[1])
						cString += '<CPFCNPJIntermediario>'+AllTrim(aIntermed[1])+'</CPFCNPJIntermediario>'
						cString += '<InscricaoMunicipalIntermediario>'+(aIntermed[2])+'</InscricaoMunicipalIntermediario>'
						cString += '<ISSRetidoIntermediario>1</ISSRetidoIntermediario>'
					EndIf
					
				EndIf
			EndIf
		EndIf
		
		if SA1->(FieldPos("A1_TPESSOA")) > 0 .And. !Empty(SA1->A1_TPESSOA)
			cString += '<tipopessoa>'+ TipoPes(AllTrim(SA1->A1_TPESSOA))+'</tipopessoa>'
		EndIf		
	EndIf
	
	cString	+= "</tomador>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} servicos
Função para montar a tag de serviços do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 19.01.2012

@param	aProd		Array contendo as informações dos produtos da nota.
@param	aISSQN		Array contendo as informações sobre o imposto.
@param	aRetido		Array contendo as informações sobre impostos retidos.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function servicos( aProd, aISSQN, aRetido, cNatOper, lNFeDesc, cDiscrNFSe,aCST, cTpPessoa, cCodMun, cF4Agreg, nDescon, cFntCtrb,aLeiTrp,lRecIrrf)	
	
	Local	aCofinsXML	:= { 0, 0, {} }
	Local	aCSLLXML	:= { 0, 0, {} }
	Local	aINSSXML	:= { 0, 0, {} }
	Local	aIRRFXML	:= { 0, 0, {} }
	Local	aISSRet		:= { 0, 0, 0, {} }
	Local	aPisXML		:= { 0, 0, {} }
	
	Local cString	:= ""
	Local cCargaTrb	:= ""
	Local cCrgTrib	:= ""
	
	Local	nOutRet		:= 0
	Local	nScan		:= 0
	Local	nValLiq		:= 0
	Local	nX			:= 0
	Local  nY			:= 0
	Local  nAliqISs	:= 0
	Local  nISSQN		:= 0

	Local	cMVOPTSIMP	:= AllTrim( getMV( "MV_OPTSIMP",, "2" ) ) // Verifica se o prestador eh optante do simples
	Local	nRatVPis    := 0
	Local	nRatVcofins := 0
	Local  nRatVIRRF   := 0
	Local	nRatVCsll   := 0
	Local  aRestImp    := {}	
	Local   cPercTrib   := "0"
	Local  lIntegHtl   := SuperGetMv("MV_INTHTL",, .F.) //Integracao via Mensagem Unica - Hotelaria
	local cCampoDiscDed := alltrim(SuperGetMV("MV_DISCDED",," ")) //Campo do cliente customizado para informar a descricao do valor da Deducao 
	
	Default nDescon		:= 0
	Default cFntCtrb	:= ""
	Default aLeiTrp		:= {}
	Default cTpPessoa	:= ""
	Default cCodMun	:= ""
	Default cF4Agreg	:= ""
	
	Default lRecIrrf	:= .T.
	cString	+= "<servicos>"
	
	// Tratando o abatimento para quando houver mais de um item de serviço
	If len(aISSQN) > 1
		For nY := 1  to len(aISSQN)
			If 	aISSQN[nY][2] > 0
				nAliqISs := aISSQN[nY][2]
				nISSQN	  += aISSQN[nY][3]
			EndIf
		Next nY
	Else
		nAliqISs := aISSQN[1][2]
		nISSQN	 := aISSQN[1][3]		
	EndIF
	
	// Tratamento para gerar aliquota quando houver o abtimento total dos itens
	IF(nAliqISs == 0 .AND. SF3->F3_ISSSUB > 0 .AND. ! EMPTY(SF3->F3_ISSSUB)  )
		nAliqISs := SF3->F3_ALIQICM
	EndIf
	
	for nX := 1 to len( aProd )
		
		nScan := aScan(aRetido,{|x| x[1] == "ISS"})
		If nScan > 0
			aIssRet[1] += aRetido[nScan][3]
			aIssRet[2] += aRetido[nScan][5]
			aIssRet[3] += aRetido[nScan][4]
			aIssRet[4] := aRetido[nScan][6]
		EndIf
		
		nScan := aScan(aRetido,{|x| x[1] == "PIS"})
		If nScan > 0
			aPisXml[1] := aRetido[nScan][3]
			aPisXml[2] += aRetido[nScan][4]
			aPisXml[3] := aRetido[nScan][5]
			nRatVPis   := RatValImp(aRetido,nScan,aProd,nX,aRestImp)
		EndIf
		
		nScan := aScan(aRetido,{|x| x[1] == "COFINS"})
		If nScan > 0
			aCofinsXml[1] := aRetido[nScan][3]
			aCofinsXml[2] += aRetido[nScan][4]
			aCofinsXml[3] := aRetido[nScan][5]
			nRatVcofins   := RatValImp(aRetido,nScan,aProd,nX,aRestImp)
		EndIf
		                                     
		nScan := aScan(aRetido,{|x| x[1] == "IRRF"})
		If nScan > 0
			aIrrfXml[1] := aRetido[nScan][3]
			aIrrfXml[2] += aRetido[nScan][4]
			aIrrfXml[3] := aRetido[nScan][5]
			nRatVIRRF   := RatValImp(aRetido,nScan,aProd,nX,aRestImp,"IRRF")
		EndIf
		                                    
		nScan := aScan(aRetido,{|x| x[1] == "CSLL"})
		If nScan > 0
			aCSLLXml[1] := aRetido[nScan][3]
			aCSLLXml[2] += aRetido[nScan][4]
			aCSLLXml[3] := aRetido[nScan][5]
			nRatVCsll   := RatValImp(aRetido,nScan,aProd,nX,aRestImp) 
		EndIf
		     
		nScan := aScan(aRetido,{|x| x[1] == "INSS"})
		If nScan > 0
			aInssXml[1] := aRetido[nScan][3]
			aInssXml[2] += aRetido[nScan][4]
			aInssXml[3] := aRetido[nScan][5]
		EndIf 
		
		// Valor dos Tributos por Ente Tributante: Federal, Estadual e Municipal
		// Lei da Transparência
		If lMvEnteTrb
            If lIntegHtl //Integracao hotelaria
                If Nx == 1 //Como os impostos estarao apenas na SF2, nao necessario verificar todos os itens  
                    If cMvMsgTrib $ "1-3" .And. cTpCliente == "F" .And. ( ( SF2->F2_TOTFED + SF2->F2_TOTEST + SF2->F2_TOTMUN ) > 0 ) 
                        cCargaTrb   := ' - Valor aproximado do(s) Tributo(s): '
                        
                        lProdItem := .F.                        
                        
                        // Federal
                        If SF2->F2_TOTFED > 0
                            cPercTrib := PercTrib(nil , lProdItem) 
                            cCrgTrib += "R$ " + ConvType( SF2->F2_TOTFED, 15, 2 )
                            If Val(cPercTrib) > 0
                                cCrgTrib += " (" + cPercTrib + "%)"
                            Endif
                            cCrgTrib += " Federal"
                        EndIf
            
                        // Estadual
                        If SF2->F2_TOTEST > 0
                            cPercTrib := PercTrib(nil , lProdItem) 
                            If !Empty(cCrgTrib)
                                cCrgTrib    += " e "
                            Endif
                            cCrgTrib += "R$ " + ConvType( SF2->F2_TOTEST, 15, 2 )
                            If Val(cPercTrib) > 0
                                cCrgTrib += " (" + cPercTrib + "%)" 
                            Endif
                            cCrgTrib += " Estadual"
                        EndIf
                
                        // Municipal
                        If SF2->F2_TOTMUN > 0
                            cPercTrib := PercTrib(nil , lProdItem)  
                            If !Empty(cCrgTrib)
                                cCrgTrib    += " e "
                            Endif
                            cCrgTrib += "R$ " + ConvType( SF2->F2_TOTMUN, 15, 2 )
                            If Val(cPercTrib) > 0
                                cCrgTrib += " (" + cPercTrib + "%)"
                            Endif
                            cCrgTrib += " Municipal."
                        EndIf
                        
                        cFntCtrb := SF2->F2_LTRAN
                                                
                        If !Empty( cFntCtrb )
                            cCrgTrib += " "                         
                            cCrgTrib += ". Fonte: " + cFntCtrb + "."
                        EndIf
                    EndIf
                    
                    cCargaTrb += cCrgTrib
                EndIf
            Else
    			If cMvMsgTrib $ "1-3" .And. cTpCliente == "F" .And. ( ( aProd[Nx][38] + aProd[Nx][39] + aProd[Nx][40] ) > 0 )
    		
    				cCargaTrb	:= ' - Valor aproximado do(s) Tributo(s): '
    				
    				// Federal
    				If aProd[Nx][38] > 0
    					cPercTrib	:= PercTrib( aProd[Nx][2], .T., "1" )  
    					cCrgTrib	+= 'R$ ' + ConvType( aProd[Nx][38], 15, 2 ) + " ("+cPercTrib+"%) Federal"
    				EndIf
    		
    				// Estadual
    				If aProd[Nx][39] > 0
    					cPercTrib	:= PercTrib( aProd[Nx][2],.T. , "2" )
    					If !Empty(cCrgTrib)
    						cCrgTrib	+= " e "
    					Endif
    					cCrgTrib	+= "R$ " + ConvType( aProd[Nx][39], 15, 2 ) + " ("+cPercTrib+"%) Estadual"
    				EndIf
    			
    				// Municipal
    				If aProd[Nx][40] > 0
    					cPercTrib	:= PercTrib( aProd[Nx][2], .T., "3" )  
    					If !Empty(cCrgTrib)
    						cCrgTrib	+= " e "
    					Endif
    					cCrgTrib	+= "R$ " + ConvType( aProd[Nx][40], 15, 2 ) + " ("+cPercTrib+"%) Municipal"
    				EndIf
    				If !Empty( cFntCtrb )
    					If ( nTotFedCrg + nTotEstCrg + nTotMunCrg ) > 0
    						cCrgTrib += " "
    					Endif
    					cCrgTrib += ". Fonte: " + cFntCtrb + "."
    				Endif
    		
    			EndIf
    			
    			cCargaTrb += cCrgTrib
    		EndIf	
		Else
			If lIntegHtl //Integracao hotelaria
                If Nx == 1 //Como os impostos estarao apenas na SF2, nao necessario verificar todos os itens
                    //Carga Tributária
                    If cMvMsgTrib $ "1-3" .And. ( ( SF2->F2_TOTFED + SF2->F2_TOTEST + SF2->F2_TOTMUN ) > 0 ) .And. cTpCliente == "F"
                        lProdItem := .F.
                        cPercTrib := PercTrib( nil , lProdItem)                     
                        cFntCtrb := SF2->F2_LTRAN
                        
                        cCargaTrb += "Valor Aproximado dos Tributos: R$ " + ConvType( SF2->F2_TOTFED + SF2->F2_TOTEST + SF2->F2_TOTMUN, 15, 2 ) 
                        If Val(cPercTrib) > 0
                            cCargaTrb += " (" + cPercTrib + "%)."
                        Endif
                        If !Empty(cFntCtrb)
                            cCargaTrb += " Fonte: " + cFntCtrb + "."
                        EndIf
                    EndIf
                EndIf
			Else
    			//Carga Tributária
    			If cMvMsgTrib $ "1-3" .And. nTotalCrg > 0 .And. cTpCliente == "F"
    				lProdItem := .T.
    				cPercTrib := PercTrib( nil , lProdItem)   
    				
    				If !Empty(cFntCtrb)
    					cCargaTrb += 'Valor Aproximado dos Tributos: R$ ' +ConvType(aProd[Nx][35],15,2)+ " ("+cPercTrib+"%). Fonte: "+cFntCtrb+"."
    				Else
    					cCargaTrb += 'Valor Aproximado dos Tributos: R$ ' +ConvType(aProd[Nx][35],15,2)+ " ("+cPercTrib+"%)."
    				EndIf 
    			EndIf
            EndIf 
		EndIf
		If aProd[Nx][35] > 0
			aadd(aLeiTrp,ConvType(aProd[Nx][35],15,2)) //valor  carga tributátria
			aadd(aLeiTrp,cPercTrib)         //valor percentual da carga tributátria
			aadd(aLeiTrp,cFntCtrb)          //fonte de infoemação da carga tributátria
		EndIf 
		     
		//Outras retenções, sera colocado o valor 0 (zero), pois atualmente nao existe valor de Outras retencoes 
		If Len(aRetido) > 0     
			nOutRet    := 0
		EndIf
		If cCodMun $ "3106200" .And. cTpPessoa == "EP" .And. cF4Agreg == "D"  
			nValLiq    := (aProd[Nx][27]) - aPisXml[1] - aCofinsXml[1]  - aInssXml[1] - aIRRFXml[1] - aCSLLXml[1] - IiF (aISSQN[1][03]> 0, aISSQN[1][03],nDescon)
		Else
			If cCodMun $ "3538709"	//Piracicaba
				nValLiq := aProd[Nx][27] - Iif(Len(aPisXml[3]) > 1 .And. len( aProd ) > 1,(aPisXml[3][Nx]+nRatVPis),aPisXml[1]) - Iif(Len(aCofinsXml[3]) > 1 .And. len( aProd ) > 1,(aCofinsXml[3][Nx]+nRatVcofins),aCofinsXml[1]) - Iif(Len(aInssXml[3]) > 1 .And. len( aProd ) > 1,aInssXml[3][Nx],aInssXml[1]) - Iif(Len(aIRRFXml[3]) > 1 .And. len( aProd ) > 1,(aIRRFXml[3][Nx]+nRatVIRRF),aIRRFXml[1]) - Iif(Len(aCSLLXml[3]) > 1 .And. len( aProd ) > 1,(aCSLLXml[3][Nx]+nRatVCsll),aCSLLXml[1]) - Iif(Len(aIssRet[4]) > 1 .And. len( aProd ) > 1,aIssRet[4][Nx],aIssRet[1])
			Else				
				nValLiq := aProd[Nx][27] - Iif(Len(aPisXml[3]) > 1 .And. len( aProd ) > 1,aPisXml[3][Nx],aPisXml[1]) - Iif(Len(aCofinsXml[3]) > 1 .And. len( aProd ) > 1,aCofinsXml[3][Nx],aCofinsXml[1]) - Iif(Len(aInssXml[3]) > 1 .And. len( aProd ) > 1,aInssXml[3][Nx],aInssXml[1]) - iif( lRecIRRF,Iif(Len(aIRRFXml[3]) > 1 .And. len( aProd ) > 1,aIRRFXml[3][Nx],aIRRFXml[1]),0 ) - Iif(Len(aCSLLXml[3]) > 1 .And. len( aProd ) > 1,aCSLLXml[3][Nx],aCSLLXml[1]) - Iif(Len(aIssRet[4]) > 1 .And. len( aProd ) > 1,aIssRet[4][Nx],aIssRet[1])
			Endif
		EndIF	
		
		cString	+= "<servico>"
		If cCodMun $ "3507605"
			cString	+= "<codigo>" + substr(allTrim( aProd[nX][24] ),1,3)+ allTrim( aProd[nX][24] ) + "</codigo>"
		Else
			cString	+= "<codigo>" + allTrim( aProd[nX][24] ) + "</codigo>"
		EndIf
		If cCodMun $ "3106200" .And. cTpPessoa == "EP" .And. cF4Agreg == "D"
			cString += '<aliquota>0.00</aliquota>'	  
		elseIf cCodMun $ "4115200"
			cString	+= "<aliquota>" + allTrim( iif( !empty( convType( nAliqISs ) ), AllTrim(Str(nAliqISs)), AllTrim(Str(aISSRet[3])) ) ) + "</aliquota>"
		ElseIf cCodMun $ "3170107|4304606|4303103|2301000" .and. aISSQN[1][02] > 0
			cString	+= "<aliquota>" + allTrim( convType(aISSQN[1][02], 7, 4) ) + "</aliquota>"
		Else
			cString	+= "<aliquota>" + allTrim( iif( nAliqISs > 0, convType( nAliqISs, 7, 4 ), convType(aISSRet[3], 7, 4) ) ) + "</aliquota>"
		EndIF	
		
		cString	+= "<idcnae>" + allTrim( aProd[nX][32] ) + "</idcnae>"		
		
		If !Empty(SF3->F3_CNAE)   
			cString	+= "<cnae>" + allTrim( SF3->F3_CNAE ) + "</cnae>" 
		Else
			cString	+= "<cnae>" + allTrim( aProd[nX][19] ) + "</cnae>" 
		EndIf

		cString	+= "<codtrib>" + allTrim( aProd[nX][34]) + allTrim( aProd[nX][32] ) + "</codtrib>"		

		If ( SC6->(FieldPos("C6_DESCRI")) > 0 .And. Len(aProd[nX]) > 40 .And. !Empty(aProd[nX][41]) ) .And. (!lNFeDesc .And. !GetNewPar("MV_NFESERV","1") == "1" .And. !Empty(GetMV("MV_CMPUSR")) )
			cString	+= "<discr>" + AllTrim(aProd[nX][41])+ cCargaTrb + "</discr>"
		ElseIf !lNFeDesc
			cString	+= "<discr>" + AllTrim(cNatOper)+ cCargaTrb + "</discr>"
		Else
			cString	+= "<discr>" + AllTrim(cDiscrNFSe)+ cCargaTrb + "</discr>"
		EndIf
		cString	+= "<quant>" + allTrim( convType( aProd[nX][9], 15, 2 ) ) + "</quant>"
		cString	+= "<valunit>" + allTrim( convType( aProd[nX][10], 15, 4 )) + "</valunit>"
		cString	+= "<valtotal>" + allTrim( convType( aProd[nX][28], 15, 4 ) ) + "</valtotal>"
		cString	+= "<basecalc>" + allTrim( convType( aProd[nX][25], 15, 2 ) ) + "</basecalc>"
		cString	+= "<issretido>" + iif( !empty( aISSRet[2] ), "1", "2" ) + "</issretido>"
		
		//-----------------------------------------------------------------------------------------
		//- Tratamento específico para ISS - São Paulo - Tag Valor Serviços e Valor Total Recebido
		//- Link Consultoria tributaria: http://tdn.totvs.com/pages/releaseview.action?pageId=382554689
		//-----------------------------------------------------------------------------------------
		if( cCodMun == "3550308" .and. allTrim( aProd[ nX ][ 23 ] ) $ allTrim( superGetMV( "MV_NFSTREC",.F.,"" ) ) )
			cString	+= "<valdedu>0.00</valdedu>"//tag valdedu é obrigatória, onde a mesma deve estar com valor 0 ao considerar o "Valor Recebido"
			cString	+= "<valreceb>" + allTrim( convType( ( aProd[ nX ][ 28 ] ),15,2 ) ) + "</valreceb>"
		else
			cString	+= "<valdedu>" + allTrim( convType( aProd[ nX ][ 29 ],15,2 ) ) + "</valdedu>"
		endIf
		
		//--------------------------------------------------------------------------------
		//- Verifica a existencia do campo das "Discriminacoes das Deducoes"
		//- Nao obrigatorio haver um valor de deducao para que o campo seja informado
		//--------------------------------------------------------------------------------
		if( !empty( cCampoDiscDed ) )
			if( select( "SC5" ) > 0 )
				if( SC5->( FieldPos( alltrim( cCampoDiscDed ) ) ) > 0 )
					if( valtype( &( "SC5->(" + alltrim( cCampoDiscDed ) + ")" ) ) <> "U" )				
						cString	+= "<discrdedu>" + &( "SC5->(" + alltrim( cCampoDiscDed ) + ")" ) + "</discrdedu>"
					endif
				endif
			endif
		endif

		cString	+= "<valredu>" + allTrim( convType( aProd[nX][36], 15, 2 ) ) + "</valredu>"
		cString	+= "<valpis>" + allTrim( convType(Iif(Len(aPisXml[3]) > 1 .And. Len(aProd) > 1 .And. cCodMun == "2610707",(aPisXml[3][Nx]+nRatVPis),aPisXml[1]),15,2))+"</valpis>"
		cString	+= "<valcof>" + allTrim( convType(Iif(Len(aCofinsXml[3]) > 1 .And. Len(aProd) > 1 .And. cCodMun == "2610707",(aCofinsXml[3][Nx]+nRatVcofins),aCofinsXml[1]),15,2))+"</valcof>"
		cString	+= "<valinss>" + allTrim( convType( aInssXml[1], 15, 2 ) ) + "</valinss>"
		If lRecIrrf
		   cString	+= "<valir>" + allTrim( convType(Iif(Len(aIRRFXml[3]) > 1 .And. Len(aProd ) > 1 .And. cCodMun == "2610707",(aIRRFXml[3][Nx]+nRatVIRRF),aIRRFXml[1]),15,2 )) + "</valir>"
		Else
			cString	+= "<valir>0.00</valir>"
		EndIf
		cString	+= "<valcsll>" + allTrim( convType(Iif(Len(aCSLLXml[3]) > 1 .And. Len(aProd) > 1 .And. cCodMun == "2610707",(aCSLLXml[3][Nx]+nRatVCsll),aCSLLXml[1]),15,2)) + "</valcsll>"
		If (cCodMun $ "3106200" .And. cTpPessoa == "EP" .And. cF4Agreg == "D") .Or. (cCodMun $ "3549904" .And. cMVOPTSIMP == "1" .And. aIssRet[1] == 0)
			cString	+= "<valiss>0.00</valiss>"
		ElseIf cCodMun == "2301000" .and. nISSQN >= 0 // Aquiraz
			cString	+= "<valiss>" + allTrim( ConvType(nISSQN,15,2) ) + "</valiss>"				
		ElseIf cCodMun $ "3170107" .and. !empty(aISSRet[2])
			cString	+= "<valiss>0.00</valiss>"
		Else
			cString	+= "<valiss>" + allTrim( ConvType(aISSQN[nX][3],15,2) ) + "</valiss>"
		EndIf	

		If cCodMun $ "3106200" .And. cTpPessoa == "EP" .And. cF4Agreg == "D"
			cString	+= "<valissret>0.00</valissret>"
		elseif cCodMun $ "4105805"
			cString	+= "<valissret>" + allTrim( convType( aIssRet[4][nX], 15, 2 ) ) + "</valissret>"
		Else
			cString	+= "<valissret>" + allTrim( convType( aIssRet[1], 15, 2 ) ) + "</valissret>"
		EndIf	
		
		cString	+= "<outrasret>" + allTrim( convType( nOutRet, 15, 2 ) ) + "</outrasret>"
		cString	+= "<valliq>" + allTrim( convType( nValLiq, 15, 2 ) ) + "</valliq>"
		cString	+= "<valtrib>" + allTrim( ConvType( aProd[Nx][35],15,2 ) ) + "</valtrib>"
		If cCodMun $ "3106200" .And. cTpPessoa == "EP" .And. cF4Agreg == "D"
			cString	+= "<desccond>"+IiF (aISSQN[1][03]> 0, convtype(aISSQN[1][03],15,2),convType(nDescon,15,2))+"</desccond>"
		Else
			cString	+= "<desccond>0</desccond>"
		EndIf	
		
		If cCodMun $ Fisa022Cod("008")
			cString +="<descinc>" + convType(nDescon,15,2) + "</descinc>"
		Else
			cString	+= "<descinc>" + allTrim( convType( aISSQN[1][6], 15, 2 ) ) + "</descinc>"
		EndIf
		
		cString	+= "<unidmed>" + allTrim( aProd[nX][8] ) + "</unidmed>"
		If TssCnae(cCodMun, allTrim(aProd[nX][19]))
			cString	+= "<tributavel>N</tributavel>"
		Else
			cString	+= "<tributavel>S</tributavel>"
		EndIf

		if !empty( allTrim( aProd[nX][33] ) )
			cString	+= "<cfps>" + allTrim( aProd[nX][33] ) + "</cfps>"
		endif 

		if !empty( allTrim( aCST[nX][02] ) )
			cString	+= "<cst>" + allTrim( aCST[nX][02] ) + "</cst>"
		endif	
		If !cCodMun $ "3143302-4303103-4208450-3524006"	//Cachoeirinha-RS
			cString	+= "<valrepasse>0.00</valrepasse>"
		EndIf
		cString	+= "</servico>"
		
	next nX
	
	cString	+= "</servicos>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} valores
Função para montar a tag de valores do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	aISSQN		Array contendo as informações sobre o imposto.
@param	aRetido		Array contendo as informações sobre impostos retidos.
@param	aTotal		Array contendo os valores totais da nota.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function valores( aISSQN, aRetido, aTotal, aDest, cCodMun,aLeiTrp,lRecIrrf )
	
	local aCOFINSXML	:= { 0, 0 }
	local aCSLLXML		:= { 0, 0 }
	local aINSSXML		:= { 0, 0 }
	local aIRRFXML		:= { 0, 0 }
	local aISSRet		:= { 0, 0, 0 }
	local aPISXML		:= { 0, 0 }
	
	local cString		:= ""
	local cTributa		:= ""
	local cMunPrest		:= ""
	
	local nOutRet		:= 0
	local nScan			:= 0

	local lRetido		:= .F.
	Local cMVOPTSIMP	:= allTrim( getMV( "MV_OPTSIMP",, "2" ) ) // Verifica se o prestador eh optante do simples

	Default aLeiTrp	:= {}
   	Default lRecIrrf	:= .T.
   	
	If cCodMun $ "4318705"

		cMunPrest := aDest[07] // SA1->A1_COD_MUN
		If Len( cMunPrest ) <= 5 .And. (!(cMunPrest$'9999999').Or. (cMunPrest$'9999999' .And. cCodMun $ '3550308|4205407|3300704|3156700'))
			cMunPrest := UfIBGEUni(aDest[09]) + cMunPrest
		EndIf
	
		lRetido:= aScan(aRetido,{|x| x[1] == "ISS"}) > 0
		
		Do Case
			Case aDest[11] == "EX"
				cTributa :="78"			
			Case cCodMun == cMunPrest
				If aTotal[3] == "1"
					If lRetido
						cTributa :="51"
					Else
						cTributa :="52"	
					EndIF										
			    ElseIf aTotal[03] == "7"
					cTributa :="58"	
			    ElseIf aTotal[03] == "8" .Or. aTotal[03] == "4"
					cTributa :="59"	
			    EndIF
			Case cCodMun <> cMunPrest
				If aTotal[3] == "1" 
					If lRetido
						cTributa :="61"
					Else
						cTributa :="62"		
					EndIF
				ElseIf aTotal[03] == "2"
					If lRetido
						cTributa:="63"	
					Else
						cTributa:="64"	
					EndIF		
				ElseIf aTotal[03] == "7"
					cTributa :="68"
			    ElseIf aTotal[03] == "8" .Or. aTotal[03] == "4"
					cTributa :="69"	
				EndIF
		EndCase
	EndIf

	nScan	:= aScan( aRetido, { | x | x[1] == "ISS" } )
	if nScan > 0
		aISSRet[1]	+= aRetido[nScan][3] 
		aISSRet[2]	+= aRetido[nScan][5] 
		aISSRet[3]	+= aRetido[nScan][4]
	endif
	
	nScan := aScan( aRetido, { | x | x[1] == "PIS" } )
	if nScan > 0
		aPISXML[1] := aRetido[nScan][3]
		aPISXML[2] += aRetido[nScan][4]
	endif
	
	nScan := aScan( aRetido, { | x | x[1] == "COFINS" } )
	if nScan > 0
		aCOFINSXML[1] := aRetido[nScan][3]
		aCOFINSXML[2] += aRetido[nScan][4]
	EndIf
	
	nScan := aScan( aRetido, { | x | x[1] == "INSS" } )
	if nScan > 0
		aINSSXML[1] := aRetido[nScan][3]
		aINSSXML[2] += aRetido[nScan][4]
	EndIf
	
	nScan := aScan( aRetido, { | x | x[1] == "IRRF" } )
	if nScan > 0
		aIRRFXML[1] := aRetido[nScan][3]
		aIRRFXML[2] += aRetido[nScan][4]
	endif
	                                    
	nScan := aScan( aRetido, { | x | x[1] == "CSLL" } )
	if nScan > 0
		aCSLLXML[1] := aRetido[nScan][3]
		aCSLLXML[2] += aRetido[nScan][4]
	endif
	
	if len( aRetido ) > 0
		nOutRet	:= 0
	endif
	
	cString	+= "<valores>"
	
	If (cCodMun $ "4318705" .and. cTributa $ "58|63|64|68|59|78|69") .or. (cCodMun $ "3549904" .and. cMVOPTSIMP == "1" .and. aIssRet[1] == 0)   
		cString += '<iss>0.00</iss>'
	Else
		cString	+= "<iss>" + allTrim( convType( aISSQN[1][3], 15, 2 ) ) + "</iss>"
	EndIf
	cString	+= "<issret>" + allTrim( convType( aISSRet[1], 15, 2 ) ) + "</issret>"
	cString	+= "<outrret>" + allTrim( convType( nOutRet, 15, 2 ) ) + "</outrret>"
	cString	+= "<pis>" + allTrim( convType( aPISXML[1], 15, 2 ) ) + "</pis>"
	cString	+= "<cofins>" + allTrim( convType( aCOFINSXml[1], 15, 2 ) ) + "</cofins>"
	cString	+= "<inss>" + allTrim( convType( aINSSXML[1], 15, 2 ) ) + "</inss>"
	If lRecIrrf
	cString	+= "<ir>" + allTrim( convType( aIRRFXML[1], 15, 2 ) ) + "</ir>"
	Else
		cString	+= "<ir>0.00</ir>"
	EndIf
	cString	+= "<csll>" + allTrim( convType( aCSLLXML[1], 15, 2 ) ) + "</csll>"
	cString	+= "<aliqiss>" + allTrim( convType( ( Iif( !empty( aISSQN[1][02] ), aISSQN[1][02], aISSRet[3] )), 15, 4 ) ) + "</aliqiss>"
	cString	+= "<aliqpis>" + allTrim( convType( aPISXML[2], 15,4 ) ) + "</aliqpis>"
	cString	+= "<aliqcof>" + allTrim( convType( aCOFINSXML[2], 15, 4 ) ) + "</aliqcof>"
	cString	+= "<aliqinss>" + allTrim( convType( aINSSXML[2], 15, 4 ) ) + "</aliqinss>"
	cString	+= "<aliqir>" + allTrim( convType( aIRRFXML[2], 15, 4 ) ) + "</aliqir>"
	cString	+= "<aliqcsll>" + allTrim( convType( aCSLLXML[2], 15, 4 ) ) + "</aliqcsll>"
	cString	+= "<valtotdoc>" + allTrim( convType( aTotal[2], 15, 4 ) ) + "</valtotdoc>"
	If len( aLeiTrp ) > 0   
		cString	+= "<valcartri>"+allTrim(aLeiTrp[1])+"</valcartri>"
		cString	+= "<valpercartri>"+allTrim(aLeiTrp[2])+"</valpercartri>"
		cString	+= "<valfoncartri>"+allTrim(aLeiTrp[3])+"</valfoncartri>"		
	EndIf		
	
	cString	+= "</valores>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} pagtos
Função para montar a tag de valores do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 06.02.2012

@param	aDupl		Array contendo informações sobre os pagamentos.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function pagtos( aDupl,cCondPag )
	
	local	cString	:= ""
	local	cTemp	:= ""
	
	local	nX		:= 0
	
	If len( aDupl ) > 0



		cString	+= "<pagamentos>"

			If ("00" == AllTrim(cCondPag)) .Or. ("00," == AllTrim(cCondPag)) // Pega do campo E4_COND
				cString += "<condpag>1</condpag>"
			Else 
				If cCodmun $ "3547304" .AND. AllTrim(cCondPag)>"00" //Santana de Parnaíba
					cString += "<condpag>2</condpag>"
				Else
					cString += "<condpag>3</condpag>"
				EndIf	
			
			Endif 
		
		for nX := 1 to len( aDupl )
			
			
			cTemp	:= dToS( aDupl[nX][2] )
			
			cString	+= "<pagamento>"
			
			cString	+= "<parcela>" + iif( !empty( allTrim( aDupl[nX][4] ) ), allTrim( aDupl[nX][4] ), "1" ) + "</parcela>"
			cString	+= "<dtvenc>" + subStr( allTrim( cTemp ), 1, 4 ) + "-" + subStr( allTrim( cTemp ), 5, 2 ) + "-" + subStr( allTrim( cTemp ), 7, 2 ) + "</dtvenc>"
			cString	+= "<valor>" + allTrim( convType( aDupl[nX][3], 15, 2 ) ) + "</valor>"
			
			cString	+= "</pagamento>"
			
			
		next nX
		cString	+= "</pagamentos>"
	EndIf
	
	
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} faturas
Função para montar a tag de valores do XML de envio de NFS-e ao TSS.

@author Karyna Morato
@since 03.06.2015

@param	aDupl		Array contendo informações sobre os pagamentos.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function faturas( aDupl )

	local	cString	:= ""

	local	nX		:= 0

	If len( aDupl ) > 0 // Coloca a tag faturas, apenas quando gerar duplicata

		cString	+= "<faturas>"

		for nX := 1 to len( aDupl )

			cString	+= "<fatura>"

			cString	+= "<numero>" + allTrim( aDupl[nX][5] ) + "</numero>"
			cString	+= "<valor>" + allTrim( convType( aDupl[nX][3], 15, 2 ) ) + "</valor>"

			cString	+= "</fatura>"

		next nX

		cString	+= "</faturas>"

	EndIf

return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} deducoes
Função para montar a tag de deduções do XML de envio de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	aProd	Array contendo as informações sobre os serviços.
@param	aDeduz	Array contendo as informações sobre as deduções.

@return	cString	Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function deducoes( aProd, aDeduz, aDeducao )
	
	local cCPFCNPJ	:= ""
	local cString	:= ""
	
	local nX		:= 0
	
	if len( aDeduz ) <= 0.and. len( aDeducao ) <= 0 

		return cString

	endif
	
	cString	+= "<deducoes>"
		
	if  len( aDeduz ) > 0   

		for nX := 1 to len( aDeduz )
			
			cCPFCNPJ	:= allTrim( posicione( "SA2", 1, xFilial( "SA2" ) + aDeduz[nX][3] + aDeduz[nX][4], "A2_CGC" ) )
			
			cString		+= "<deducao>"
			
			cString		+= "<tipo>" + iif( empty( allTrim( aDeduz[nX][1] ) ), "1", iif( allTrim( aDeduz[nX][1] ) == "1", "1", "2") ) + "</tipo>"
			cString		+= "<modal>" + iif( empty( allTrim( aDeduz[nX][2] ) ), "1", iif( allTrim( aDeduz[nX][2] ) == "1", "1", "2" ) ) + "</modal>"
			cString		+= "<cpfcnpj>" + iif( empty( cCPFCNPJ ), "00000000000191", cCPFCNPJ ) + "</cpfcnpj>"
			cString		+= "<numeronf>" + iif( empty( allTrim( aDeduz[nX][6] ) ), "1", allTrim( aDeduz[nX][6] ) ) + "</numeronf>"
			cString		+= "<totalnf>" + allTrim( convType( aDeduz[nX][7], 15, 2 ) ) + "</totalnf>"
			cString		+= "<percentual>" + iif( aDeduz[nX][1] == "1", allTrim( convType( aDeduz[nX][8], 15, 2 ) ), "0.00" ) + "</percentual>"
			cString		+= "<valor>" + iif( aDeduz[nX][1] == "2", allTrim( convType( aDeduz[nX][9], 15, 2 ) ), "0.00" ) + "</valor>"
			
			cString		+= "</deducao>"
			
		next nX
	
	else
		for nX := 1 to len( aDeducao )
					
			cString		+= "<deducao>"
			
			cString		+= "<tipo>1</tipo>"
			cString		+= "<modal>1</modal>"
			cString		+= "<cpfcnpj>" + iif( empty( cCPFCNPJ ), "00000000000191", cCPFCNPJ ) + "</cpfcnpj>"
			cString		+= "<numeronf>1</numeronf>"
			cString		+= "<totalnf>0.00</totalnf>"
			cString		+= "<percentual>0.00</percentual>"
			cString		+= "<valor>" + allTrim( convType( aDeducao[nX][1], 15, 2 ) ) + "</valor>"
			
			cString		+= "</deducao>"
			
		next nX
	
	endif
	
	cString	+= "</deducoes>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} construcao
Função para montar a tag de construção civil do XML de envio de NFS-e ao TSS.

@author Simone dos Santos de Oliveira
@since 20.11.2013

@param	aConstr		Array contendo dados da construção civil.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function construcao( aConstr )
	
	local cString	:= ""


	If !Empty(aConstr[1]) .or. !Empty(aConstr[3]) .Or. !Empty(aConstr[4]) .or. !Empty(aConstr[15]) .or. !Empty(aConstr[17])
		cString	+= "<construcao>"
		cString += If(Len(aConstr) > 00 .And. !Empty(aConstr[01]), '<codigoobra>'+AllTrim(aConstr[01])+'</codigoobra>', "" )
		cString += If(Len(aConstr) > 01 .And. !Empty(aConstr[02]), '<art>'+AllTrim(aConstr[02])+'</art>' , "" )
		cString += If(Len(aConstr) > 02 .And. !Empty(aConstr[03]), '<tipoobra>'+AllTrim(aConstr[03])+'</tipoobra>' , "")		
		
		cString += If(Len(aConstr) > 03 .And. !Empty(aConstr[04]), '<xLogObra>'+aConstr[04]+'</xLogObra>' , "" )
		cString += If(Len(aConstr) > 04 .And. !Empty(aConstr[05]), '<xComplObra>'+aConstr[05]+'</xComplObra>' ,"" )
		cString += If(Len(aConstr) > 05 .And. !Empty(aConstr[06]), '<vNumeroObra>'+aConstr[06]+'</vNumeroObra>' , "" )
		cString += If(Len(aConstr) > 06 .And. !Empty(aConstr[07]), '<xBairroObra>'+aConstr[07]+'</xBairroObra>' , "" )
		cString += If(Len(aConstr) > 07 .And. !Empty(aConstr[08]), '<xCepObra>'+aConstr[08]+'</xCepObra>' , "")
		cString += If(Len(aConstr) > 08 .And. !Empty(aConstr[09]), '<cCidadeObra>'+UfIBGEUni(aConstr[11])+aConstr[09]+'</cCidadeObra>' , "" )
		cString += If(Len(aConstr) > 09 .And. !Empty(aConstr[10]), '<xCidadeObra>'+aConstr[10]+'</xCidadeObra>' , "" )
		cString += If(Len(aConstr) > 10 .And. !Empty(aConstr[11]), '<xUfObra>'+aConstr[11]+'</xUfObra>' , "" )
		cString += If(Len(aConstr) > 11 .And. !Empty(aConstr[12]), '<cPaisObra>'+aConstr[12]+'</cPaisObra>' , "" )
		cString += If(Len(aConstr) > 12 .And. !Empty(aConstr[13]), '<xPaisObra>'+aConstr[13]+'</xPaisObra>' , "" )
		cString += If(Len(aConstr) > 13 .And. !Empty(aConstr[14]), '<numeroArt>'+aConstr[14]+'</numeroArt>' , "" )
		cString += If(Len(aConstr) > 14 .And. !Empty(aConstr[15]), '<numeroCei>'+aConstr[15]+'</numeroCei>' , "" )
		cString += If(Len(aConstr) > 15 .And. !Empty(aConstr[16]), '<numeroProj>'+aConstr[16]+'</numeroProj>' ,"" )
		cString += If(Len(aConstr) > 16 .And. !Empty(aConstr[17]), '<numeroMatri>'+aConstr[17]+'</numeroMatri>' , "" )
		cString += If(Len(aConstr) > 17 .And. !Empty(aConstr[18]), '<numeroEncap>'+aConstr[18]+'</numeroEncap>' , "" )

		cString	+= "</construcao>"
	EndIf
	
return cString   

//-----------------------------------------------------------------------
/*/{Protheus.doc} infCompl
Função para montar a tag de informações complementares do XML de envio
de NFS-e ao TSS.

@author Marcos Taranta
@since 23.01.2012

@param	cMensCli	Mensagem complementar ao cliente.
@param	cMensFis	Mensagem complementar ao fisco.

@return	cString		Tag montada em forma de string.
/*/
//-----------------------------------------------------------------------
static function infCompl( cMensCli, cMensFis, lNFeDesc, cDescrNFSe )
	
	local cString	:= ""
	
	cString	+= "<infcompl>"
	
	If !lNFeDesc
		cString	+= "<descricao>" + cMensCli + space( 1 ) + cMensFis + "</descricao>"
	Else
		cString	+= "<descricao>" + Alltrim(cDescrNFSe) + "</descricao>"
	EndIf
	
	cString += "<observacao>" + cMensCli + space( 1 ) + cMensFis + "</observacao>"
	cString	+= "</infcompl>"
	
return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} convType
Função para converter qualquer tipo de informação para string.

@author Marcos Taranta
@since 19.01.2012

@param	xValor	Informação a ser convertida.
@param	nTam	Tamanho final da string a ser retornada.
@param	nDec	Número de casa decimais para informações numéricas.

@return	cNovo	Informação em forma de string a ser retornada.
/*/
//-----------------------------------------------------------------------
static function convType( xValor, nTam, nDec )
	
	local	cNovo	:= ""
	
	default	nDec	:= 0
	
	do case
		case valType( xValor ) == "N"
			if xValor <> 0
				cNovo	:= allTrim( str( xValor, nTam, nDec ) )
				cNovo	:= strTran( cNovo, ",", "." )
			else
				cNovo	:= "0"
			endif
		case valType( xValor ) == "D"
			cNovo	:= fsDateConv( xValor, "YYYYMMDD" )
			cNovo	:= subStr( cNovo, 1, 4 ) + "-" + subStr( cNovo, 5, 2 ) + "-" + subStr( cNovo, 7 )
		case valType( xValor ) == "C"
			if nTam == nil
				xValor	:= allTrim( xValor )
			endif
			default	nTam	:= 60
			cNovo := allTrim( encodeUTF8( subStr( xValor, 1, nTam ) ) )
	endcase
	
return cNovo

//-----------------------------------------------------------------------
/*/{Protheus.doc} myGetEnd
Função para pegar partes do endereço de uma única string.

@author Marcos Taranta
@since 24.01.2012

@param	cEndereco	String do endereço único.
@param	cAlias		Alias da base.

@return	aRet		Partes separadas do endereço em um array.
/*/
//-----------------------------------------------------------------------
static function myGetEnd( cEndereco, cAlias )
	
	local aRet		:= { "", 0, "", "" }
	
	local cCmpEndN	:= subStr( cAlias, 2, 2 ) + "_ENDNOT"
	local cCmpEst	:= subStr( cAlias, 2, 2 ) + "_EST"
	
	// Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
	// Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
	if ( &( cAlias + "->" + cCmpEst ) == "DF" ) .Or. ( ( cAlias )->( FieldPos( cCmpEndN ) ) > 0 .And. &( cAlias + "->" + cCmpEndN ) == "1" )
		aRet[1] := cEndereco
		aRet[3] := "SN"
	else
		aRet := fisGetEnd( cEndereco )
	endIf
	
return aRet 

//-----------------------------------------------------------------------
/*/{Protheus.doc} vldIE
Valida IE.

@author Marcos Taranta
@since 24.01.2012

@param	cInsc	IE.
@param	lContr	Caso .F., retorna "ISENTO".

@return	aRet	Retorna a IE.
/*/
//-----------------------------------------------------------------------
Static Function vldIE( cInsc, lContr )
	
	local cRet		:= ""
	
	local nI		:= 1
	
	default lContr	:= .T.
	
	for nI := 1 to len( cInsc )
		if isDigit( subs( cInsc, nI, 1 ) ) .Or. isAlpha( subs( cInsc, nI, 1 ) )
			cRet += subs( cInsc, nI, 1)
		endif
	next
	
	cRet := allTrim( cRet )
	if "ISENT" $ upper( cRet )
		cRet := ""
	endif
	
	if !( lContr ) .And. !empty( cRet )
		cRet := "ISENTO"
	endif
	
return cRet 

//-----------------------------------------------------------------------
/*/{Protheus.doc} UfIBGEUni
Funcao que retorna o codigo da UF do participante, de acordo com a tabela 
disponibilizada pelo IBGE.

@author Simone Oliveira
@since 02.08.2012

@param	cUf 	Sigla da UF do cliente/fornecedor

@return	cCod	Codigo da UF
/*/
//-----------------------------------------------------------------------

Static Function UfIBGEUni (cUf,lForceUF)
Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}

DEFAULT lForceUF := .T.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"EX","99"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][2]
	EndIf
Else
	cRetorno := IIF(lForceUF,"",aUF)
EndIf

Return(cRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTipoLogr
Função que retorna os tipos de logradouro do prestador/tomador

@author Natalia Sartori
@since 08/01/2013
@version 1.0 

@param	cTexto		Tipo do Logradouro

@return	cTipoLogr	Retorna a descrição do Tipo do Logradouro
/*/
//-----------------------------------------------------------------------
Static Function RetTipoLogr( cTexto )

Local cTipoLogr:= ""
Local cAbrev	 := ""
Local nX       := 0
Local nAt		 := 0 
Local aMsg     := {}

aadd(aMsg,{"1", "Av"})			// Avenida
aadd(aMsg,{"2", "Rua"})			// Rua
aadd(aMsg,{"3", "Rod"})			// Rodovia
aadd(aMsg,{"4", "Ruela"})
aadd(aMsg,{"5", "Rio"})
aadd(aMsg,{"6", "Sitio"})
aadd(aMsg,{"7", "Sup Quadra"})
aadd(aMsg,{"8", "Travessa"})
aadd(aMsg,{"9", "Vale"})
aadd(aMsg,{"10","Via"})			// Via
aadd(aMsg,{"11","Vd"}) 			// Viaduto
aadd(aMsg,{"12","Ve"}) 			// Viela
aadd(aMsg,{"13","Vila"})
aadd(aMsg,{"14","Vargem"})			// Vargem
aadd(aMsg,{"15","Al"})			// Alameda
aadd(aMsg,{"16","Pc"})			// Praça	
aadd(aMsg,{"17","Bc"})			// Beco
aadd(aMsg,{"18","Tv"})			// Travessa
aadd(aMsg,{"19","Vel"})			// Via Elevada
aadd(aMsg,{"20","Pq"})			// Parque
aadd(aMsg,{"21","Lg"})			// Largo
aadd(aMsg,{"22","Vep"})			// Viela Particular
aadd(aMsg,{"23","Pa"})			// Pátio
aadd(aMsg,{"24","Ves"})			// Viela Sanitária
aadd(aMsg,{"25","Ld"})			// Ladeira
aadd(aMsg,{"26","Jd"})			// Jardim
aadd(aMsg,{"27","Es"})			// Estrada
aadd(aMsg,{"28","Pte"})			// Ponte
aadd(aMsg,{"29","Rp"})			// Rua Particular
aadd(aMsg,{"30","Praia"})

nAt := At(" ", UPPER(cTexto))
cAbrev := substr(UPPER(cTexto), 1, nAt-1)

nX := aScan(aMsg,{|x| UPPER(x[2]) $ cAbrev})
If nX == 0
	cTipoLogr := "2"
Else
	cTipoLogr := aMsg[nX][1]
EndIf

Return cTipoLogr

//-----------------------------------------------------------------------
/*/{Protheus.doc} RatValImp
Realiza a proporcionalidade do Valor do imposto aglutinado

@author Rene Julian
@since 17/03/2015
@version 1.0 

@param	cTexto		Tipo do Logradouro

@return	cTipoLogr	Retorna a descrição do Tipo do Logradouro
/*/
//-----------------------------------------------------------------------
Static Function RatValImp(aRetido,nScan,aProd,nProd,aRestImp)
Local nRetorno  := 0
Local nValimp   := 0
Local nValitens := 0
Local nValtot   := 0
Local nDifVal   := 0
Local nX       := 0
Local nPos      := aScan(aRestImp,{|x| x[1] == nScan})


If Len(aRetido[nScan][5]) > 0 
	For nX := 1 To Len(aRetido[nScan][5])
		nValitens += aRetido[nScan][5][nX]
	Next nX
	nDifVal := aRetido[nScan][3] - nValitens 
	For nX := 1 To Len(aProd)
		nValtot += aProd[nX][28]  
	Next nX
	nValimp := (nDifVal / nValtot) * aProd[nProd][28]	
EndIf

If nPos == 0
	AADD(aRestImp,{nScan,nValimp - noRound(nValimp,2)})
	nRetorno := noRound(nValImp)
Else
	nValImp:= nValImp + aRestImp[nPos][2]            
	nRetorno := noRound(nValImp)
	aRestImp[nPos][2] := nValimp - noRound(nValimp,2)
EndIf 
Return(nRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaXml
Retira e valida algumas informações e caracteres indesejados para 
o parse do XML.

@author Valter Silva
@since 03/09/2015
@version 1.0 

@param	cXml	XML que será feito a validação e a retirada dos
				caracteres especiais

@return	cRetorno	XML limpo
/*/
//-------------------------------------------------------------------
Static Function LimpaXml( cXml )
Local cRetorno		:= "" 
DEFAULT cXml		:= ""

If ( !Empty(cXml) )
	if( SM0->M0_CODMUN $ "3170701" )
		/*Retira caractere '&' substitui por 'e'*/
		cRetorno := StrTran(cXml,"&","e")
	else
		/*Retira caractere '&' substitui por '&amp;'*/
		cRetorno := StrTran(cXml,"&","&amp;amp;")
	endIf
EndIf

Return cRetorno 

//-----------------------------------------------------------------------
/*/{Protheus.doc} PercTrib
Retorna a porcentagem a ser impresso no DANFE para a Lei Transparencia (Lei 12.741)


@param	aProd		Contendo as informacoes do(s) produto(s).
@param	lProdItem	Identifica se a mensagem da Lei da Transparencia sera gerado
					no Produto e/ou informacoes complementares.
@param	cEnte		Ente Tributante: 1-Federal / 2-Estadual / 3-Municipal

@return cPercTrib Porcentagem do Tributo

@author Douglas Parreja
@since 26/06/2014
@version 12
/*/
//-----------------------------------------------------------------------

Static Function PercTrib( cCodP, lProdItem, cEnte ) 

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->( GetArea() )

Local cPercTrib		:= ""
Local nPos			    := 30
Local nTotCargaTrib	:= nTotalCrg
Local nAliq			:= 0
Local nTotNota		:= 0

Default cCodP 		:= ""         
Default lProdItem 	:= .F.
Default cEnte		:= ""

If lMvEnteTrb .And. ( cEnte $ "1-2-3" )
	
	If cEnte == "1"	// FEDERAL

		nPos 			:= 38
		nTotCargaTrib	:= nTotFedCrg

	ElseIf cEnte == "2"	// ESTADUAL

		nPos			:= 39
		nTotCargaTrib	:= nTotEstCrg

	Else

		nPos 			:= 40
		nTotCargaTrib	:= nTotMunCrg

	Endif
	
Endif

If lProdItem

	dbSelectArea("SB1")
	dbSetOrder(1) // B1_FILIAL+B1_COD
	
	If dbSeek( xFilial("SB1") + cCodP )
	
		nAliq	:= LeiTransp(nPos) 
		cPercTrib := ConvType( nAliq * 100 , 15, 2 )
		
	Endif

Else

	cPercTrib	:= ConvType( ( nTotCargaTrib / nTotNota ) * 100, 15, 2 )

EndIf			

RestArea( aAreaSB1 )
RestArea( aArea )	

Return cPercTrib

//-----------------------------------------------------------------------
/*/{Protheus.doc} LeiTransp
Retorna a porcentagem a ser impresso no por documento gerado 
DANFE para a Lei Transparencia (Lei 12.741) 


@param	nPos 	Posição ref. Aliq. Tributante: 30 - Aliquota Total
							35-Federal / 36-Estadual / 37-Municipal

@return nAliq		Aliquota do Produto

@author Douglas Parreja
@since 19/12/2014
@version 11.80
/*/
//-----------------------------------------------------------------------

Static Function LeiTransp (nPos)

Local nAliq := 0

Default nPos	:= 30

DbSelectArea("SD2")
DbSetOrder(3)
If dbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)

	If nPos == 38 .And. SD2->(FieldPos("D2_TOTFED"))<>0	// FEDERAL
	
		nAliq := SD2->D2_TOTFED /  (SD2->D2_VALBRUT + SD2->D2_DESCON)
		
	ElseIf nPos == 39 .And. SD2->(FieldPos("D2_TOTEST"))<>0	// ESTADUAL
	
		nAliq := SD2->D2_TOTEST / (SD2->D2_VALBRUT + SD2->D2_DESCON)
	
	ElseIf nPos == 40 .And. SD2->(FieldPos("D2_TOTMUN"))<>0	// MUNICIPAL
	
		nAliq := SD2->D2_TOTMUN / (SD2->D2_VALBRUT + SD2->D2_DESCON)	
	ElseIf nPos == 30 .And. SD2->(FieldPos("D2_TOTIMP  "))<>0 // MUNICIPAL

		nAliq := SD2->D2_TOTIMP / (SD2->D2_VALBRUT + SD2->D2_DESCON)
		
	EndIf

EndIf

Return nAliq
//-----------------------------------------------------------------------
/*/{Protheus.doc} NatPCC
Função que verifica os pontos de inclusão da natureza de operação

@author Cleiton Genuino
@since 31.12.2015

@return aNatPCC	array com ponteiro e Valor da Natureza para compor calculo PCC
/*/
//-----------------------------------------------------------------------

Static Function  NatPCC ( aDest , cNatPCC  )

Local aArea	 := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local cNatBusc := ""

Default aDest   := {}
Default cNatPCC := "SA1->A1_NATUREZ"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona Natureza do pedido                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
	dbSelectArea("SC5")
	SC5->( dbSetOrder(1) )

	dbSelectArea("SD2")	
	SD2->( dbSetOrder(3) )
	
	If SD2->( MsSeek( xFilial("SD2") + aDest[23] + aDest[24])) 	 //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM,
	          
		If SC5->( MsSeek( xFilial("SC5") + SD2->D2_PEDIDO) )
		
			If SC5->(FieldPos("C5_NATUREZ") > 0 ) .And. !Empty(SC5->C5_NATUREZ)	
				cNatBusc := SC5->C5_NATUREZ
								
			Elseif (len (aDest) > 0 .And. !Empty(aDest[19]) )	
				cNatBusc := SA1->A1_NATUREZ
					
			Elseif !Empty(cNatPCC) .And. cNatPCC $ 'C5_NATUREZ' 
			    If SC5->(FieldPos("C5_NATUREZ") > 0 ) .And. !Empty(SC5->C5_NATUREZ)	
					cNatBusc := SC5->C5_NATUREZ
				Endif
				
			Elseif !Empty(cNatPCC) .And. cNatPCC $ 'A1_NATUREZ'
				cNatBusc:= SA1->A1_NATUREZ
					
		   Endif
		endif
	endif
	
RestArea(aAreaSC5)
RestArea(aAreaSD2)
RestArea(aArea)

return cNatBusc

//--------------------------------------------------

/*/{Protheus.doc} TipoPes
Retorna o tipo de pessoa

@author Valter Silva
@since 23/12/2016
@version 1.0 

@param	cTipo	 Tipo de pessoa

@return cRetorno	Tipo de pessoa padrão tss
/*/
//-------------------------------------------------------------------

Static Function  TipoPes(cTipo)
Local cRetorno		:= "" 
DEFAULT cTipo		:= ""

Do Case
	Case cTipo == "CI" //CI=Comercio/Industria
		cRetorno :="1"
	Case cTipo == "PF" //PF=Pessoa Fisica
		cRetorno :="2"
	Case cTipo == "OS" //OS=Prestação de Servico
		cRetorno :="3"
	Case cTipo == "EP" //EP=Empressa publica
		cRetorno :="4"
	Case cTipo == "CO"//CO=Cooperado
		cRetorno:= "5"			
	EndCase	

Return cRetorno

//--------------------------------------------------

/*/{Protheus.doc} FunValUnit
Retorna o valor total

@author Karyna Morato
@since 12/07/2016
@version 1.0 

@param	cTipo		Tipo do item
		nPrcVen 	Valor unitário do item
		

@return nTotal 	Valor total
/*/
//-------------------------------------------------------------------  

Static Function FunValUnit(cTipo, nPrcVen, nQtde,nValIss)

Local nTotal := 0 

/* Conforme alinhado com Renato Panfietti e Felipe Barbieri o TMS sempre trabalha com quantidade "1",
sendo assim, será apenas somado o preco de venda com o valor icms(referente a valor do ISS)
*/
If !cTipo $ "IP"

	// Soma o valor ISS quando a nota é do TMS
	If SF4->(FieldPos("F4_AGRISS")) > 0 .and. IntTMS()
		If SF4->F4_AGRISS == '1' .and. nQtde == 1
			nTotal := nPrcVen + nValIss
		ELSE
		   nTotal := nPrcVen
		EndIf
	
	Else
		nTotal := nPrcVen 	 
	EndIf

EndIf

Return nTotal
//--------------------------------------------------

/*/{Protheus.doc} FunValTot
Retorna o valor total

@author Karyna Morato
@since 12/07/2016
@version 1.0 

@param	cTipo		Tipo do item
		nPrcVen 	Valor unitário do item
		nQtde		Quantidade do item
		nTotDoc	Valor total do item
		nDescon	Desconto do item
		nDesczfr	Desconto
		nValIss	Valor do ISS

@return nTotal 	Valor total
/*/
//-------------------------------------------------------------------  

Static Function FunValTot(cTipo,nPrcVen, nQtde, nTotDoc, nDescon, nDesczfr, nValIss)
				  
Local nTotal	:= 0 
Local lMvtot	:= SuperGetMV("MV_NFSETOT",,.F.) // Parâmetro para somar o desconto no valor total


If !cTipo $ "IP"
	
	If if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) == "3550308"
		nTotal := nPrcVen * nQtde
	Else
		nTotal := nTotDoc
	EndIf
	
	//----------------------------------------------------------------
	// Realizado ajuste para considerar uma unica vez a soma 
	// no desconto (D2_DESCON + D2_DESCZFR)
	// @autor: Douglas Parreja
	// @date: 29/03/2018
	//----------------------------------------------------------------
	If lMvtot //!SM0->M0_CODMUN $ "4205407-3148103"
		nTotal += nDescon + nDesczfr
	EndIf
	
	// Soma o valor ISS quando a nota é do TMS
	If SF4->(FieldPos("F4_AGRISS")) > 0 .and. IntTMS()
		If SF4->F4_AGRISS == '1'
			nTotal += nValIss
		EndIf		 
	EndIf

EndIf

Return nTotal
//--------------------------------------------------

/*/{Protheus.doc} FuCamArren
Retorna o campo correto para a funcao A410Arred 

@author Fernando Bastos 
@since 03/08/2017
@version 1.0 

@param	cCamPrcv	valor do campo D2_PRCVEN
		cCamQuan	valor do campo D2_QUANT
		cCamTot	valor do campo D2_TOTAL

@return cCampo 	Campo para a funcao A410Arred
/*/
//-------------------------------------------------------------------  
Static Function FuCamArren(nCamPrcv,nCamQuan,nCamTot)

//Para entender essa funcao olhar o fonte fatxfun.prx funcao A410Arred  
//Parametro MV_ARREFAT de arredondamento 

Local cCampo 	:= ""

Default nCamPrcv	:= 2 
Default nCamQuan	:= 2
Default nCamTot	:= 2
 	  
If nCamQuan > nCamPrcv .And. nCamQuan > nCamTot 
	cCampo := "D2_QUANT"
ElseIf nCamPrcv > nCamQuan  .And. nCamPrcv > nCamTot
	cCampo := "D2_PRCVEN"
Else
	cCampo := "D2_TOTAL"
EndIf

Return cCampo

//----------------------------------------------------------------------
/*/{Protheus.doc} ClearTLogr
Funcao que define se leva ou não o tipo  do Logradouro do logradouro
@author Valter Silva
@since 23.10.2017
@version 1.0 

@param		cLogradour  	Parâmetro com a informações do Logradouro.
@return	cLogradour     Logradouro com ou sem o tipo de logradouro de acordo com Parâmetro "MV_TIPLOGR".
@obs		
/*/
//------------------------------------------------------------------- 
Static Function ClearTLogr(cLogradour)

local cTipoLogrA	:= ""
local cTipoLogrB	:= ""
Local LlimpLog	:= SuperGetMV("MV_TIPLOGR",.F.,.F.) // Parâmetro para determinar se retira o tipo do logradouro do endereço.
                                
if !Empty(cLogradour)
	cTipoLogr:= RetTipoLogr(cLogradour)
endif 

If !Empty(cTipoLogr) .AND.  LlimpLog
	Do Case
		Case cTipoLogr == "1" // Avenida
			cTipoLogr := "Av "
		Case cTipoLogr == "2" // Rua
			cTipoLogr := "Rua "			
		Case cTipoLogr == "3" // Rodovia
			cTipoLogr := "Rod "	
		Case cTipoLogr == "4" // Ruela
			cTipoLogr := "Ruela "		
		Case cTipoLogr == "5" //Rio
			cTipoLogr := "Rio "		
		Case cTipoLogr == "6" //Sitio
			cTipoLogr := "Sitio "	
		Case cTipoLogr == "7" //Sup Quadr
			cTipoLogr := "Sup Quadra "		
		Case cTipoLogr == "8" //Travessa
			cTipoLogr := "Travessa "	
		Case cTipoLogr == "9" //Vale
			cTipoLogr := "Vale "	
		Case cTipoLogr == "10" // Via
			cTipoLogr := "Via "	
		Case cTipoLogr == "11" // Viaduto
			cTipoLogr := "Vd "		
		Case cTipoLogr == "12" // Viela
			cTipoLogr := "Vie "	
		Case cTipoLogr == "13" // Vila
			cLogr := "Vila "	
		Case cTipoLogr == "14" //Vargem
			cTipoLogr := "Vargem "
		Case cTipoLogr == "15" // Alameda
			cTipoLogr := "Al "
		Case cTipoLogr == "16" // Praça
			cTipoLogr := "Pc "
		Case cTipoLogr == "17" // Beco
			cTipoLogr := "Bc "
		Case cTipoLogr == "18" // Travessa
			cTipoLogr := "Tv "
		Case cTipoLogr == "19" // Via Elevada
			cTipoLogr := "Vel "
		Case cTipoLogr == "20" // Parque
			cTipoLogr := "Pq "	
		Case cTipoLogr == "21" // Largo
			cTipoLogr := "Lg "	
		Case cTipoLogr == "22" // Viela Particular
			cTipoLogr := "Vep "	
		Case cTipoLogr == "23" // Pátio
			cTipoLogr := "Pa "
		Case cTipoLogr == "24" // Viela Sanitária
			cTipoLogr := "Ves "
		Case cTipoLogr == "25" // Ladeira
			cTipoLogr := "Ld "
		Case cTipoLogr == "26" // Jardim
			cTipoLogr := "Jd "
		Case cTipoLogr == "27" // Estrada
			cTipoLogr := "Es "
		Case cTipoLogr == "28" // Ponte
			cTipoLogr := "Pte "
		Case cTipoLogr == "29" // Rua Particular
			cTipoLogr := "Rp "
		Case cTipoLogr == "30" // Praia
			cTipoLogr := "Praia "
			
	EndCase

	cLogradour:= StrTran(cLogradour,'.',"")
	cLogradour:= StrTran(cLogradour,cTipoLogr,"")
	cLogradour:= StrTran(cLogradour,Upper(cTipoLogr),"")
	cLogradour:= StrTran(cLogradour,Lower(cTipoLogr),"")
	
endif

return(cLogradour)

//--------------------------------------------------
/*/{Protheus.doc} GetTitNat
Função utilizada para buscar a natureza do título da nota

@author paulo.barbosa
@since 14/12/2017
@version 1.0 

@param cNota, char, Numero do documento
@param cSerie, char, Série do documento
@param cCliente, char, Codigo do cliente do documento
@param cLoja, char, Codigo da loja do cliente do documento

@return cRet, char, Natureza fiscal do título
/*/
//-------------------------------------------------------------------
Static Function GetTitNat(cNota, cSerie, cCliente, cLoja)
Local cRet       := ""
Local cAliasAux  := GetNextAlias()

BeginSql Alias cAliasAux
	SELECT E1_NATUREZ
	FROM %Table:SE1% SE1
	WHERE E1_FILIAL = %xFilial:SE1%
		AND E1_NUM = %Exp:cNota%
		AND E1_PREFIXO = %Exp:cSerie%
		AND E1_TIPO = %Exp:MVNOTAFIS%
		AND E1_CLIENTE = %Exp:cCliente%
		AND E1_LOJA = %Exp:cLoja%
		AND SE1.%notDel%
EndSql

If ( cAliasAux )->( !EOF() )
	cRet := (cAliasAux)->E1_NATUREZ
EndIf

(cAliasAux)->( dbCloseArea() )

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} getValTotal
Funcao responsavel por retornar o valor com ou sem desconto.

@param	nValTotPed		Valor total do Pedido.
		nSD2_TOTAL		Valor gravado com abatimento do desconto.

@return	nValor			Valor retornado conforme municipio, caso 
						nao seja informado, mantera o legado.
            
@author Douglas Parreja
@since  16/08/2018
@version 3.0 
/*/
//-----------------------------------------------------------------------
static function getValTotal( nValTotPed, nSD2_TOTAL )

	local lValSemDesc		:= .F.
	default nValTotPed		:= 0
	default nSD2_TOTAL		:= 0

	//------------------------------------------------------
	// Municipio a ser retornado valor total sem Desconto
	//------------------------------------------------------
	if( (valtype("nValTotPed") <> "U") .and. (valtype("nSD2_TOTAL") <> "U") )
		if( (valtype(nValTotPed) == "N") .and. (valtype(nSD2_TOTAL) == "N") ) 
			if( iif( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) $ "2927408" )
				lValSemDesc := .T.
			endif
		endif	
	endif
		
return iif( lValSemDesc, nValTotPed, nSD2_TOTAL )


//-----------------------------------------------------------------------
/*/{Protheus.doc} getValDesc
Funcao responsavel por retornar a somatoria do Desconto.

@param		lMvded			Parametro Habilita/Desabilita as Deducoes da NFSE.
			cCliente		Codigo do Cliente
			cLoja			Codigo da loja
			cNota			Numero do documento 
			cSerie			Serie do documento
			cCodISS		Codigo do servico
			nSD2Desc		Valor do desconto na tabela SD2.
			
@return	nValor			Valor do documento.

            
@author Douglas Parreja
@since  04/09/2018
@version 3.0 
/*/
//-----------------------------------------------------------------------
static function getValDesc(lMvded, cCliente, cLoja, cNota, cSerie, cCodISS, nSD2Desc )
							
	local nRet			:= 0
	local nValor		:= 0
	local cAliasSF3	:= GetNextAlias()
									
	default lMvded	:= .F.
	default cCliente 	:= ""
	default cloja		:= ""
	default cNota		:= ""
	default cSerie	:= ""
	default cCodISS	:= ""
	default nSD2Desc	:= 0
	
	dbSelectArea("SF3")
	SF3->(dbSetOrder(4))
	if ( dbSeek(xFilial("SF3")+cCliente+cloja+cNota+cSerie) )		
		//---------------------------------------------------------------
		// Hoje o processo existente eh gerar um registro na tabela SF3 
		// para N registros na tabela SD2, principalmente quando houver
		// aglutinacao, considerando Codigo Servico + Aliquota + 
		// Codigo tributacao municipio.
		// Neste cenario, somente retornara o valor da primeira vez.
		//---------------------------------------------------------------		
		if ( nCountSF3 == 0 )		
									
			BeginSql Alias cAliasSF3
			select COUNT(*) NCOUNT
			FROM %Table:SF3% SF3
			WHERE SF3.F3_CLIEFOR= %Exp:cCliente%
					AND SF3.F3_LOJA = %Exp:cLoja%
					AND SF3.F3_NFISCAL = %Exp:cNota%
					AND SF3.F3_SERIE = %Exp:cSerie%
					AND SF3.F3_CODISS = %Exp:cCodISS%
					AND SF3.%notDel%
			EndSql
			//---------------------------------------------------------------		
			// Retorno da quantidade de registros com mesmo cod.servico
			//---------------------------------------------------------------		
			if ( cAliasSF3 )->( !EOF() )
				nRet := (cAliasSF3)->NCOUNT				
			endif															
			(cAliasSF3)->( dbCloseArea() )
		
			//---------------------------------------------------------------
			// Processo para retorno do valor a ser calculado
			//---------------------------------------------------------------				
			if ( valtype(nValor) == "N" )		
				if ( nRet > 0 )	
					if ( nRet == 1 )																																			
						if ( lMvded .and. nSD2Desc > 0 )
							nValor += SF3->F3_ISSSUB + SF3->F3_ISSMAT + nSD2Desc
						else
							nValor += SF3->F3_ISSSUB + SF3->F3_ISSMAT
						endif		
						nCountSF3++		
					//else
						// Funcao para realizar possivel tratamento quando houver mais de 1 registro na SF3.						
					endif
				endif
			endif
		endif							
	endif
	
return ( nValor )

//-----------------------------------------------------------------------
/*/{Protheus.doc} TssCnae
Retorna os codigos CNAE que permitem itens de serviços com marcação "Não Tributavel - N" 

@author Totvs
@since 16/10/2018
@version 1.0 

@return	String com todas atividades que permitem itens de serviços com marcação "Não Tributavel"
@obs		
/*/
//-----------------------------------------------------------------------

static function TssCnae(cCodMun, cCnae)

Local cRetTer 	:= ""
Local cRetUbl 	:= ""
Local cRetBel 	:= ""
Local cRetCpo 	:= ""
Local cPipe	    := "-"
Local lRet      := .F.

Default cCodMun := ""
Default cCnae   := "" 

/*CNAE Teresina - Códigos não tributaveis*/

cRetTer  +=	"661340000" + cPipe //ADMINISTRACAO DE CARTOES DE CREDITO
cRetTer  +=	"869099900"         //OUTRAS ATIVIDADES DE ATENCAO A SAUDE HUMANA NAO ESPECIFICADAS ANTERIORMENTE

/*CNAE Uberlandia - Códigos não tributaveis*/

cRetUbl +=	"661340000" + cPipe //ADMINISTRACAO DE CARTOES DE CREDITO
cRetUbl +=	"731909900" + cPipe //OUTRAS ATIVIDADES DE PUBLICIDADE NAO ESPECIFICADAS
cRetUbl +=	"782050000" + cPipe //LOCACAO DE MAO DE OBRA TEMPORARIA
cRetUbl +=	"865000320" + cPipe //ATIVIDADES DE PSICANALISE
cRetUbl +=	"551080100" + cPipe //HOTEIS
cRetUbl +=	"551080200" + cPipe //APARTHOTEIS
cRetUbl +=	"551080300" + cPipe //MOTEIS
cRetUbl +=	"559060100" + cPipe //ALBERGUES, EXCETO ASSISTENCIAIS
cRetUbl +=	"559060300" + cPipe //PENSOES (ALOJAMENTO)
cRetUbl +=	"559069900" + cPipe //OUTROS ALOJAMENTOS NAO ESPECIFICADOS ANTERIORMENTE
cRetUbl +=	"655020002" + cPipe //PLANOS DE SAUDE (COOPERATIVA)
cRetUbl +=	"869099901" + cPipe //OUTRAS ATIVIDADES DE ATENCAO A SAUDE HUMANA NAO ESPECIFICADO ANTERIORMENTE
cRetUbl +=	"869099902" + cPipe //OUTRAS ATIVIDADES DE ATENCAO A SAUDE HUMANA NAO ESPECIFICADO ANTERIORMENTE (SERVIÇOS MÉDICOS DE ANESTESIA)
cRetUbl +=	"655020003"         //PLANOS DE SAUDE (COOPERATIVA ODONTOLOGICA)

/*CNAE Belem - Códigos não tributaveis*/

cRetBel  +=	"829970200" + cPipe //EMISSAO DE VALES-ALIMENTACAO, VALES-TRANSPORTE E SIMILARES
cRetBel  +=	"551080101" + cPipe //HOTEIS  - NIVEL  I
cRetBel  +=	"551080102" + cPipe //HOTEIS -  - NIVEL  I I
cRetBel  +=	"551080103"         //HOTEISL - NIVEL  I I I

/*CNAE Campo Grande - Códigos não tributaveis*/

cRetCpo  +=	"551080102" + cPipe //HOTEIS
cRetCpo  +=	"731220002" + cPipe //AGENCIAMENTO DE ESPACOS PARA PUBLICIDADE, EXCETO EM VEICULOS DE COMUNICACAO
cRetCpo  +=	"782050002" + cPipe //LOCACAO DE MAODEOBRA TEMPORARIA
cRetCpo  +=	"475120002" + cPipe //Serviços de carga e recargas de cartuchos tintas e toner para equipamento de informática
cRetCpo  +=	"212110102" + cPipe //LABORATORIO DE MANIPULACAO
cRetCpo  +=	"941110002"         //ATIVIDADES DE ORGANIZACOES ASSOCIATIVAS PATRONAIS E EMPRESARIAIS

If cCodMun == "2211001" .And. cCnae $ cRetTer //Teresina - 2211001
	lRet := .T.
ElseIf cCodMun == "3170206" .And. cCnae $ cRetUbl //Uberlandia - 3170206
	lRet := .T.
ElseIf cCodMun == "1501402" .And. cCnae $ cRetBel //Belem - 1501402
	lRet := .T.
ElseIf cCodMun == "5002704" .And. cCnae $ cRetCpo //Campo Grande - 5002704
	lRet := .T.
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} IsRPSLOJA
Verifica se é venda de serviço (RPS) originada do SIGALOJA (Varejo) e retorna as informações 
do local da prestação do serviço.

@author Totvs
@since 19/06/2019
@version 1.0 
@param	aEndPres	Array passado por referência para que seja alimentado com as informações do endereço de prestação do serviço.
@return	lRet		Verifica se é venda de serviço (RPS) originada do SIGALOJA (Varejo)
@obs		
/*/
//-----------------------------------------------------------------------
Static Function IsRPSLOJA(aEndPres)
Local lRet 			:= .F.
Local aFldEndPre	:= {} //Parametro que aponta para os campos da tabela SL1 para pegar as informações do endereço da prestação do serviço
Local nX 			:= 0
Local cField 		:= ""
Local uValue 		:= Nil

/*
Ordem dos campos da tabela SL1 configurados no parâmetro MV_LJENDPS:
01-Endereço Prest. Serviço
02-Núm. End. Prest. Serviço
03-Comp. End. Prest. Serviço
04-Bairro Prestação Serviço
05-UF Prestação Serviço
06-CEP Prestação Serviço
07-Código Mun. Pres. Serviço
08-Descr. Mun. Pres. Serviço
09-País Prestação Serviço
*/

If !Empty(SF2->F2_NUMORC) //Se este campo estiver alimentado significa que é uma venda de RPS originada do SIGALOJA (Varejo)
	
	aFldEndPre	:= &(SuperGetMV("MV_LJENDPS",,"{,,,,,,,,}")) //Parametro que aponta para os campos da tabela SL1 para pegar as informações do endereço da prestação do serviço

	If ValType(aFldEndPre) <> "A"
		aFldEndPre := {}
	EndIf

	//Ajusta o array para que tenha a quantidade certa de 9 posições
	aSize(aFldEndPre, 9)
	For nX:=1 To Len(aFldEndPre)
		If aFldEndPre[nX] == Nil
			aFldEndPre[nX] := ""
		EndIf
	Next nX

	DbSelectArea("SL1")
	SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
	If SL1->(DbSeek(xFilial("SL1")+SF2->F2_NUMORC))
		
		lRet 	 := .T.
		aEndPres := {}

		For nX:=1 To Len(aFldEndPre)
			cField := aFldEndPre[nX]
			uValue := ""
			If !Empty(cField)
				If SL1->(ColumnPos(aFldEndPre[nX])) > 0
					uValue := SL1->&(cField)
				EndIf
			EndIf

			aAdd( aEndPres, uValue )
		Next nX

	EndIf

EndIf

Return lRet

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)
