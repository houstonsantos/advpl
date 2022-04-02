#include 'protheus.ch'


/*/{Protheus.doc} F080BENEF
    (Alteração do nome de beneficiario(cheque) de A2_NREDUZ para A2_NOME)
    @type  Function
    @author Houston Santos
    @since 10/06/2019
    @version version
    @return return
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=236424444)
/*/

User Function F080BENEF()
	
	Local aArea := GetArea()
	Local cBeneficiario := PadR(SA2->A2_NOME, TamSx3("EF_BENEF")[1])
	RestArea(aArea)
	
Return cBeneficiario
