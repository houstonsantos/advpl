#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'


/*APÓS CONFIRMAR A EXCLUSÃO (07/10/2020)
Este P.E. será executado após o usuário confirmar a exclusão; Depois da execução do mesmo, 
será feita a exclusão efetiva dos dados do Cliente no arquivo.
*/

User Function M030EXC()

Local lRet := .T.

dbSelectArea("CTD")
CTD->(dbSetOrder(1))
CTD->(dbGoTop())

IF CTD->(dBSeek(xFilial("CTD") + "C" + SA1->A1_COD + SA1->A1_LOJA))
	RecLock("CTD", .F.)
	dbDelete()
	CTD->(MsUnLock())
	
Endif

CTD->(dbCloseArea())

Return lRet
