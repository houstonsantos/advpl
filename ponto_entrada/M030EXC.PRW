#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'


/*AP�S CONFIRMAR A EXCLUS�O (07/10/2020)
Este P.E. ser� executado ap�s o usu�rio confirmar a exclus�o; Depois da execu��o do mesmo, 
ser� feita a exclus�o efetiva dos dados do Cliente no arquivo.
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
