#include 'Protheus.ch'


/*/{Protheus.doc} MT100GE2
    (Grava na SE2(E2_CCD) o centro de custo(D1_CC), somente qunado houver 
    um �nico CC no documento de entrada e grava o c�digo de barras E2_CODBAR)
    @type Function
    @author Houston Santos
    @since 12/07/2019
    @version version
    @return array
    @see (http://tdn.totvs.com/pages/releaseview.action?pageId=6085781)
/*/

User Function MT100GE2()

    Local i := 0  
    Local j := 0  
    Local nLinha := PARAMIXB[1]
    Local nOpc := PARAMIXB[2]
    Local aHeadSE2 := PARAMIXB[3]
    Local cCusto := Iif(AllTrim(SD1->D1_CC) == "", nLinha[AScan(aHeadSE2, {|x|AllTrim(x[2]) == "E2_CCD"})], SD1->D1_CC)

    // Inclus�o.
    If (nOpc == 1)
        // Grava c�digo de barras informado na classifica��o.
        SE2->E2_CODBAR := nLinha[AScan(aHeadSE2, {|x|AllTrim(x[2]) == "E2_CODBAR"})]
        // Valida centro de custo.
        If (Len(aCols) > 1)
            For i := 1 to 1
                For j := i to Len(aCols)
                    // Verifica se os centros de custos inofrmados s�o iguais, em caso de diferen�a n�o haver� altera��o.
                    if (aCols[j,13] != aCols[i,13])
                        Exit
                    EndIf
                Next
            Next
            // Grava centro de custo quando todos centro de custo D1_CC forem iguais.
            SE2->E2_CCD := cCusto
        Else
            // Grava centro de custo quando s� tiver um item D1_CC.
            SE2->E2_CCD := cCusto
        EndIf
    EndIf

Return
