#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'


/*
M020EXC - Complementa valida��es de exclus�o de fornecedor (07/10/2020)
O ponto de entrada M020EXC complementa as valida��es do sistema sobre a exclus�o de registros
do cadastro de fornecedores (Tabela SA2) com valida��es de usu�rio.

LOCALIZA��O : Fun��o fAvalSA2() - Complementa a atualiza��o da tabela de fornecedo
EM QUE PONTO : Ap�s as valida��es do sistema para a exclus�o do registro do Fornecedor 
Deve ser utilizado para realizar valida��es de usu�rio, complementando as valida��es do sistema.
*/

User Function M020EXC()

Local lRet := .T.

dbSelectArea("CTD")
CTD->(dbSetOrder(1))
CTD->(dbGoTop())

IF CTD->(dBSeek(xFilial("CTD") + "F" + SA2->A2_COD + SA2->A2_LOJA))
	RecLock("CTD", .F.)
	dbDelete()
	CTD->(MsUnLock())
	
Endif

CTD->(dbCloseArea())

Return lRet
