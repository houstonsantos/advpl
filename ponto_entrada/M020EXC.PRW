#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'


/*
M020EXC - Complementa validações de exclusão de fornecedor (07/10/2020)
O ponto de entrada M020EXC complementa as validações do sistema sobre a exclusão de registros
do cadastro de fornecedores (Tabela SA2) com validações de usuário.

LOCALIZAÇÃO : Função fAvalSA2() - Complementa a atualização da tabela de fornecedo
EM QUE PONTO : Após as validações do sistema para a exclusão do registro do Fornecedor 
Deve ser utilizado para realizar validações de usuário, complementando as validações do sistema.
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
