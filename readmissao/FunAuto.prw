#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} FunAuto
    (Programa para aproveitar o cadastro antigo do funcionario quando o funcionario estiver sendo readmitido, pegar cadastro anterior)
    @type Function
    @author Houston Santos
    @since 13/03/2019
    @version 1
    @param none
    @return true
    @example
    (examples)
    @see (links_or_references)
/*/

User Function FUNAUTO()

	If (INCLUI)
		// Criando query para pegar ultimo registro de acrodo com o CPF informado.
		cQry := " SELECT TOP 1 R_E_C_N_O_ FROM " + RetSqlName("SRA")
		cQry += " WHERE RA_CIC = '"+M->RA_CIC+"' "
		cQry += " ORDER BY R_E_C_N_O_ DESC "

		DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), 'QSRA' , .F., .T.) 
		
		nTotReg := Contar("QSRA","!Eof()")
	
		If nTotReg > 0
			QSRA->(DbGoTop())
		Else
			QSRA->(DbCloseArea())    
			Return(.T.)
		EndIf
 	
		// Percorrer tabela SRA procurando o CPF.
		SRA->(DbSelectArea("SRA"))
		SRA->(DbSetOrder(5))
		SRA->(DbGoTo(QSRA->R_E_C_N_O_))
		
		If SRA->RA_SITFOLH == "D" 
			If MsgYesNo( "Foi encontrado dados relacionados a este CPF: "+ AllTrim(SRA->RA_CIC) + " NOME: "+ AllTrim(SRA->RA_NOME) +". Deseja readmitir?", "Readmissção" )
				Processa( {|| OkDados() }, "Aguarde...", "Carregando dados do funcionario...",.F.)
			Else
				// Nada
			Endif
		ElseIf SRA->RA_SITFOLH == "A" 
			Alert("Foi encontrado dados relacionados a este CPF: "+ AllTrim(SRA->RA_CIC) + " NOME: "+ AllTrim(SRA->RA_NOME) +". Funcionario Afastado Temporariamente.")
		ElseIf SRA->RA_SITFOLH == "F" 
			Alert("Foi encontrado dados relacionados a este CPF: "+ AllTrim(SRA->RA_CIC) + " NOME: "+ AllTrim(SRA->RA_NOME) +". Funcionario de Férias")
		EndIf

		SRA->(DbCloseArea())
		QSRA->(DbCloseArea())
	EndIf
	
Return(.T.)


/*/{Protheus.doc} OkDados
	(Realiza verificação dos campos na SX3)
    @type Function
    @author Houston Santos
    @since 13/03/2019
    @version 1
    @param none
    @return true
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function OkDados()

	SX3->(DbSelectArea("SX3"))
	SX3->(DbSetOrder(1))

	ProcRegua(RecCount())

	If SX3->(MsSeek("SRA"))
		While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "SRA"
			IncProc() 
			// Campo RA_CPAISOR é um campo virtual, tornando assim impossivel pegar de um cadastro anterior.
			// Os campos informados a baixo, são campos do antigo cadastro que não devem ser informados no novo cadastro.
			cCpoNo := "RA_FILIAL #RA_MAT    #RA_DATAALT#RA_TIPOALT#RA_SITFOLH#RA_DEMISSA#RA_ADMISSA#RA_OPCAO  #RA_VCTOEXP#RA_VCTEXP2#RA_EXAMEDI#RA_DTCAGED"
			
			If !SX3->X3_CAMPO $ cCpoNo .AND. X3USO(SX3->X3_USADO) .AND. !SX3->X3_VISUAL $ "V#"
				&("M->"+SX3->X3_CAMPO) := &("SRA->"+SX3->X3_CAMPO)	
			EndIf
			SX3->(DbSkip())
		EndDo
	EndIf

Return()
